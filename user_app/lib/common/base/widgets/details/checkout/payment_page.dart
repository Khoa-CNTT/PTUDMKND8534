import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:multi_store/common/base/widgets/common/custom_app_bar.dart';
import 'package:multi_store/resource/theme/app_style.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:http/http.dart' as http;

import '../../../../../resource/theme/app_colors.dart';

class PaymentPage extends StatefulWidget {
  final double amount;

  const PaymentPage({super.key, required this.amount});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _getUrlPayment();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.contains('/vnpay_return')) {
              _checkStatusPayment(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  Future<void> _getUrlPayment() async {
    http.Response response = await http.post(
        Uri.parse('https://backend-vnpay-a8aa14777084.herokuapp.com/order/create_payment_url'),
        body: {'amount': widget.amount.toInt().toString(), 'bankCode': '', 'language': 'vn'});

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      final url = data['Url'];
      _controller.loadRequest(Uri.parse(url));
    }
  }

  Future<void> _checkStatusPayment(String url) async {
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      Navigator.pop(context, data['code'] == '00');

      // final dynamic data = jsonDecode(response.body);
      // final url = data['Url'];
      // _controller.loadRequest(Uri.parse(url));
    } else {
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thanh toán",
          style: AppStyles.STYLE_18_BOLD.copyWith(color: AppColors.blackFont),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}