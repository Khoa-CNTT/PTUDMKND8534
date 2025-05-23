import 'dart:convert';

import 'package:admin_panel_app_web/global_variable.dart';
import 'package:admin_panel_app_web/models/banner.dart';
import 'package:admin_panel_app_web/services/manage_http_response.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BannerController {
  uploadBanner({required dynamic pickImage, required context}) async {
    try {
      final cloudinary = CloudinaryPublic("dajwnmjjf", "tb9fytch");
      CloudinaryResponse imageResponse = await cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(pickImage,
              identifier: "pickedImage", folder: "banners"));
      String image = imageResponse.secureUrl;

      BannerModel bannerModel = BannerModel(id: "", image: image);

      http.Response response = await http.post(
        Uri.parse("$uri/api/banner"),
        body: bannerModel.toJson(),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );
      manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, "Upload thành công");
          });
    } catch (e) {
      print(e);
    }
  }

  // fetch banners
  Future<List<BannerModel>> loadBanners() async {
  try {
    http.Response response = await http.get(
      Uri.parse('$uri/api/banner'),
      headers: <String, String>{
        "Content-Type": 'application/json; charset=UTF-8'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      List<BannerModel> banners = data.map((banner) {
        return BannerModel.fromJson(banner); // Không cần decode nữa
      }).toList();

      return banners;
    } else {
      throw Exception('Failed to load banners. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception("Error loading banners: ${e.toString()}");
  }
}

// Delete banner
  Future<void> deleteBanner({required String bannerId, required BuildContext context}) async {
    try {
      http.Response response = await http.delete(
        Uri.parse('$uri/api/banner/$bannerId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Banner đã được xóa");
        },
      );
    } catch (e) {
      showSnackBar(context, "Lỗi khi xóa banner: $e");
    }
  }
}
