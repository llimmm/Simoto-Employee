import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/attendance_page/AttendancePage.dart';
import 'package:kliktoko/camera_page/CameraPage.dart';
import 'package:kliktoko/home_page/Homepage/HomePage.dart';
import 'package:kliktoko/gudang_page/GudangPage/GudangPage.dart';
import 'package:kliktoko/profile_page/ProfilePage/ProfilePage.dart';

class NavController extends GetxController {
  static NavController get to => Get.find();
  final _selectedIndex = 0.obs;

  // Define the main pages for the navigation bar
  final List<Widget> pages = [
    HomePage(key: ValueKey("HomePage")),
    const GudangPage(key: ValueKey("GudangPage")),
    Container(key: ValueKey("PlaceholderPage")), // Placeholder for camera button
    const AttendancePage(key: ValueKey("AttendancePage")),
    ProfilePage(key: ValueKey("ProfilePage")),
  ];

  int get selectedIndex => _selectedIndex.value;
  set selectedIndex(int value) => _selectedIndex.value = value;

  void changePage(int index) {
    // If it's the camera button (index 2)
    if (index == 2) {
      openQRScanner();
    } 
    // Otherwise, change to the selected page
    else if (_selectedIndex.value != index) {
      _selectedIndex.value = index;
    }
  }

  // Method to open the QR scanner
  Future<void> openQRScanner() async {
    try {
      final result = await Get.to(() => const CameraPage());
      
      if (result != null) {
        // Handle the scanned QR code result
        processScannedCode(result);
      }
    } catch (e) {
      print('Error opening camera: $e');
      Get.snackbar(
        'Error',
        'Failed to open camera. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    }
  }

  // Process the scanned QR code
  void processScannedCode(String code) {
    print('Scanned QR code: $code');
    
    // Show a success message
    Get.snackbar(
      'QR Code Scanned',
      'Successfully scanned: $code',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFAED15C),
      colorText: Colors.black,
      duration: Duration(seconds: 3),
    );

    // TODO: Add your business logic to process the QR code
    // For example, you might want to:
    // - Check if it's a valid product code
    // - Add item to inventory
    // - Verify attendance
    // - etc.
  }

  // This method is kept for backward compatibility but redirects to the QR scanner
  void handleAddButton() {
    openQRScanner();
  }
}