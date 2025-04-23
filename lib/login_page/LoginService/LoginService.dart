import 'package:kliktoko/APIService/ApiService.dart';
import 'package:kliktoko/login_page/LoginModel/LoginModel.dart';

class LoginService {
  final ApiService _apiService = ApiService();

  Future<LoginResponse> login(String username, String password) async {
    try {
      final loginData = LoginModel(
        name: username,
        password: password,
      );

      final response = await _apiService.login(loginData);
      return response;
    } catch (e) {
      print('Login error: $e');
      throw e;
    }
  }
}
