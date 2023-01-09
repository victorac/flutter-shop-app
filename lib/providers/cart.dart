import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/http_exception.dart';

class CartItem {
  final String productId;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.productId,
    required this.title,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'title': title,
        'quantity': quantity,
        'price': price,
      };
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get productCount {
    return items.values.length;
  }

  int get itemCount {
    return items.values.fold(0, (value, element) => value + element.quantity);
  }

  double get total {
    return items.values.fold(
      0,
      (previousValue, element) =>
          previousValue + element.quantity * element.price,
    );
  }

  Future<void> updateItem(String productId, String title, double price,
      {int value = 1}) async {
    final url = Uri.https(
        dotenv.env['DATABASE_AUTHORITY'] as String, '/cart/$productId.json');
    CartItem? cartItemRef = _items[productId];
    _items.update(
      productId,
      (oldCart) => CartItem(
        productId: productId,
        title: title,
        quantity: oldCart.quantity + value,
        price: price,
      ),
    );
    notifyListeners();
    final response = await http.patch(url,
        body: convert.jsonEncode({'quantity': cartItemRef!.quantity + value}));
    if (response.statusCode >= 400) {
      _items[productId] = cartItemRef;
      notifyListeners();
      throw HttpException('Failed to update cart');
    }
    cartItemRef = null;
  }

  Future<void> addItem(String productId, String title, double price) async {
    final url = Uri.https(
        dotenv.env['DATABASE_AUTHORITY'] as String, '/cart/$productId.json');
    try {
      await http.put(url,
          body: convert.jsonEncode({
            'productId': productId,
            'title': title,
            'quantity': 1,
            'price': price,
          }));
      _items.putIfAbsent(
        productId,
        () => CartItem(
          productId: productId,
          title: title,
          quantity: 1,
          price: price,
        ),
      );
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> removeItem(String id) async {
    CartItem? cartItemRef = _items[id];
    _items.remove(id);
    notifyListeners();
    final url =
        Uri.https(dotenv.env['DATABASE_AUTHORITY'] as String, '/cart/$id.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items[id] = cartItemRef as CartItem;
      notifyListeners();
      cartItemRef = null;
      throw HttpException('Failed while removing item from cart');
    }
    cartItemRef = null;
  }

  Future<void> removeSingleItem(String id) async {
    if (_items.containsKey(id)) {
      if (_items[id]!.quantity > 1) {
        await updateItem(
          id,
          _items[id]!.title,
          _items[id]!.price,
          value: -1,
        );
      } else {
        await removeItem(id);
      }
    }
  }

  Future<void> clear() async {
    Map<String, CartItem>? itemsRef = _items;
    _items = {};
    notifyListeners();
    final url =
        Uri.https(dotenv.env['DATABASE_AUTHORITY'] as String, '/cart.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items = itemsRef;
      itemsRef = null;
      notifyListeners();
      throw HttpException('Failed clearing cart');
    }
    itemsRef = null;
  }
}
