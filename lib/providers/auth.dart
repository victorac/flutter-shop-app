import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shop_app/models/http_exception.dart';

final String apiKey = dotenv.env['API_KEY'] as String;

class Auth extends ChangeNotifier {
  String? _token;
  DateTime? _expirationDate;
  String? _userId;
  Timer? _timer;

  String? get token {
    if (_token != null &&
        _expirationDate != null &&
        _expirationDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  bool get isLoggedIn {
    return token != null;
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
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      final secondsToExpire = double.parse(responseData['expiresIn']).round();
      _expirationDate = DateTime.now().add(Duration(seconds: secondsToExpire));
      _userId = responseData['localId'];
      notifyListeners();
      _autoLogout();
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

  void logout() {
    _token = null;
    _userId = null;
    _expirationDate = null;
    notifyListeners();
  }

  void _autoLogout() {
    _timer?.cancel();
    if (_expirationDate != null) {
      final duration = _expirationDate!.difference(DateTime.now());
      _timer = Timer(duration, logout);
    }
  }
}
