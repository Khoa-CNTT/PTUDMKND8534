import 'dart:convert';

import 'package:admin_panel_app_web/global_variable.dart';
import 'package:admin_panel_app_web/models/buyer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/manage_http_response.dart';

class BuyerController {
  Future<List<Buyer>> loadBuyer() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/user'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        List<Buyer> buyers = data.map((buyer) {
          return Buyer.fromMap(buyer);
        }).toList();

        return buyers;
      } else {
        throw Exception(
            'Failed to load Buyer. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Error loading Buyers: ${e.toString()}");
    }
  }

  Future<void> deleteBuyer({required String buyerId, required BuildContext context}) async {
    debugPrint('BuyerController: Starting deleteBuyer for ID: $buyerId');
    try {
      final response = await http.delete(
        Uri.parse('$uri/api/user/delete$buyerId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          if (context.mounted) {
            showSnackBar(context, 'Xóa tài khoản thành công');
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Lỗi khi xóa tài khoản: $e');
      }
    }
  }
}
