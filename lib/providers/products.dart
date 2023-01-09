import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product item(String id) {
    return _items.firstWhere(
      (element) => element.id == id,
      orElse: () => Product(
        id: '',
        title: '',
        description: '',
        price: 0,
        imageUrl: '',
      ),
    );
  }

  Product? tryItem(String id) {
    try {
      return _items.firstWhere((element) => element.id == id);
    } on StateError {
      return null;
    }
  }

  Future<void> updateItem(String id, String title, String description,
      double price, String imageUrl, bool isFavorite) async {
    final url = Uri.https(
      dotenv.env['DATABASE_AUTHORITY'] as String,
      'products/$id.jsonw',
    );
    try {
      final response = await http.put(url,
          body: convert.jsonEncode({
            'title': title,
            'description': description,
            'price': price,
            'imageUrl': imageUrl,
            'isFavorite': isFavorite,
          }));
      final Map<String, dynamic> updatedProduct =
          convert.jsonDecode(response.body);
      final productIndex = _items.indexWhere((element) => element.id == id);
      _items[productIndex] = Product(
        id: id,
        title: updatedProduct['title'],
        description: updatedProduct['description'],
        price: updatedProduct['price'],
        imageUrl: updatedProduct['imageUrl'],
        isFavorite: updatedProduct['isFavorite'],
      );
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> addItem({
    required String title,
    required String description,
    required double price,
    required String imageUrl,
  }) async {
    final url = Uri.https(
      dotenv.env['DATABASE_AUTHORITY'] as String,
      dotenv.env['DATABASE_PRODUCT_PATH'] as String,
    );
    try {
      final response = await http.post(
        url,
        body: convert.jsonEncode(
          {
            'title': title,
            'description': description,
            'price': price,
            'imageUrl': imageUrl,
            'isFavorite': false
          },
        ),
      );
      final String generatedId = convert.jsonDecode(response.body)['name'];
      _items.add(Product(
        id: generatedId,
        title: title,
        description: description,
        price: price,
        imageUrl: imageUrl,
      ));
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> getItems() async {
    try {
      final url = Uri.https(
        dotenv.env['DATABASE_AUTHORITY'] as String,
        dotenv.env['DATABASE_PRODUCT_PATH'] as String,
      );
      final response = await http.get(url);
      final Map<String, dynamic> products = convert.jsonDecode(response.body);
      final List<Product> items = [];
      products.forEach((id, product) {
        items.add(Product(
          id: id,
          title: product['title'],
          description: product['description'],
          price: product['price'],
          imageUrl: product['imageUrl'],
          isFavorite: product['isFavorite'],
        ));
      });
      _items = items;
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> getItem(String id) async {
    final url = Uri.https(
      dotenv.env['DATABASE_AUTHORITY'] as String,
      'products/$id.json',
    );
    final response = await http.get(url);
  }

  Future<void> removeItem(String id) async {
    final url = Uri.https(
      dotenv.env['DATABASE_AUTHORITY'] as String,
      'products/$id.json',
    );
    final index = _items.indexWhere((element) => element.id == id);
    Product? productRef = _items[index];
    _items.removeAt(index);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(index, productRef);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    productRef = null;
  }
}
