import 'dart:convert';

import 'package:admin_panel_app_web/global_variable.dart';
import 'package:admin_panel_app_web/models/category.dart';
import 'package:admin_panel_app_web/services/manage_http_response.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoryController {
  uploadCategory(
      {required dynamic pickedImage,
      required dynamic pickedBanner,
      required String name, required context}) async {
    try {
      final cloudinary = CloudinaryPublic("dajwnmjjf", "tb9fytch");

      // upload image
      CloudinaryResponse imageResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(pickedImage,
            identifier: "pickedImage", folder: "categoryImages"),
      );
      String image = imageResponse.secureUrl;

      CloudinaryResponse bannerResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(pickedBanner,
            identifier: "pickedBanner", folder: "categoryImages"),
      );
      String banner = bannerResponse.secureUrl;

      Category category = Category(
        id: "",
        name: name,
        image: image,
        banner: banner,
      );
      http.Response response = await http.post(Uri.parse("$uri/api/categories"),
      body: category.toJson(),
      headers: <String, String>{
        "Content-Type":'application/json; charset=UTF-8'
      }
      );
      manageHttpResponse(response: response, context: context, onSuccess: (){
        showSnackBar(context, 'Tải thành công');
      });
    } catch (e) {
      print("Lỗi  tải lên cloudinary:$e");
    }
  }
     // load the uploaded category
 Future<List<Category>> loadCategories() async {
  try {
    http.Response response = await http.get(
      Uri.parse('$uri/api/categories'),
      headers: <String, String>{
        "Content-Type": 'application/json; charset=UTF-8'
      },
    );

    print("API Response: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      List<Category> categories = data.map((category) =>
          Category.fromJson(category as Map<String, dynamic>)).toList();

      return categories;
    } else {
      throw Exception('Không tải được danh mục.. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception("Lỗi tải danh mục: ${e.toString()}");
  }
}

// Xóa danh mục
  Future<void> deleteCategory({required String categoryId, required BuildContext context}) async {
    try {
      final response = await http.delete(
        Uri.parse('$uri/api/categories/$categoryId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          if (context.mounted) {
            showSnackBar(context, 'Danh mục đã được xóa');
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Lỗi khi xóa danh mục: $e');
      }
    }
  }
}
