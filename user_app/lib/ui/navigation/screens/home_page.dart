import 'package:flutter/material.dart';
import 'package:multi_store/common/base/widgets/common/custom_search.dart';
import 'package:multi_store/common/base/widgets/common/reusable_text_widget.dart';
import 'package:multi_store/common/base/widgets/details/products/all_product_page.dart';
import 'package:multi_store/common/base/widgets/details/products/all_product_widget.dart';
import 'package:multi_store/common/base/widgets/details/products/popular_product_page.dart';
import 'package:multi_store/common/base/widgets/details/products/popular_product_widget.dart';
import 'package:multi_store/common/base/widgets/details/products/top_rated_product_page.dart';

import '../../../common/base/widgets/details/banner/banner_widget.dart';
import '../../../common/base/widgets/common/hearder_widget.dart';
import '../../../common/base/widgets/details/category/category_item_widget.dart';
import '../../../common/base/widgets/details/products/top_rated_widget.dart';
import '../../../resource/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white40,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.20),
        child: const HeaderWidget(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            const BannerWidget(),
            const SizedBox(height: 5),
            const CategoryItemWidget(),
            const SizedBox(height: 5),

            ReusableTextWidget(
              title: "Tất cả sản phẩm",
              actionText: "Xem tất cả",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return const AllProductPage();
                }));
              },
            ),
            const SizedBox(height: 5),
          const  AllProductWidget(),
            const SizedBox(height: 5),

            ReusableTextWidget(
              title: "Top sản phẩm",
              actionText: "Xem tất cả",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return const TopRatedProductPage();
                }));
              },
            ),
            const SizedBox(height: 5),
            const TopRatedWidget(),
            const SizedBox(height: 5),
            ReusableTextWidget(
              title: "Phổ biến",
              actionText: "Xem tất cả",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return const PopularProductPage();
                }));
              },
            ),
            const SizedBox(height: 5),
            const PopularProductWidget(),

          ],
        ),
      ),
    );
  }
}
