import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/home_page/Homepage/HomePage.dart';
import 'package:kliktoko/gudang_page/GudangPage/GudangPage.dart';
import 'package:kliktoko/profile_page/ProfilePage/ProfilePage.dart';

class NavController extends GetxController {
  static NavController get to => Get.find();
  final _selectedIndex = 0.obs;
  
  final List<Widget> pages = [
    const HomePage(key: ValueKey("HomePage")),
    const GudangPage(key: ValueKey("GudangPage")),
    const ProfilePage(key: ValueKey("ProfilePage")),
  ];

  int get selectedIndex => _selectedIndex.value;
  set selectedIndex(int value) => _selectedIndex.value = value;

  void changePage(int index) {
    if (_selectedIndex.value != index) {
      _selectedIndex.value = index;
    }
  }
}