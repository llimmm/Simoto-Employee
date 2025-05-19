import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:kliktoko/attendance_page/controllers/attendance_controller.dart';

import 'package:kliktoko/storage/storage_service.dart';
import '../../APIService/ApiService.dart';
import '../../gudang_page/GudangModel/ProductModel.dart';
import '../../gudang_page/GudangModel/CategoryModel.dart'; // Added import for Category
import '../../gudang_page/GudangServices/CategoryService.dart'; // Added import for CategoryService
import '../../../navigation/NavController.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;
  var isLoading = false.obs;
  var outOfStockProducts = <Product>[].obs;
  var newArrivals = <Product>[].obs;
  var username = ''.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Added for category synchronization
  var categories = <Category>[].obs;
  var isCategoriesLoading = false.obs;

  // Time-related variables - using a simple string for direct display
  final timeString = ''.obs;
  final dateString = ''.obs;
  Timer? _timer;

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final CategoryService _categoryService =
      CategoryService(); // Added CategoryService

  @override
  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  // Updates the time and date strings with current system time
  void _updateTimeAndDate() {
    final now = DateTime.now();
    timeString.value = DateFormat('HH:mm:ss').format(now);
    dateString.value = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
  }

  @override
  void onInit() async {
    super.onInit();

    final token = await _storageService.getToken();
    if (token != null && !Get.isRegistered<AttendanceController>()) {
      Get.put(AttendanceController(token: token), permanent: true);
    }
    // Initialize time immediately
    _updateTimeAndDate();

    // Set up timer to update every second, synchronized with system time
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeAndDate();
    });

    // Register to listen for changes in the shared controller

    // Load categories
    loadCategories();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // Current time string directly from timeString observable
  String getCurrentTime() {
    return timeString.value;
  }

  // Current date string directly from dateString observable
  String getCurrentDate() {
    return dateString.value;
  }

  // Added method to load categories, similar to GudangController
  Future<void> loadCategories() async {
    try {
      isCategoriesLoading.value = true;

      final loadedCategories = await _categoryService.getCategories();
      categories.value = loadedCategories;

      print('HomeController: Loaded ${categories.length} categories');
    } catch (e) {
      print('Error loading categories in HomeController: $e');
      // Categories will remain as default values
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  // Added method to get products by category, similar to GudangController
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      isLoading.value = true;

      // Use CategoryService to get products filtered by category
      final products = await _categoryService.getProductsByCategory(categoryId);

      return products;
    } catch (e) {
      print('Error fetching products by category in HomeController: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Added method to find category by name
  Category? findCategoryByName(String name) {
    try {
      return categories.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
        orElse: () => Category(id: -1, name: name),
      );
    } catch (e) {
      print('Error finding category by name: $e');
      return null;
    }
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Check if token exists
      final token = await _storageService.getToken();
      if (token == null) {
        hasError.value = true;
        errorMessage.value = 'Please login to view products';
        return;
      }

      final products = await _apiService.getProducts();

      // Filter out-of-stock products
      outOfStockProducts.value = products.where((p) => p.stock == 0).toList();

      // Filter new arrivals
      newArrivals.value = products.where((p) => p.isNew).toList();

      print('HomeController: Loaded ${products.length} products');
      print(
          'HomeController: Found ${outOfStockProducts.length} out-of-stock products');
      print('HomeController: Found ${newArrivals.length} new arrivals');
    } catch (e) {
      print('Error loading products: $e');
      hasError.value = true;

      // Check if it's an auth error
      if (e is HttpException && e.statusCode == 401) {
        errorMessage.value = 'Your session has expired. Please log in again.';
        // Clear login data
        await _storageService.clearLoginData();

        // Don't automatically redirect from the homepage, just show the error
        username.value = 'Guest';
      } else {
        errorMessage.value = 'Failed to load products. Please try again later.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Method to get limited out of stock items for display
  List<Product> getOutOfStockItemsForDisplay(int limit) {
    return outOfStockProducts.take(limit).toList();
  }

  // Get status message based on current attendance state

  Future<void> loadUserData() async {
    try {
      // First try to get user data from local storage
      final userData = await _storageService.getUserData();
      if (userData != null && userData.containsKey('name')) {
        username.value = userData['name'];
        print(
            'Loaded username from storage in HomeController: ${username.value}');
      } else {
        print('No username found in storage');
        username.value = 'User';
      }

      // Then try to refresh from API if we have a token
      final token = await _storageService.getToken();
      if (token != null) {
        try {
          final apiUserData = await _apiService.getUserData(token);
          if (apiUserData.containsKey('name') &&
              apiUserData['name'] != null &&
              apiUserData['name'].toString().isNotEmpty) {
            username.value = apiUserData['name'];
            print(
                'Updated username from API in HomeController: ${username.value}');
            await _storageService
                .saveUserData(apiUserData); // Update cached user data
          } else {
            print('API returned empty username');
          }
        } catch (e) {
          print('Error fetching user data from API: $e');
          // We already tried local storage, so we'll use that if it worked

          // Check if it's an auth error
          if (e is HttpException && e.statusCode == 401) {
            // Clear login data but don't redirect from homepage
            await _storageService.clearLoginData();
            username.value = 'Guest';
            hasError.value = true;
            errorMessage.value =
                'Your session has expired. Please log in again.';
          }
        }
      } else {
        print('No token available, could not refresh from API');
      }
    } catch (e) {
      print('Error in loadUserData: $e');
    }
  }

  // Method to navigate to attendance page
  void goToAttendancePage() {
    try {
      Get.find<NavController>().changePage(3);
    } catch (e) {
      print('Error navigating to attendance page: $e');
      // Fallback if NavController is not found
      Get.toNamed('/attendance');
    }
  }

  // Method to check in directly from HomePage

  Future<void> logout() async {
    await _storageService.clearLoginData();
    Get.offAllNamed('/login');
  }
}
