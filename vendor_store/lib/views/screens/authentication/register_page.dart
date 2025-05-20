import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_store/controllers/vendor_auth_controller.dart';
import 'package:vendor_store/views/screens/authentication/login_page.dart';
import '../../../common/widgets/app_button.dart';
import '../../../common/widgets/app_text_field.dart';
import '../../../resource/asset/app_images.dart';
import '../../../resource/theme/app_colors.dart';
import '../../../resource/theme/app_styles.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final VendorAuthController _vendorAuthController = VendorAuthController();
  final ImagePicker picker = ImagePicker();

  String fullName = "";
  String email = "";
  String phone = "";
  String password = "";
  File? imageFile;
  bool isLoading = false;

  // Xử lý đăng ký
  void registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      await _vendorAuthController.signUpVendor(
        fullName: fullName,
        email: email,
        phone: phone,
        address: "",
        password: password,
        context: context,
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  // Chọn ảnh từ thư viện hoặc máy ảnh
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  // Hiển thị bottom sheet để chọn ảnh
  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Chọn từ thư viện"),
                onTap: () {
                  pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Chụp ảnh"),
                onTap: () {
                  pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            height: screenHeight * 0.4,
            width: double.infinity,
            child: Image.asset(
              AppImages.imgBrSignUp,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Đăng ký",
                        style: AppStyles.STYLE_36_BOLD.copyWith(color: Colors.black),
                      ),
                      const SizedBox(height: 20),

                      // Ô chọn ảnh đại diện
                      GestureDetector(
                        onTap: () => _showImagePicker(context),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.gold50,
                          backgroundImage: imageFile != null ? FileImage(imageFile!) : null,
                          child: imageFile == null
                              ? const Icon(Icons.camera_alt, size: 40, color: Colors.blue)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      AppTextField(
                        hintText: "Nhập họ và tên",
                        prefixImage: AppImages.icUser,
                        onChanged: (value) => fullName = value,
                        validator: (value) => value!.isEmpty ? "Vui lòng nhập họ và tên" : null,
                      ),
                      const SizedBox(height: 15),
                      AppTextField(
                        hintText: "Nhập email",
                        prefixImage: AppImages.icEmail,
                        onChanged: (value) => email = value,
                        validator: (value) => value!.isEmpty ? "Vui lòng nhập email" : null,
                      ),
                      const SizedBox(height: 15),
                      AppTextField(
                        hintText: "Nhập số điện thoại",
                        prefixImage: AppImages.icUser,
                        onChanged: (value) => phone = value,
                        validator: (value) => value!.isEmpty ? "Vui lòng nhập số điện thoại" : null,
                      ),
                      const SizedBox(height: 15),
                      AppTextField(
                        hintText: "Nhập mật khẩu",
                        prefixImage: AppImages.icPassword,
                        isPassword: true,
                        onChanged: (value) => password = value,
                        validator: (value) => value!.length < 6 ? "Mật khẩu phải có ít nhất 6 ký tự" : null,
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        text: "Đăng ký",
                        isLoading: isLoading,
                        onPressed: registerUser,
                        color: AppColors.bluePrimary,
                        textColor: AppColors.white,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Đã có tài khoản?",
                            style: AppStyles.STYLE_16.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return  const LoginPage();
                              }));
                            },
                            child: Text(
                              " Đăng nhập",
                              style: AppStyles.STYLE_16_BOLD.copyWith(
                                color: AppColors.bluePrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}