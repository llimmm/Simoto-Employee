import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/attendance_page/SharedAttendanceController.dart';
import 'package:kliktoko/storage/storage_service.dart';
import '../../APIService/ApiService.dart';
import '../../gudang_page/GudangModel/ProductModel.dart';
import '../../../navigation/NavController.dart';
import 'dart:async';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;
  var isLoading = false.obs;
  var outOfStockProducts = <Product>[].obs;
  var newArrivals = <Product>[].obs;
  var username = ''.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // Get shared attendance controller with error handling
  SharedAttendanceController? _attendanceController;
  SharedAttendanceController get attendanceController {
    if (_attendanceController == null) {
      try {
        _attendanceController = SharedAttendanceController.to;
      } catch (e) {
        print('Error getting SharedAttendanceController: $e');
        // Create and register the controller if it doesn't exist
        _attendanceController = Get.put(SharedAttendanceController());
      }
    }
    return _attendanceController!;
  }

  // Delegate attendance-related operations to shared controller
  RxBool get hasCheckedIn => attendanceController.hasCheckedIn;
  RxString get selectedShift => attendanceController.selectedShift;

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    _storageService.init().then((_) {
      checkAuthAndLoadData();
    });
    
    // Register to listen for changes in the shared controller
    try {
      ever(attendanceController.hasCheckedIn, (_) => update());
    } catch (e) {
      print('Error setting up hasCheckedIn listener: $e');
    }
  }

  Future<void> checkAuthAndLoadData() async {
    bool isLoggedIn = await _storageService.isLoggedIn();
    if (isLoggedIn) {
      loadUserData();
      loadProducts();
      
      // Make sure to update attendance data
      try {
        attendanceController.determineShift();
      } catch (e) {
        print('Error determining shift: $e');
      }
    } else {
      // If not logged in, just set a default username and don't try to load products
      username.value = 'Guest';
      hasError.value = true;
      errorMessage.value = 'Please login to see product information';
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
      print('HomeController: Found ${outOfStockProducts.length} out-of-stock products');
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

  String getShiftTime(String shift) {
    try {
      return attendanceController.getShiftTime(shift);
    } catch (e) {
      print('Error getting shift time: $e');
      // Default shift times if controller fails
      switch (shift) {
        case '1':
          return '08:00 - 14:00';
        case '2':
          return '14:00 - 21:00';
        case '3':
          return '21:00 - 08:00';
        default:
          return '08:00 - 14:00';
      }
    }
  }

  Future<void> loadUserData() async {
    try {
      // First try to get user data from local storage
      final userData = await _storageService.getUserData();
      if (userData != null && userData.containsKey('name')) {
        username.value = userData['name'];
        print('Loaded username from storage in HomeController: ${username.value}');
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
            print('Updated username from API in HomeController: ${username.value}');
            await _storageService.saveUserData(apiUserData); // Update cached user data
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
            errorMessage.value = 'Your session has expired. Please log in again.';
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
  Future<void> checkIn() async {
    try {
      // If already checked in, show a message
      if (hasCheckedIn.value) {
        Get.snackbar(
          'Already Checked In', 
          'You have already checked in today',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFAED15C),
          colorText: Colors.black,
        );
        return;
      }
      
      // Show loading indicator
      Get.dialog(
        Dialog(
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAED15C)),
                ),
                const SizedBox(height: 15),
                const Text('Processing...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      
      await attendanceController.checkIn();
      Get.back(); // Close loading dialog
      
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) Get.back();
      
      print('Error checking in from HomePage: $e');
      Get.snackbar(
        'Error', 
        'Failed to check in. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    }
  }

  Future<void> logout() async {
    await _storageService.clearLoginData();
    Get.offAllNamed('/login');
  }
}