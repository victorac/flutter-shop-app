import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String apiKey = dotenv.env['API_KEY'] as String;

class Auth extends ChangeNotifier {
  String? _token;
  String? _expirationDate;
  String? _userId;

  String? get token {
    return _token;
  }

  String? get userId {
    return _userId;
  }

  Future<void> authenticate(
      String email, String password, String urlPath) async {
    final url = Uri.parse(urlPath);
    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = jsonDecode(response.body);
      _token = responseData['idToken'];
      final secondsToExpire = double.parse(responseData['expiresIn']).round();
      _expirationDate = DateTime.now()
          .add(Duration(seconds: secondsToExpire))
          .toIso8601String();
      _userId = responseData['localId'];
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> signup(String email, String password) async {
    return authenticate(email, password,
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey');
  }

  Future<void> signin(String email, String password) async {
    return authenticate(email, password,
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey');
  }

  bool isLoggedIn() {
    if (_expirationDate == null) return false;
    return DateTime.now().isBefore(DateTime.parse(_expirationDate as String));
  }
}
