// lib/controllers/product_controller.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../global_variable.dart';
import '../models/product.dart';

class ProductController {
  Future<List<Product>> loadProducts() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/products'),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception("Không tìm thấy sản phẩm nào!");
      } else {
        throw Exception("Lỗi khi tải sản phẩm: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Lỗi khi tải sản phẩm: ${e.toString()}");
    }
  }
}