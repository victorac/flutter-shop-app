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
  String? uid;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
    this.uid,
  });

  Future<void> toggleIsFavorite(String? uid, String? token) async {
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse(
        'https://${dotenv.env['DATABASE_AUTHORITY']}/favorites/$uid/$id.json?auth=$token');
    try {
      final response = await http.put(
        url,
        body: convert.jsonEncode(isFavorite),
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
