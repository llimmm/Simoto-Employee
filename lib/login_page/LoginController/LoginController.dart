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
  final RxBool isPasswordVisible = false.obs; // For password visibility toggle

  @override
  void onInit() {
    super.onInit();
    // Initialize storage service early and check for existing login
    _initializeStorage();
  }
  
  Future<void> _initializeStorage() async {
    try {
      await _storageService.init();
      final isAlreadyLoggedIn = await _storageService.verifyLoginState();
      
      if (isAlreadyLoggedIn) {
        print('User is already logged in, navigating to home');
        // Optional: Add a slight delay to ensure the UI is ready
        await Future.delayed(const Duration(milliseconds: 100));
        Get.offAllNamed('/bottomnav');
      }
    } catch (e) {
      print('Error initializing storage: $e');
    }
  }
  
  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = 'Please enter username and password';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    
    print('Starting login process for user: ${usernameController.text}');

    try {
      // Ensure storage service is initialized first
      await _storageService.init();
      
      final response = await _loginService.login(
        usernameController.text,
        passwordController.text,
      );
      
      print('Login response received: success=${response.success}, '
            'token=${response.token.isNotEmpty ? 'Present' : 'Missing'}');

      if (response.success && response.token.isNotEmpty) {
        try {
          // Save token first
          await _storageService.saveToken(response.token);
          print('Token saved successfully');

          // Prepare user data with proper fallbacks
          Map<String, dynamic> userData = {};
          if (response.user.isNotEmpty) {
            userData = Map<String, dynamic>.from(response.user);
          } else {
            // If API didn't return user data, create basic data from username
            userData = {'name': usernameController.text};
            print('Created basic user data from username');
          }

          // Ensure username is present
          if (!userData.containsKey('name') || 
              userData['name'] == null || 
              userData['name'].toString().isEmpty) {
            userData['name'] = usernameController.text;
            print('Added missing name field from username');
          }

          print('Saving user data: $userData');
          await _storageService.saveUserData(userData);
          
          // Verify data was saved
          final loginVerified = await _storageService.verifyLoginState();
          
          if (loginVerified) {
            print('Login data stored successfully, navigating to home');
            Get.offAllNamed('/bottomnav');
          } else {
            print('Data verification failed after login');
            errorMessage.value = 'Login successful but data storage failed. Please try again.';
          }
        } catch (e) {
          print('Error saving login data: $e');
          errorMessage.value = 'Login successful but data storage failed: $e';
        }
      } else {
        print('Login failed: ${response.message}');
        errorMessage.value = response.message.isNotEmpty 
            ? response.message 
            : 'Login failed. Please check your credentials.';
      }
    } catch (e) {
      print('Login error: $e');
      errorMessage.value = 'Login failed: ${e.toString()}';
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