import 'package:admin_panel_app_web/common/widgets/custom_search.dart';
import 'package:admin_panel_app_web/resource/asset/app_images.dart';
import 'package:admin_panel_app_web/views/side_bar_screen/buyers_screen.dart';
import 'package:admin_panel_app_web/views/side_bar_screen/category_screen.dart';
import 'package:admin_panel_app_web/views/side_bar_screen/orders_screen.dart';
import 'package:admin_panel_app_web/views/side_bar_screen/products_screen.dart';
import 'package:admin_panel_app_web/views/side_bar_screen/sub_category_screen.dart';
import 'package:admin_panel_app_web/views/side_bar_screen/upload_banner_screen.dart';
import 'package:admin_panel_app_web/views/side_bar_screen/vendors_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget _selectedScreen = const VendorsScreen();

  screenSelector(item) {
    switch (item.route) {
      case BuyersScreen.id:
        setState(() {
          _selectedScreen = const BuyersScreen();
        });
        break;

      case VendorsScreen.id:
        setState(() {
          _selectedScreen = const VendorsScreen();
        });
        break;

      case OrdersScreen.id:
        setState(() {
          _selectedScreen = const OrdersScreen();
        });
        break;

      case CategoryScreen.id:
        setState(() {
          _selectedScreen = const CategoryScreen();
        });
        break;
      case SubCategoryScreen.id:
        setState(() {
          _selectedScreen = const SubCategoryScreen();
        });
        break;
      case UploadBannerScreen.id:
        setState(() {
          _selectedScreen = const UploadBannerScreen();
        });
        break;

      case ProductsScreen.id:
        setState(() {
          _selectedScreen =  ProductsScreen();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Admin Panel"),

      ),
      body: _selectedScreen,
      sideBar: SideBar(
        header: Container(
          height: 50,
          width: double.infinity,
          decoration:const BoxDecoration(
            color: Colors.white,
          ),
          child: Center(
            child: Image.asset(AppImages.imgLogo),
          ),
        ),
        items: const [
          AdminMenuItem(
            title: "Nhà cung cấp",
            route: VendorsScreen.id,
            icon: CupertinoIcons.person_3,
          ),
          AdminMenuItem(
            title: "Người dùng",
            route: BuyersScreen.id,
            icon: CupertinoIcons.person,
          ),
          AdminMenuItem(
            title: "Đơn hàng",
            route: OrdersScreen.id,
            icon: CupertinoIcons.shopping_cart,
          ),
          AdminMenuItem(
            title: "Danh mục hàng",
            route: CategoryScreen.id,
            icon: Icons.category,
          ),
          AdminMenuItem(
            title: "Danh mục con",
            route: SubCategoryScreen.id,
            icon: Icons.category_outlined,
          ),
          AdminMenuItem(
            title: "Tải banner",
            route: UploadBannerScreen.id,
            icon: Icons.upload,
          ),
          AdminMenuItem(
            title: "Sản phẩm",
            route: ProductsScreen.id,
            icon: Icons.store,
          ),
        ],
        selectedRoute: VendorsScreen.id,
        onSelected: (item) {
          screenSelector(item);
        },
      ),
    );
  }
}
