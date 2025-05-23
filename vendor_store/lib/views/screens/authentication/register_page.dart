import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_store/controllers/vendor_auth_controller.dart';
import 'package:vendor_store/views/screens/authentication/login_page.dart';
import '../../../common/widgets/app_button.dart';
import '../../../common/widgets/app_text_field.dart';
import '../../../resource/asset/app_images.dart';
import '../../../resource/theme/app_colors.dart';
import '../../../resource/theme/app_styles.dart';
import '../../../services/manage_http_response.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final VendorAuthController _vendorAuthController = VendorAuthController();
  final ImagePicker picker = ImagePicker();
  final ValueNotifier<File?> imageNotifier = ValueNotifier<File?>(null);

  String fullName = "";
  String email = "";
  String phone = "";
  String password = "";
  bool isLoading = false;

  // Pick image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      imageNotifier.value = File(pickedFile.path);
    } else {
      showSnackBar(context, "Không lấy được ảnh");
    }
  }

  // Show bottom sheet for image source selection
  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(CupertinoIcons.photo, color: AppColors.bluePrimary),
                title: Text("Chọn từ thư viện", style: AppStyles.STYLE_16),
                onTap: () {
                  pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.camera, color: AppColors.bluePrimary),
                title: Text("Chụp ảnh", style: AppStyles.STYLE_16),
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

  // Handle registration
  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      // Kiểm tra xem ảnh có được chọn hay không
      if (imageNotifier.value == null) {
        showSnackBar(context, "Vui lòng chọn ảnh đại diện");
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        // Tải ảnh lên Cloudinary
        final cloudinary = CloudinaryPublic("dajwnmjjf", "tb9fytch");
        CloudinaryResponse imageResponse = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imageNotifier.value!.path,
            identifier: "vendor_profile",
            folder: "storeImage",
          ),
        );
        String imageUrl = imageResponse.secureUrl;

        // Gọi signUpVendor với URL ảnh
        await _vendorAuthController.signUpVendor(
          fullName: fullName,
          email: email,
          phone: phone,
          address: "",
          password: password,
          context: context,
          storeImage: imageUrl, // Truyền URL ảnh
        );
      } catch (e) {
        showSnackBar(context, "Lỗi khi đăng ký: $e");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
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

                      // Image selection
                      ValueListenableBuilder(
                        valueListenable: imageNotifier,
                        builder: (context, image, child) {
                          return InkWell(
                            onTap: () => _showImagePicker(context),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.grey, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: image != null
                                    ? FileImage(image)
                                    : const AssetImage(AppImages.imgDefaultAvatar),
                                child: image == null
                                    ? const Icon(
                                  CupertinoIcons.photo,
                                  size: 40,
                                  color: AppColors.bluePrimary,
                                )
                                    : null,
                              ),
                            ),
                          );
                        },
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
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