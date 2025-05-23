import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:multi_store/controller/product_review_controller.dart';
import 'package:multi_store/data/model/order.model.dart';
import 'package:multi_store/resource/theme/app_colors.dart';
import 'package:multi_store/resource/theme/app_style.dart';

import '../../../../../provider/cart_provider.dart';
import '../../../../../provider/order_provider.dart';
import '../../common/confirm_dialog.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  final ProductReviewController _productReviewController = ProductReviewController();
  final TextEditingController _reviewController = TextEditingController();
  double rating = 0.0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String formatCurrency(double price) {
    final format = NumberFormat.currency(symbol: 'đ', locale: 'vi_VN');
    return format.format(price);
  }

  void _showDeleteConfirmationDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        content: "Bạn có chắc muốn xóa đơn hàng này?",
        onConfirm: () {
          print("Xoá đơn hàng ID: $orderId");
          Navigator.of(context).pop();
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final orderTotal = ref.watch(orderProvider.notifier).calculateItemTotal(order);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          order.productName,
          style: AppStyles.STYLE_14_BOLD.copyWith(color: AppColors.blackFont),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.white),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: AppColors.gold50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            order.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.productName, style: AppStyles.STYLE_14_BOLD),
                            const SizedBox(height: 4),
                            Text(order.category, style: AppStyles.STYLE_12),
                            const SizedBox(height: 4),
                            Text(
                              "Số lượng ${order.quantity.toString()}",
                              style: AppStyles.STYLE_14.copyWith(color: AppColors.blackFont),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatCurrency(order.productPrice.toDouble()),
                              style: AppStyles.STYLE_14_BOLD.copyWith(color: AppColors.bluePrimary),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: order.delivered
                                    ? AppColors.bluePrimary
                                    : order.processing
                                        ? AppColors.cinder500
                                        : AppColors.gold600,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.delivered
                                    ? "Đã giao hàng"
                                    : order.processing
                                        ? "Đang xử lý"
                                        : "Đã hủy",
                                style: AppStyles.STYLE_12_BOLD.copyWith(color: AppColors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 80,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.pink),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, order.id);
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Container(
              width: 336,
              height: order.delivered ? 180 : 180,
              decoration: BoxDecoration(
                color: AppColors.white40,
                border: Border.all(color: AppColors.white),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text("Địa chỉ: ", style: AppStyles.STYLE_16),
                            Text(
                              order.address,
                              style: AppStyles.STYLE_16_BOLD.copyWith(color: AppColors.blackFont),
                            ),
                          ],
                        ),
                        Text(
                          "Số lượng: ${order.quantity.toString()}",
                          style: AppStyles.STYLE_16.copyWith(color: AppColors.blackFont),
                        ),
                        Text("Từ: ${order.fullName}", style: AppStyles.STYLE_16),
                        Text("Mã đơn: ${order.id}", style: AppStyles.STYLE_16),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                        const    Text("Tổng thanh toán: ", style: AppStyles.STYLE_16),
                            Text(
                              formatCurrency(orderTotal),
                              style: AppStyles.STYLE_16_BOLD.copyWith(color: AppColors.bluePrimary),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  order.delivered
                      ? ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Để lại đánh giá"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        decoration: const InputDecoration(labelText: "Đánh giá của bạn"),
                                        controller: _reviewController,
                                      ),
                                      RatingBar(
                                        filledIcon: Icons.star,
                                        emptyIcon: Icons.star_border,
                                        onRatingChanged: (value) {
                                          rating = value;
                                        },
                                        initialRating: 0,
                                        maxRating: 5,
                                      )
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        final review = _reviewController.text;

                                        _productReviewController.uploadReview(
                                          buyerId: order.buyerId,
                                          fullName: order.fullName,
                                          email: order.email,
                                          productId: order.id,
                                          rating: rating,
                                          review: review,
                                          context: context,
                                        );
                                      },
                                      child: const Text("Gửi đánh giá"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text("Đánh giá"),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
