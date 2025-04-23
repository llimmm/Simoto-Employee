import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(tokenKey, token);
    await _prefs.setBool(isLoggedInKey, true);
  }

  Future<bool> isLoggedIn() async {
    return _prefs.getBool(isLoggedInKey) ?? false;
  }

  Future<String?> getToken() async {
    return _prefs.getString(tokenKey);
  }

  Future<void> clearLoginData() async {
    await _prefs.remove(tokenKey);
    await _prefs.remove(userDataKey);
    await _prefs.setBool(isLoggedInKey, false);
  }

  saveUserData(Map<String, dynamic> userData) {}
}
