import 'dart:convert';

import 'package:admin_panel_app_web/models/subcategory.dart';
import 'package:admin_panel_app_web/services/manage_http_response.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;

import '../global_variable.dart';

class SubcategoryController {
  uploadSubcategory({
    required String categoryId,
    required String categoryName,
    required dynamic pickedImage,
    required String subCategoryName,
    required context,
  }) async {
    try {
      final cloudinary = CloudinaryPublic("dajwnmjjf", "tb9fytch");

      // upload image
      CloudinaryResponse imageResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(pickedImage, identifier: "pickedImage", folder: "categoryImages"),
      );
      String image = imageResponse.secureUrl;
      SubCategory subcategory = SubCategory(
        id: '',
        categoryId: categoryId,
        categoryName: categoryName,
        image: image,
        subCategoryName: subCategoryName,
      );
      http.Response response = await http.post(Uri.parse("$uri/api/subcategories"),
          body: subcategory.toJson(),
          headers: <String, String>{
            "Content-Type":'application/json; charset=UTF-8'
          }
      );
      manageHttpResponse(response: response, context: context, onSuccess: (){
        showSnackBar(context, "Upload thành công");
      });
    } catch (e) {
      print("$e");
    }
  }

  // load the uploaded category
  Future<List<SubCategory>> loadSubCategories() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/subcategories'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );


      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        if (data is! List) {
          throw Exception("Invalid API response format. Expected a List.");
        }

        List<SubCategory> subcategories = data.map((subcategory) {
          try {
            return SubCategory.fromJson(subcategory as Map<String, dynamic>);
          } catch (e) {
            throw Exception("Error parsing subcategory: ${e.toString()}");
          }
        }).toList();

        return subcategories;
      } else {
        throw Exception('Failed to load subcategories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error loading subcategories: ${e.toString()}");
      throw Exception("Error loading subcategories: ${e.toString()}");
    }
  }

}
