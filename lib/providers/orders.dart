import 'package:flutter/material.dart';

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  void addOrder(Cart cart) {
    _orders.add(OrderItem(
      id: DateTime.now().toString(),
      amount: cart.total,
      products: cart.items.values.toList(),
      dateTime: DateTime.now(),
    ));
    notifyListeners();
  }
}
