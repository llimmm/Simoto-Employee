import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/login_page/LoginController/LoginController.dart';

class LoginBottomSheet extends GetView<LoginController> {
  const LoginBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LoginController>()) {
      Get.put(LoginController());
    }

    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive height (60% of screen height)
    final sheetHeight = screenHeight * 0.60;

    // Calculate responsive paddings
    final horizontalPadding = screenWidth * 0.05;
    final verticalSpacing = screenHeight * 0.02;

    return Material(
      child: Container(
        height: sheetHeight,
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
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: sheetHeight,
            ),
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
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

                  // Password field
                  TextField(
                    controller: controller.passwordController,
                    obscureText: true,
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
                    ),
                  ),

                  // Error message (if any)
                  Obx(() => controller.errorMessage.value.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(top: verticalSpacing * 0.4),
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
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
                  // Add extra padding at the bottom for smaller screens
                  SizedBox(height: verticalSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
