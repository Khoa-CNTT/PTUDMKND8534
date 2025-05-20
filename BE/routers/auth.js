const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Vendor = require('../models/vendor');
const User = require('../models/user');
const crypto = require('crypto');
const sendOtpEmail = require('../helper/send_email'); 
const otpStore = new Map(); 
const { auth } = require('../middlewares/auth'); 
const authRouter = express.Router();

// ✅ API ĐĂNG KÝ
authRouter.post('/api/signup', async (req, res) => {
  try {
    const { fullName, email, phone, password, image, address } = req.body;

    const existingVendorEmail = await Vendor.findOne({ email });
    if (existingVendorEmail) {
      return res.status(400).json({ msg: "Email này đã được sử dụng" });
    }
    // Kiểm tra email & phone trùng
    const existingEmail = await User.findOne({ email });
    if (existingEmail) {
      return res.status(400).json({ msg: "Email này đã được sử dụng" });
    }

    const existingPhone = await User.findOne({ phone });
    if (existingPhone) {
      return res.status(400).json({ msg: "Số điện thoại này đã được sử dụng" });
    }
 
    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Tạo OTP 6 chữ số
    const otp = crypto.randomInt(100000, 999999).toString();

    // Lưu OTP
    otpStore.set(email, { otp, expiresAt: Date.now() + 10 * 60 * 1000 });

    // Tạo user mới
    let user = new User({
      fullName,
      email,
      phone,
      password: hashedPassword,
      isVerified: false,
      image: image || "",
      address: address || "", 
    });

    user = await user.save();

    // Gửi email xác thực OTP
    await sendOtpEmail(email, otp);
    console.log("OTP đã được gửi đến email:", email);
    return res.status(201).json({
      msg: "Đăng ký thành công. Vui lòng kiểm tra email để xác thực tài khoản.",
      user,
    });

  } catch (e) {
    console.error("Loi trong quá trình đăng ký",e);
        return res.status(500).json({ error: "Đã xảy ra lỗi trong quá trình đăng ký. Vui lòng thử lại sau." });
  }
});



// ✅ API ĐĂNG NHẬP
authRouter.post('/api/signin', async (req, res) => {
  try {
    const { loginInput, password } = req.body;

    const findUser = await User.findOne({
      $or: [{ email: loginInput }, { phone: loginInput }]
    });

    if (!findUser) {
      return res.status(400).json({ msg: "Không tìm thấy người dùng với thông tin đã cung cấp" });
    }

    if (!findUser.isVerified) {
      return res.status(403).json({ msg: "Tài khoản chưa được xác thực. Vui lòng kiểm tra email." });
    }

    const isMatch = await bcrypt.compare(password, findUser.password);
    if (!isMatch) {
      return res.status(400).json({ msg: "Mật khẩu không đúng" });
    }

    const token = jwt.sign({ id: findUser._id }, "passwordKey",{ expiresIn: "1d" });

    const { password: _, ...userWithoutPassword } = findUser._doc;

    return res.json({ token,userWithoutPassword });

  } catch (error) {
    console.error("❌ Lỗi đăng nhập:", error);
    return res.status(500).json({ error: "Đã xảy ra lỗi trong quá trình đăng nhập. Vui lòng thử lại sau." });
  }
});

// API KIỂM TRA TOKEN 
authRouter.post('/api/tokenIsValid', async (req, res) => {
  try {
    const token = req.header("x-auth-token");
    if (!token) return res.json(false);

    const verified = jwt.verify(token, "passwordKey");
    if (!verified) return res.json(false);

    const user = await User.findById(verified.id);
    if (!user) return res.json(false);

    return res.json(true);
  } catch (e) {
    console.log("❌ Lỗi xác thực token:", e);
    return res.status(500).json({
      error: "Đã xảy ra lỗi trong quá trình xác thực token. Vui lòng thử lại sau.",
    });
  }
});

// Xác định một tuyến đường lấy cho roter xác thực
authRouter.get('/', auth, async(req, res) => {
try {

  const user = await User.findById(req.user); 

 return  res.json({...user._doc, token: req.token}); // Trả về thông tin người dùng và token
  
} catch (e) {
  console.error("❌ Lỗi xác thực:", e);
  return res.status(500).json({ error: "Đã xảy ra lỗi trong quá trình xác thực. Vui lòng thử lại sau." });  
  
}

});

// ✅ API XÁC THỰC OTP
authRouter.post('/api/verify-otp', async (req, res) => {
  try {
    const { email, otp } = req.body;

    const storedOtpData = otpStore.get(email);
    console.log("Stored OTP Data:", storedOtpData); // Debugging line

    if (!storedOtpData) {
      return res.status(400).json({ msg: "Mã OTP không hợp lệ hoặc đã hết hạn" });
    }

    if (storedOtpData.otp !== otp) {
      return res.status(400).json({ msg: "Mã OTP không đúng" });
    }

    if (storedOtpData.expiresAt < Date.now()) {
      otpStore.delete(email);
      return res.status(400).json({ msg: "Mã OTP đã hết hạn" });
    }

    const user = await User.findOneAndUpdate(
      { email },
      { isVerified: true },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ msg: "Không tìm thấy người dùng" });
    }

    otpStore.delete(email);
    return res.status(200).json({ msg: "Xác thực thành công" });

  } catch (e) {
    console.error("❌ Lỗi xác thực OTP:", e);
    return res.status(500).json({ error: "Đã xảy ra lỗi trong quá trình xác thực OTP. Vui lòng thử lại sau." });
  }
});



// ✅ API cập nhật người dùng
authRouter.put('/api/user/update/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { fullName, phone, email, address, image } = req.body;

    const updatedUser = await User.findByIdAndUpdate(
      id,
      { fullName, phone, email, address, image },
      { new: true }
    );

    if (!updatedUser) {
      return res.status(404).json({ msg: "Không tìm thấy người dùng" });
    }

    const { password, ...userWithoutPassword } = updatedUser._doc;

    return res.json({
      msg: "Cập nhật thông tin thành công",
      user: userWithoutPassword,
    });
  } catch (error) {
    return res.status(500).json({ error: "Lỗi cập nhật thông tin: " + error.message });
  }
});

// ✅ API lấy toàn bộ người dùng (ẩn mật khẩu)
authRouter.get('/api/user', async (req, res) => {
  try {
    const users = await User.find().select('-password');
    return res.status(200).json(users);
  } catch (error) {
    return res.status(500).json({ error: "Lỗi lấy thông tin người dùng: " + error.message });
  }
});

// xoá người dùng hoặc vendor API
authRouter.delete('/api/user/delete-account/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;

    const user = await User.findById(id);
    const vendor = await Vendor.findById(id);

    if (!user && !vendor) {
      return res.status(404).json({ msg: "Không tìm thấy người dùng hoặc vendor" });
    }

    if (user) {
      await User.findByIdAndDelete(id);
    } else if (vendor) {
      await Vendor.findByIdAndDelete(id);
    }

    return res.status(200).json({ msg: "Xóa tài khoản thành công" });

  } catch (error) {
    return res.status(500).json({ error: "Lỗi xóa người dùng: " + error.message });
  }
});




module.exports = authRouter;
