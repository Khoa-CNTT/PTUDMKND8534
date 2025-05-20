import 'dart:convert';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_store/provider/vendor_product_provider.dart';
import '../global_variables.dart';
import '../provider/vendor_provider.dart';
import '../services/manage_http_response.dart';
import '../views/screens/authentication/login_page.dart';
import '../views/screens/authentication/main_vendor_page.dart';

class VendorAuthController {
  // ✅ Đăng ký Vendor
  Future<void>  signUpVendor({
    required BuildContext context,
    required String email,
    required String phone,
    required String fullName,
    required String password,
    String image = '',
    String address = '',
  }) async {
    try {
      final requestBody = jsonEncode({
        "email": email,
        "phone": phone,
        "fullName": fullName,
        "password": password,
        "image": image,
        "address": address,
      });

      final response = await http.post(
        Uri.parse('$uri/api/v2/vendor/signup'),
        body: requestBody,
        headers: {"Content-Type": 'application/json; charset=UTF-8'},
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
          showSnackBar(context, "Đăng ký thành công");
        },
      );
    } catch (e) {
      showSnackBar(context, "Lỗi khi đăng ký: $e");
    }
  }

  // ✅ Đăng nhập Vendor
  Future<void> signInVendor({
    required BuildContext context,
    required String loginInput,
    required String password,
    required WidgetRef ref,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$uri/api/v2/vendor/signin"),
        body: jsonEncode({"loginInput": loginInput, "password": password}),
        headers: {"Content-Type": 'application/json; charset=UTF-8'},
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          final prefs = await SharedPreferences.getInstance();

          String token = jsonDecode(response.body)['token'];

          await prefs.setString('auth_token', token);

          final userJson = jsonEncode(jsonDecode(response.body));

          ref.read(vendorProvider.notifier).setVendor(response.body);
          ref.read(vendorProductProvider.notifier).clearProducts();

          await prefs.setString('user', userJson);

          if (ref.read(vendorProvider)?.token.isNotEmpty == true) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainVendorPage()),
              (route) => false,
            );
            showSnackBar(context, "Đăng nhập thành công");
          }
        },
      );
    } catch (e) {
      showSnackBar(context, "Lỗi khi đăng nhập: $e");
    }
  }

  getUserData(context, WidgetRef ref) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      String? token = preferences.getString('auth_token');

      if (token == null) {
        preferences.setString('auth_token', '');
      }

      var tokenResponse = await http.post(
        Uri.parse('$uri/api/vendor-tokenIsValid'),
        headers: {
          "Content-Type": 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );
      var response = jsonDecode(tokenResponse.body);
      if (response == true) {
        http.Response userResponse = await http.get(
          Uri.parse('$uri/get-vendor'),
          headers: {
            "Content-Type": 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );
        ref.read(vendorProvider.notifier).setVendor(userResponse.body);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // ✅ Đăng xuất Vendor
  Future<void> signOutVendor({required BuildContext context}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('vendor');
      await prefs.remove('vendorId');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );

      showSnackBar(context, "Đăng xuất thành công");
    } catch (e) {
      showSnackBar(context, "Lỗi khi đăng xuất");
    }
  }

  // ✅ 5. Cập nhật data vendor
  Future<void> updateVendorData({
    required BuildContext context,
    required String id,
    required File? storeImage,
    required String storeDescription,
    required WidgetRef ref,
  }) async {
    try {
      final cloudinary = CloudinaryPublic("dajwnmjjf", "tb9fytch");
      CloudinaryResponse imageResponse = await cloudinary
          .uploadFile(CloudinaryFile.fromFile(storeImage!.path, identifier: "pickedImage", folder: "storeImage"));
      String image = imageResponse.secureUrl;

      final response = await http.put(
        Uri.parse('$uri/api/vendor/update/$id'),
        headers: {"Content-Type": 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'storeImage': image,
          'storeDescription': storeDescription,
        }),
      );

      if (!context.mounted) return;

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          final updatedUser = jsonDecode(response.body);
          final userJson = jsonEncode(updatedUser);
          ref.read(vendorProvider.notifier).setVendor(userJson);
          showSnackBar(context, "Cập nhật thành công");
        },
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, "Lỗi cập nhật data: $e");
      }
    }
  }
}
