import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/http_exception.dart';

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

  Future<void> addOrder(Cart cart) async {
    final url =
        Uri.https(dotenv.env['DATABASE_AUTHORITY'] as String, '/orders.json');
    try {
      final datetime = DateTime.now();
      final response = await http.post(url,
          body: convert.jsonEncode({
            'amount': cart.total,
            'products': cart.items.values.toList(),
            'datetime': datetime.toString(),
          }));
      final String id = convert.jsonDecode(response.body)['name'];
      _orders.add(OrderItem(
        id: id,
        amount: cart.total,
        products: cart.items.values.toList(),
        dateTime: datetime,
      ));
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }
}
