import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multi_store/common/base/widgets/common/my_profile_widget.dart';
import 'package:multi_store/common/base/widgets/details/order/order_screen.dart';
import 'package:multi_store/provider/cart_provider.dart';
import 'package:multi_store/provider/favorite_provider.dart';
import 'package:multi_store/resource/asset/app_images.dart';
import 'package:multi_store/resource/theme/app_colors.dart';
import 'package:multi_store/resource/theme/app_style.dart';
import 'package:multi_store/controller/auth_controller.dart';
import 'package:multi_store/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/base/widgets/common/confirm_dialog.dart';
import '../../../provider/delivered_order_count_provider.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  final AuthController _authController = AuthController();

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

  Future<void> _refreshData() async {
    final buyerId = ref.read(userProvider)!.id;
    // Invalidate providers to force refresh
    ref.invalidate(userProvider);
    ref.invalidate(deliveredOrderCountProvider);
    ref.invalidate(cartProvider);
    ref.invalidate(favoriteProvider);
    // Fetch updated delivered orders count
    await ref.read(deliveredOrderCountProvider.notifier).fetchDeliveredOrdersCount(buyerId, context);
  }

  @override
  Widget build(BuildContext context) {
    final buyerId = ref.read(userProvider)!.id;
    ref.read(deliveredOrderCountProvider.notifier).fetchDeliveredOrdersCount(buyerId, context);

    final deliveredCount = ref.watch(deliveredOrderCountProvider);
    final user = ref.read(userProvider);
    final cartData = ref.read(cartProvider);
    final favoriteCount = ref.read(favoriteProvider);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 350,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        AppImages.imgBrProfile,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 70,
                      left: 150,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: _buildUserImage(user!.image),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return MyProfileWidget(
                                    image: user.image,
                                    fullName: user.fullName,
                                    phone: user.phone,
                                    email: user.email,
                                    address: user.address,
                                  );
                                })).then((_) => _refreshData()); // Refresh after returning from profile edit
                              },
                              child: SvgPicture.asset(
                                AppImages.icEdit,
                                width: 20,
                                height: 20,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0, 0.10),
                      child: user!.fullName != ""
                          ? Text(
                        user.fullName,
                        style: AppStyles.STYLE_18_BOLD.copyWith(
                          color: AppColors.white,
                        ),
                      )
                          : Text(
                        "User",
                        style: AppStyles.STYLE_18_BOLD.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0, 0.25),
                      child: InkWell(
                        onTap: () {},
                        child: user.address != ""
                            ? Text(
                          user.address,
                          style: AppStyles.STYLE_14.copyWith(
                            color: AppColors.white,
                          ),
                        )
                            : Text(
                          "Địa chỉ",
                          style: AppStyles.STYLE_14.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0, 0.70),
                      child: SizedBox(
                        width: 287,
                        height: 117,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Hoàn tất
                            Positioned(
                              top: 100,
                              left: 265,
                              child: Text(
                                deliveredCount.toString(),
                                style: AppStyles.STYLE_14_BOLD.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 240,
                              top: 120,
                              child: Text(
                                "Hoàn tất",
                                style: AppStyles.STYLE_14.copyWith(
                                  color: AppColors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 250,
                              top: 50,
                              child: Container(
                                width: 42,
                                height: 48,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage(AppImages.imgComplete),
                                    fit: BoxFit.contain,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      left: 10,
                                      top: 10,
                                      child: Image.asset(
                                        AppImages.imgDone,
                                        width: 25,
                                        height: 25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Yêu thích
                            Positioned(
                              left: 140,
                              top: 100,
                              child: Text(
                                favoriteCount.length.toString(),
                                style: AppStyles.STYLE_14_BOLD.copyWith(
                                  color: AppColors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 115,
                              top: 120,
                              child: Text(
                                "Yêu thích",
                                style: AppStyles.STYLE_14.copyWith(
                                  color: AppColors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 125,
                              top: 50,
                              child: Container(
                                width: 42,
                                height: 48,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    fit: BoxFit.contain,
                                    image: AssetImage(AppImages.imgComplete),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      left: 10,
                                      top: 13,
                                      child: Image.asset(
                                        AppImages.imgFavorite,
                                        width: 25,
                                        height: 25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Cart
                            Positioned(
                              left: 12,
                              top: 100,
                              child: Text(
                                cartData.length.toString(),
                                style: AppStyles.STYLE_14_BOLD.copyWith(
                                  color: AppColors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            Positioned(
                              left: -4,
                              top: 120,
                              child: Text(
                                "Giỏ hàng",
                                style: AppStyles.STYLE_14.copyWith(
                                  color: AppColors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 50,
                              child: Container(
                                width: 42,
                                height: 48,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage(AppImages.imgComplete),
                                    fit: BoxFit.contain,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      left: 10,
                                      top: 10,
                                      child: Image.asset(
                                        AppImages.imgCart,
                                        width: 25,
                                        height: 25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const OrderScreen();
                  }));
                },
                leading: const Icon(Icons.art_track_rounded),
                title: Text(
                  "Theo dõi đơn hàng",
                  style: AppStyles.STYLE_14_BOLD.copyWith(color: AppColors.blackFont),
                ),
              ),
              const SizedBox(height: 5),
              ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const OrderScreen();
                  }));
                },
                leading: const Icon(Icons.history),
                title: Text(
                  "Lịch sử mua hàng",
                  style: AppStyles.STYLE_14_BOLD.copyWith(color: AppColors.blackFont),
                ),
              ),
              const SizedBox(height: 5),
              ListTile(
                onTap: () {},
                leading: const Icon(Icons.help_outline),
                title: Text(
                  "Trợ giúp",
                  style: AppStyles.STYLE_14_BOLD.copyWith(color: AppColors.blackFont),
                ),
              ),
              const SizedBox(height: 5),
              ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ConfirmDialog(
                      content: "Bạn có chắc chắn muốn đăng xuất không?",
                      onConfirm: () async {
                        await _authController.signOutUser(context: context, ref: ref);
                      },
                      onCancel: () {},
                    ),
                  );
                },
                leading: const Icon(Icons.logout),
                title: Text(
                  "Đăng xuất",
                  style: AppStyles.STYLE_14_BOLD.copyWith(color: AppColors.blackFont),
                ),
              ),
              const SizedBox(height: 5),
              ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ConfirmDialog(
                      content: "Bạn có chắc chắn muốn xóa tài khoản không?",
                      onConfirm: () async {
                        await _authController.deleteAccount(context: context, id: user.id, ref: ref);
                      },
                      onCancel: () {},
                    ),
                  );
                },
                leading: const Icon(Icons.delete),
                title: Text(
                  "Xóa tài khoản",
                  style: AppStyles.STYLE_14_BOLD.copyWith(color: AppColors.blackFont),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}