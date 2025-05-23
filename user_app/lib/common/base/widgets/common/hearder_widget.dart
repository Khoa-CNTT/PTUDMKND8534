import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_store/common/base/widgets/common/custom_search.dart';
import 'package:multi_store/resource/asset/app_images.dart';
import 'package:multi_store/resource/theme/app_colors.dart';
import 'package:multi_store/resource/theme/app_style.dart';
import 'package:multi_store/ui/navigation/screens/cart_page.dart';
import 'package:multi_store/provider/cart_provider.dart';

import '../../../../provider/user_provider.dart';
import 'my_profile_widget.dart';

class HeaderWidget extends ConsumerStatefulWidget {
  const HeaderWidget({super.key});

  @override
  ConsumerState<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends ConsumerState<HeaderWidget> {
  @override
  Widget build(BuildContext context) {
    final cartData = ref.watch(cartProvider);
    final user = ref.watch(userProvider);
    ImageProvider _buildUserImage(String? imagePath) {
      if (imagePath == null || imagePath.isEmpty) {
        return AssetImage(AppImages.imgDefaultAvatar);
      } else if (imagePath.startsWith('http')) {
        return NetworkImage(imagePath);
      } else {
        final file = File(imagePath);
        if (file.existsSync()) {
          return FileImage(file);
        } else {
          return AssetImage(AppImages.imgDefaultAvatar);
        }
      }
    }

    // Future<void> _refreshData() async {
    //   ref.invalidate(userProvider);
    // }
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.22,
      child: Stack(
        children: [
          // // Nen banner
          // Image.asset(
          //   AppImages.imgSearchBanner,
          //   width: MediaQuery.of(context).size.width,
          //   fit: BoxFit.cover,
          // ),
          Positioned(
            top: 60,
            left: 20,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return MyProfileWidget(
                        image: user.image,
                        fullName: user.fullName,
                        phone: user.phone,
                        email: user.email,
                        address: user.address,
                      );
                    }));
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: _buildUserImage(user!.image),

                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 30,
            left: 140,
            child: Image.asset(AppImages.imgBt, width: 100, height: 100),
          ),

          // Icon gio hang (ben phai)
          Positioned(
            top: 60,
            right: 5,
            child: Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return const CartPage();
                    }));
                  },
                  icon: SvgPicture.asset(
                    AppImages.icCartWhite,
                    height: 30,
                    width: 30,
                    color: AppColors.bluePrimary,
                  ),
                ),
                if (cartData.isNotEmpty)
                  Positioned(
                    right: 4,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cartData.length.toString(),
                        style: AppStyles.STYLE_12_BOLD.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
       const   Positioned(
            top: 120,
            left: 15,
            child: SizedBox(
              child:  CustomSearch(),
            ),
          ),

        ],
      ),
    );
  }
}
