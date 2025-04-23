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
        await _storageService.init();
        await _storageService.saveToken(response.token);
        await _storageService.saveUserData(response.user);
        
        // Navigate to bottom navigation
        Get.offAllNamed('/bottomnav'); // Changed from '/home' to '/bottomnav'
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
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
