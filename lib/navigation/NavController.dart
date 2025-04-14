import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/home_page/Homepage/HomePage.dart';
import 'package:kliktoko/gudang_page/GudangPage/GudangPage.dart';
import 'package:kliktoko/profile_page/ProfilePage/ProfilePage.dart';

class NavController extends GetxController {
  static NavController get to => Get.find();
  final _selectedIndex = 0.obs;

  // You'll need to create these additional pages
  final List<Widget> pages = [
    const HomePage(key: ValueKey("HomePage")),
    const GudangPage(key: ValueKey("GudangPage")),
    const Placeholder(key: ValueKey("AddPage")), // Will not be shown, just a placeholder
    const Placeholder(key: ValueKey("CalendarPage")), // Create a calendar page
    const ProfilePage(key: ValueKey("ProfilePage")),
  ];

  int get selectedIndex => _selectedIndex.value;
  set selectedIndex(int value) => _selectedIndex.value = value;

  void changePage(int index) {
    // Skip index 2 which is the add button
    if (index != 2 && _selectedIndex.value != index) {
      _selectedIndex.value = index;
    } else if (index == 2) {
      // The add button is handled separately
      handleAddButton();
    }
  }
  
  void handleAddButton() {
    // Handle add button press - show a dialog, bottom sheet, or navigate to a form
    Get.bottomSheet(
      Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Item',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Form content would go here'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB5DE42),
                foregroundColor: Colors.black,
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}