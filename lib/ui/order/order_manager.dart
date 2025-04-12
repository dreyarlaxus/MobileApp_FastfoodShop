import 'package:flutter/material.dart';
import 'package:ct312h_project/services/order_service.dart';
import 'package:ct312h_project/models/item.dart';
import 'package:ct312h_project/models/order.dart';

class OrderManager with ChangeNotifier {
  final OrderService _orderService = OrderService();

  Future<void> createOrder({
    required String userId,
    required double totalAmount,
    required String address,
    required String description,
    required Map<Item, int> cart,
    required String phoneNumber,
  }) async {
    try {
      final order = Order(
        userId: userId,
        amount: totalAmount,
        deliveryAddress: address,
        description: description,
        items: cart,
        datetime: DateTime.now(),
        phoneNumber: phoneNumber,
      );

      await _orderService.createOrder(order);
      notifyListeners();
    } catch (error) {
      print('Error creating order: $error');
    }
  }
}
