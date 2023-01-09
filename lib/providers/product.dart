import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleIsFavorite() async {
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.https(
      dotenv.env['DATABASE_AUTHORITY'] as String,
      'products/$id.json',
    );
    try {
      final response = await http.patch(
        url,
        body: convert.jsonEncode(
          {
            'isFavorite': isFavorite,
          },
        ),
      );
      if (response.statusCode >= 400) {
        throw PatchFavoriteItemException();
      }
    } catch (error) {
      isFavorite = !isFavorite;
      notifyListeners();
      print(error);
      rethrow;
    }
  }
}
