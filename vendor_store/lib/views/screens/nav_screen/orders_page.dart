import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vendor_store/provider/vendor_provider.dart';
import '../../../common/widgets/confirm_dialog.dart';
import '../../../controllers/order_controller.dart';
import '../../../provider/order_provider.dart';
import '../../../resource/theme/app_colors.dart';
import '../../../resource/theme/app_styles.dart';
import '../../details/orders/order_detail_screen.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final user = ref.read(vendorProvider);
    if (user != null) {
      final OrderController orderController = OrderController();
      try {
        final orders = await orderController.loadOrders(vendorId: user.id);
        ref.read(orderProvider.notifier).setOrders(orders);
      } catch (e) {
        print("Lỗi đơn hàng: $e");
      }
    }
  }

  String formatCurrency(int price) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(price);
  }

  Future<void> _deleteOrder(String orderId) async {
    final OrderController orderController = OrderController();
    try {
      await orderController.deleteOrder(id: orderId, context: context);
      _fetchOrders();
    } catch (e) {
      print("Xóa không thành công: $e");
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        content: "Bạn có chắc muốn xóa đơn hàng này?",
        onConfirm: () {
          _deleteOrder(orderId);
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Đơn hàng",
          style: AppStyles.STYLE_18_BOLD.copyWith(color: AppColors.blackFont),
        ),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? const Center(child: Text("Không có đơn hàng"))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return OrderDetailScreen(order: order);
                }));
              },
              child: Stack(
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
                                Text(
                                  order.productName,
                                  style: AppStyles.STYLE_14_BOLD.copyWith(color: AppColors.blackFont),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order.category,
                                  style: AppStyles.STYLE_12.copyWith(color: AppColors.blackFont),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatCurrency(order.productPrice),
                                  style: AppStyles.STYLE_14_BOLD.copyWith(color: AppColors.blackFont),
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
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Chỉ hiển thị nút Delete nếu đơn hàng chưa được giao (order.delivered == false)
                  if (!order.delivered)
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
            ),
          );
        },
      ),
    );
  }
}