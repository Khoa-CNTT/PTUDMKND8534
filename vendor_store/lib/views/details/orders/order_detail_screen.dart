import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vendor_store/controllers/order_controller.dart';

import '../../../common/widgets/confirm_dialog.dart';
import '../../../models/order.dart';
import '../../../provider/order_provider.dart';
import '../../../resource/theme/app_colors.dart';
import '../../../resource/theme/app_styles.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  final OrderController orderController = OrderController();

  String formatCurrency(double price) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
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
    final orders = ref.watch(orderProvider);
    final orderTotal = ref.watch(orderProvider.notifier).calculateItemTotal(order);

    final updatedOrders =   orders.firstWhere((o) => o.id == widget.order.id, orElse: () => widget.order);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.order.productName,
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
                            widget.order.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.order.productName,
                              style: AppStyles.STYLE_14_BOLD.copyWith(color: AppColors.blackFont),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.order.category,
                              style: AppStyles.STYLE_12.copyWith(color: AppColors.blackFont),
                            ),
                            const SizedBox(height: 4),
                            Text("Số lượng: ${widget.order.quantity.toString()}"),
                            Text(
                              formatCurrency(widget.order.productPrice.toDouble()),
                              style: AppStyles.STYLE_14_BOLD.copyWith(color: AppColors.bluePrimary),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: updatedOrders.delivered == true
                                    ? AppColors.bluePrimary
                                    : updatedOrders .processing == true
                                        ? AppColors.cinder500
                                        : AppColors.gold600,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                updatedOrders.delivered == true
                                    ? "Đã giao hàng"
                                    : updatedOrders.processing == true
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
                    _showDeleteConfirmationDialog(context, widget.order.id);
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Container(
              width: 336,
              height: 180,
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Địa chỉ giao hàng",
                          style: AppStyles.STYLE_16_BOLD.copyWith(color: AppColors.blackFont),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          " ${widget.order.address}",
                          style: AppStyles.STYLE_14.copyWith(color: AppColors.blackFont),
                        ),
                        Text(
                          "Từ: ${widget.order.fullName}",
                          style: AppStyles.STYLE_14_BOLD.copyWith(color: AppColors.blackFont),
                        ),
                        Text(
                          "Mã đơn: ${widget.order.id}",
                          style: AppStyles.STYLE_12_BOLD.copyWith(color: AppColors.blackFont),
                        ),
                        Row(
                          children: [
                            Text(
                              "Tổng tiền: ",
                              style: AppStyles.STYLE_14_BOLD.copyWith(color: AppColors.blackFont),
                            ),
                            Text(
                              formatCurrency(orderTotal),
                              style: AppStyles.STYLE_16_BOLD.copyWith(color: AppColors.bluePrimary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: (updatedOrders.delivered == true || updatedOrders.processing == false) ? null : () async {
                          await orderController.updateOrderStatus(id: widget.order.id, context: context)
                              .then((_) {
                            ref.read(orderProvider.notifier).updateOrderStatus(widget.order.id, delivered: true);
                          });
                        },
                        child: Text(
                          (updatedOrders.delivered == true || updatedOrders.processing == false) ? "Đã giao hàng" : "Xác nhận giao hàng",
                          style: AppStyles.STYLE_14_BOLD.copyWith(
                            color: (updatedOrders.delivered == true || updatedOrders.processing == false) ? Colors.grey : AppColors.blackFont,
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: updatedOrders.processing == false|| updatedOrders.delivered==true ? null : () async {
                          await orderController.cancelOrder(id: widget.order.id, context: context)
                              .then((_) {
                            ref.read(orderProvider.notifier).updateOrderStatus(widget.order.id, processing: false);
                          });
                        },
                        child: Text(
                          updatedOrders.processing == false ? "Đã hủy" : "Hủy",
                          style: AppStyles.STYLE_14_BOLD.copyWith(
                            color: updatedOrders.processing == false ? Colors.grey : AppColors.pink,
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
