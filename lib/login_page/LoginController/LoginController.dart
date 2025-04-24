import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/login_page/LoginService/LoginService.dart';
import 'package:kliktoko/storage/storage_service.dart';

class LoginController extends GetxController {
  final LoginService _loginService = LoginService();
  final StorageService _storageService = StorageService();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _storageService.init(); // Initialize storage service early
  }

  void login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = 'Please enter username and password';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _loginService.login(
        usernameController.text,
        passwordController.text,
      );

      if (response.success) {
        // Save token and user data
        await _storageService.saveToken(response.token);

        // Make sure we're saving all user data including username
        Map<String, dynamic> userData =
            Map<String, dynamic>.from(response.user);

        // If the user data doesn't have a name field, add it from the username controller
        if (!userData.containsKey('name') ||
            userData['name'] == null ||
            userData['name'].toString().isEmpty) {
          userData['name'] = usernameController.text;
        }

        print('Saving user data to storage: $userData');
        await _storageService.saveUserData(userData);

        // Navigate to bottom navigation
        Get.offAllNamed('/bottomnav');
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      print('Login error: $e');
      errorMessage.value = 'Login failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose(); 
    super.onClose();
  }
}
