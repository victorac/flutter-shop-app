import 'package:flutter/material.dart';

class CartItem {
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

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void removeSingleItem(String id) {
    if (_items.containsKey(id)) {
      _items.update(
          id,
          (cartItem) => CartItem(
                id: cartItem.id,
                productId: cartItem.productId,
                title: cartItem.title,
                quantity: cartItem.quantity - 1,
                price: cartItem.price,
              ));
      int itemQuantity = _items[id]?.quantity ?? 0;
      if (itemQuantity < 1) {
        print("reached zero");
        _items.remove(id);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
