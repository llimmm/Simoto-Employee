import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/login_page/LoginController/LoginController.dart';
import 'package:kliktoko/login_page/Loginpage/LoginBottomSheet.dart';

// Utility class to manage login bottom sheet display
class LoginSheetUtils {
  // Singleton pattern
  static final LoginSheetUtils _instance = LoginSheetUtils._internal();
  factory LoginSheetUtils() => _instance;
  LoginSheetUtils._internal();

  // Flag to prevent multiple bottom sheets
  bool _isBottomSheetShowing = false;

  // Method to show login bottom sheet with safeguards
  void showLoginBottomSheet(BuildContext context) {
    // Prevent multiple sheets from appearing
    if (_isBottomSheetShowing) return;
    _isBottomSheetShowing = true;

    // Register the controller only once before showing the sheet
    if (!Get.isRegistered<LoginController>()) {
      Get.put(LoginController());
    }

    // Show the bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LoginBottomSheet(),
    ).then((_) {
      // Reset the flag after sheet is closed with a delay
      // to prevent immediate reopening during animation
      Future.delayed(const Duration(milliseconds: 300), () {
        _isBottomSheetShowing = false;
      });
    });
  }
}
