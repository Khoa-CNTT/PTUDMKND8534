import 'package:flutter/material.dart';
import 'package:multi_store/common/base/widgets/details/products/product_item_widget.dart';
import '../../../../../controller/product_controller.dart';
import '../../../../../data/model/product.dart';
import '../../../../../resource/theme/app_colors.dart';

class SearchProductScreen extends StatefulWidget {
  const SearchProductScreen({super.key});

  @override
  State<SearchProductScreen> createState() => _SearchProductScreenState();
}

class _SearchProductScreenState extends State<SearchProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductController _productController = ProductController();
  List<Product> _searchedProducts = [];
  bool _isLoading = false;

  void _searchProducts() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _productController.searchProducts(query);
      setState(() {
        _searchedProducts = products;
      });
    } catch (e) {
      print("Lỗi khi tìm kiếm: $e");
      setState(() {
        _searchedProducts = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 4;
    final childAspectRatio = screenWidth < 600 ? 2 / 4 : 4 / 5;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: _buildSearchField(),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _searchedProducts.isEmpty
            ? const Center(
          child: Text(
            "Không tìm thấy sản phẩm",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        )
            : GridView.builder(
          itemCount: _searchedProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final product = _searchedProducts[index];
            return ProductItemWidget(product: product);
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onSubmitted: (_) => _searchProducts(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Tìm kiếm sản phẩm...',
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        filled: true,
        fillColor: AppColors.white,
        suffixIcon: IconButton(
          onPressed: _searchProducts,
          icon: const Icon(Icons.search, color: Colors.blueAccent),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder:OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.bluePrimary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
