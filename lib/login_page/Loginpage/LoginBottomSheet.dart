import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/login_page/LoginController/LoginController.dart';

class LoginBottomSheet extends GetView<LoginController> {
  const LoginBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Get the keyboard height using viewInsets
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Calculate responsive paddings
    final horizontalPadding = screenWidth * 0.05;
    final verticalSpacing = screenHeight * 0.02;

    return Padding(
      // Add padding to account for keyboard height and safe area
      padding: EdgeInsets.only(
          bottom: keyboardHeight,
          top: MediaQuery.of(context).padding.top * 0.5),
      child: Material(
        color: Colors.transparent,
        child: Container(
          // Use dynamic constraints that adapt to content and keyboard
          constraints: BoxConstraints(
            minHeight: screenHeight * 0.45,
            maxHeight:
                keyboardHeight > 0 ? screenHeight * 0.85 : screenHeight * 0.70,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[50]!],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: SingleChildScrollView(
            // This enables scrolling when keyboard appears
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  horizontalPadding,
                  horizontalPadding,
                  // Add extra padding at bottom to ensure content is above keyboard
                  horizontalPadding +
                      (keyboardHeight > 0 ? keyboardHeight * 0.2 + 20 : 0)),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Use minimum size
                children: [
                  SizedBox(height: verticalSpacing),
                  // Title text - adjust font size based on screen width
                  Center(
                    child: Text(
                      'Selamat datang kembali!',
                      style: TextStyle(
                        fontSize: screenWidth < 360 ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: verticalSpacing * 0.4),
                  Center(
                    child: Text(
                      'Silahkan log in terlebih dahulu',
                      style: TextStyle(
                        fontSize: screenWidth < 360 ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: verticalSpacing * 2),

                  // Username field
                  TextField(
                    controller: controller.usernameController,
                    decoration: InputDecoration(
                      hintText: 'Enter Username....',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding * 0.8,
                        vertical: verticalSpacing * 0.8,
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Password field with toggle visibility
                  Obx(() => TextField(
                        controller: controller.passwordController,
                        obscureText: !controller.isPasswordVisible.value,
                        decoration: InputDecoration(
                          hintText: 'Enter Password....',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding * 0.8,
                            vertical: verticalSpacing * 0.8,
                          ),
                          // Add suffix icon for password visibility toggle
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () =>
                                controller.togglePasswordVisibility(),
                          ),
                        ),
                      )),

                  // Error message with improved visibility
                  Obx(() => controller.errorMessage.value.isNotEmpty
                      ? Container(
                          margin: EdgeInsets.only(top: verticalSpacing * 0.6),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red.shade700, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value,
                                  style: TextStyle(
                                    color: Colors.red.shade800,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink()),
                  SizedBox(height: verticalSpacing * 1.5),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        )),
                  ),
                  // Add extra padding at the bottom for keyboard
                  SizedBox(
                      height:
                          verticalSpacing * 2 + (keyboardHeight > 0 ? 20 : 0)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
