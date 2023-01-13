import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  Products([this.uid, this.token, previousItems])
      : _items = previousItems ?? [];

  String? uid;
  String? token;
  List<Product> _items;
  Map<String, dynamic>? _favorites;

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
    final url = Uri.parse(
        'https://${dotenv.env['DATABASE_AUTHORITY']}/users/$uid/products/$id.json?auth=$token');
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
    final url = Uri.parse(
        'https://${dotenv.env['DATABASE_AUTHORITY']}/products/$uid.json?auth=$token');
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

  Future<void> getFavorites() async {
    final url = Uri.parse(
        'https://${dotenv.env['DATABASE_AUTHORITY']}/favorites/$uid.json?auth=$token');
    try {
      final response = await http.get(url);
      final Map<String, dynamic>? responseBody =
          convert.jsonDecode(response.body);
      if (response.statusCode >= 400) {
        throw HttpException('Couldn\'t fetch favorite data $responseBody');
      }
      _favorites = responseBody;
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> getUserItems() async {
    try {
      final url = Uri.parse(
          'https://${dotenv.env['DATABASE_AUTHORITY']}/products/$uid.json?auth=$token');
      final response = await http.get(url);
      final Map<String, dynamic>? responseBody =
          convert.jsonDecode(response.body);
      if (response.statusCode >= 400) {
        throw HttpException('Couldn\'t fetch data $responseBody');
      }
      final Map<String, dynamic>? products = responseBody;
      if (products == null) {
        _items = [];
        notifyListeners();
        return;
      }
      // favorite data
      await getFavorites();
      final List<Product> items = [];
      products.forEach(
        (productId, product) => items.add(
          Product(
            id: productId,
            title: product['title'],
            description: product['description'],
            price: product['price'],
            imageUrl: product['imageUrl'],
            isFavorite: _favorites?[productId] ?? false,
          ),
        ),
      );
      _items = items;
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> getItems() async {
    try {
      final url = Uri.parse(
          'https://${dotenv.env['DATABASE_AUTHORITY']}/products.json?auth=$token');
      final response = await http.get(url);
      final Map<String, dynamic>? responseBody =
          convert.jsonDecode(response.body);
      if (response.statusCode >= 400) {
        throw HttpException('Couldn\'t fetch data $responseBody');
      }
      final Map<String, dynamic>? usersProductData = responseBody;
      if (usersProductData == null) {
        _items = [];
        notifyListeners();
        return;
      }
      // favorite data
      await getFavorites();
      final List<Product> items = [];
      usersProductData.forEach(
        (ithUid, productMap) => (productMap as Map<String, dynamic>).forEach(
          (productId, product) => items.add(
            Product(
              id: productId,
              title: product['title'],
              description: product['description'],
              price: product['price'],
              imageUrl: product['imageUrl'],
              isFavorite: _favorites?[productId] ?? false,
            ),
          ),
        ),
      );
      _items = items;
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> removeItem(String id) async {
    final index = _items.indexWhere((element) => element.id == id);
    Product? productRef = _items[index];
    _items.removeAt(index);
    notifyListeners();
    final url = Uri.parse(
        'https://${dotenv.env['DATABASE_AUTHORITY']}/products/$uid/$id.json?auth=$token');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(index, productRef);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    productRef = null;
  }
}
