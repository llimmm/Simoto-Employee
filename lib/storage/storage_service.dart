import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      print('StorageService initialized');
    }
  }

  Future<void> saveToken(String token) async {
    await init();
    await _prefs.setString(tokenKey, token);
    await _prefs.setBool(isLoggedInKey, true);
    print('Token saved: ${token.substring(0, min(token.length, 10))}...');
  }

  Future<bool> isLoggedIn() async {
    await init();
    return _prefs.getBool(isLoggedInKey) ?? false;
  }

  Future<String?> getToken() async {
    await init();
    final token = _prefs.getString(tokenKey);
    if (token != null) {
      print('Retrieved token: ${token.substring(0, min(token.length, 10))}...');
    } else {
      print('No token found in storage');
    }
    return token;
  }

  Future<void> clearLoginData() async {
    await init();
    await _prefs.remove(tokenKey);
    await _prefs.remove(userDataKey);
    await _prefs.setBool(isLoggedInKey, false);
    print('Login data cleared');
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await init();
    final jsonData = json.encode(userData);
    await _prefs.setString(userDataKey, jsonData);
    print('User data saved: $userData');
  }
  
  Future<Map<String, dynamic>?> getUserData() async {
    await init();
    final String? userDataString = _prefs.getString(userDataKey);
    if (userDataString != null) {
      try {
        final data = json.decode(userDataString) as Map<String, dynamic>;
        print('Retrieved user data: $data');
        return data;
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    } else {
      print('No user data found in storage');
      return null;
    }
  }
  
  // Helper to limit string length for logging
  int min(int a, int b) {
    return a < b ? a : b;
  }
}