import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      _autoLogout();
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        'token': _token,
        'userId': _userId,
        'expirationDate': _expirationDate?.toIso8601String(),
      });
      await prefs.setString('userData', userData);
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

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('userData');
    if (dataString == null) {
      return;
    }
    final Map<String, dynamic> userData = jsonDecode(dataString);
    final storedExpirationDate = DateTime.parse(userData['expirationDate']);
    final storedToken = userData['token'];
    final storedUserId = userData['userId'];
    if (storedExpirationDate.isBefore(DateTime.now())) {
      return;
    }
    _token = storedToken;
    _userId = storedUserId;
    _expirationDate = storedExpirationDate;
    _autoLogout();
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expirationDate = null;
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    _timer?.cancel();
    if (_expirationDate != null) {
      final duration = _expirationDate!.difference(DateTime.now());
      _timer = Timer(duration, logout);
    }
  }
}
