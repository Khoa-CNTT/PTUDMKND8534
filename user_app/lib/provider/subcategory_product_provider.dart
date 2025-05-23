import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_store/controller/product_controller.dart';
import 'package:multi_store/data/model/product.dart';

class SubcategoryProductNotifier extends FamilyAsyncNotifier<List<Product>, String> {
  static final Map<String, List<Product>> _cache = {};

  @override
  Future<List<Product>> build(String subCategoryName) async {
    if (_cache.containsKey(subCategoryName)) {
      return _cache[subCategoryName]!;
    }

    final controller = ProductController();
    final products = await controller.loadProductBySubCategory(subCategoryName);

    _cache[subCategoryName] = products;
    return products;
  }

  Future<void> refresh() async {
    _cache.remove(arg);

    state = const AsyncValue.loading();

    try {
      final products = await build(arg);
      state = AsyncValue.data(products);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final subcategoryProductProvider =
AsyncNotifierProvider.family<SubcategoryProductNotifier, List<Product>, String>(
  SubcategoryProductNotifier.new,
);