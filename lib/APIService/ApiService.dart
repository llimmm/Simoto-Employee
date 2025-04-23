import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kliktoko/login_page/LoginModel/LoginModel.dart';
import 'package:kliktoko/gudang_page/GudangModel/ProductModel.dart';

class ApiService {
  static const String baseUrl = 'https://kliktoko.rplrus.com';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  Future<LoginResponse> login(LoginModel loginData) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/login'),
        headers: await _getHeaders(),
        body: json.encode(loginData.toJson()),
      );

      // Log the response status code and body for debugging
      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return LoginResponse.fromJson(
            json.decode(response.body)); // Correctly map the response
      } else {
        throw HttpException(
            'Request failed with status: ${response.statusCode}',
            response.statusCode);
      }
    } catch (e) {
      print('Error during login API call: $e');
      throw _handleError(e);
    }
  }

  Future<Map<String, String>> _getHeaders([String? token]) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Exception _handleError(dynamic error) {
    if (error is HttpException) return error;
    return Exception('An unexpected error occurred: $error');
  }

  Future<Map<String, dynamic>> getUserData(String token) async {
    try {
      print('Fetching user data with token: ${token.substring(0, 10)}...');
      final response = await _client.get(
        Uri.parse('$baseUrl/api/user'),
        headers: await _getHeaders(token),
      );

      print('User data API response status: ${response.statusCode}');
      print('User data API response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> userData = json.decode(response.body);
        print('Parsed user data: $userData');
        return userData;
      } else {
        throw HttpException(
            'Request failed with status: ${response.statusCode}',
            response.statusCode);
      }
    } catch (e) {
      print('Error fetching user data: $e');
      throw _handleError(e);
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/products'),
        headers: await _getHeaders(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> productsJson = json.decode(response.body);
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw HttpException(
            'Request failed with status: ${response.statusCode}',
            response.statusCode);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;

  HttpException(this.message, this.statusCode);

  @override
  String toString() => message;
}
