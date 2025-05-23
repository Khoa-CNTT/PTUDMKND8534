import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:multi_store/resource/asset/app_images.dart';
import 'package:multi_store/resource/theme/app_colors.dart';
import 'package:multi_store/resource/theme/app_style.dart';

import '../details/products/search_product_screen.dart';

class CustomSearch extends StatelessWidget {
  const CustomSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      height: 60,
      child: TextField(
        readOnly: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchProductScreen()),
          );
        },
        decoration: InputDecoration(
          hintText: "Tìm kiếm sản phẩm",
          hintStyle: AppStyles.STYLE_14.copyWith(color: AppColors.bluePrimary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          suffixIcon: GestureDetector(
            onTap: () {
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                AppImages.icCamera,
                width: 8,
                height: 8,
                 color: AppColors.bluePrimary,
              ),
            ),
          ),
          fillColor: AppColors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
