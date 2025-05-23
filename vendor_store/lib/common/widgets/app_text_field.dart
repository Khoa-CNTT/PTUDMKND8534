import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../resource/asset/app_images.dart';
import '../../resource/theme/app_colors.dart';
import '../../resource/theme/app_styles.dart';

class AppTextField extends StatefulWidget {
  final String hintText;
  final String prefixImage;
  final bool isPassword;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.hintText,
    required this.prefixImage,
    this.isPassword = false,
    this.validator,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white40, AppColors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        obscureText: widget.isPassword ? _isObscured : false,
        validator: widget.validator,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          filled: true,
          fillColor: Colors.transparent,
          hintText: widget.hintText,
          hintStyle: AppStyles.STYLE_14.copyWith(
            color: AppColors.black80,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: widget.prefixImage.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              widget.prefixImage,
              width: 24,
              height: 24,
              color: AppColors.black80,
            ),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppColors.bluePrimary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppColors.pink,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppColors.pink,
              width: 2,
            ),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: SvgPicture.asset(
              _isObscured ? AppImages.icEyes : AppImages.icEyes,
              width: 24,
              height: 24,
              color: AppColors.blackFont,
            ),
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
          )
              : null,
        ),
      ),
    );
  }
}