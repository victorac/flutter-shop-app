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
  String? uid;
  String? token;
  List<OrderItem> _orders;

  Orders([this.uid, this.token, orders]) : _orders = orders ?? [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(Cart cart) async {
    final url = Uri.parse(
        'https://${dotenv.env['DATABASE_AUTHORITY']}/users/$uid/orders.json?auth=$token');
    try {
      final timestamp = DateTime.now();
      final response = await http.post(url,
          body: convert.jsonEncode({
            'amount': cart.total,
            'products': cart.items.values.toList(),
            'datetime': timestamp.toIso8601String(),
          }));
      final String id = convert.jsonDecode(response.body)['name'];
      _orders.add(OrderItem(
        id: id,
        amount: cart.total,
        products: cart.items.values.toList(),
        dateTime: timestamp,
      ));
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> listOrders() async {
    print("$uid");
    final url = Uri.parse(
        'https://${dotenv.env['DATABASE_AUTHORITY']}/users/$uid/orders.json?auth=$token');
    try {
      final response = await http.get(url);
      final Map<String, dynamic>? orders = convert.jsonDecode(response.body);
      if (orders == null) {
        _orders = [];
        return;
      }
      List<OrderItem> loadedItems = [];
      orders.forEach((key, item) {
        loadedItems.add(
          OrderItem(
            id: key,
            amount: item['amount'],
            products: (item['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    productId: item['productId'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ),
                )
                .toList(),
            dateTime: DateTime.parse(item['datetime']),
          ),
        );
      });
      _orders = loadedItems.reversed.toList();
      notifyListeners();
    } catch (error) {
      // print(error);
      rethrow;
    }
  }
}
