import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_store/data/model/order.model.dart';

class OrderProvider extends StateNotifier<List<Order>> {
  OrderProvider() : super([]);

  void setOrders(List<Order> orders) {
    state = orders;
  }

  // Hàm tính tổng tiền của một mặt hàng (Order)
  double calculateItemTotal(Order order) {
    return order.quantity.toDouble() * order.productPrice;
  }
}

final orderProvider = StateNotifierProvider<OrderProvider, List<Order>>(
      (ref) => OrderProvider(),
);