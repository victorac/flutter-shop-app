import 'package:flutter/material.dart';

class CartItem with ChangeNotifier {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  final Map<String, CartItem> _items = {};

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

  void addItem(String productId, String title, double price) {
    if (items.containsKey(productId)) {
      _items.update(
        productId,
        (oldCart) => CartItem(
          id: oldCart.id,
          productId: productId,
          title: title,
          quantity: oldCart.quantity + 1,
          price: price,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          productId: productId,
          title: title,
          quantity: 1,
          price: price,
        ),
      );
    }
    notifyListeners();
  }
}
