import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/attendance_page/SharedAttendanceController.dart';
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
  RxBool get hasCheckedOut => attendanceController.hasCheckedOut;
  RxBool get isLate => attendanceController.isLate;
  RxString get selectedShift => attendanceController.selectedShift;
  RxBool get isOutsideShiftHours => attendanceController.isOutsideShiftHours;

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
  void onInit() {
    super.onInit();

    // Initialize time immediately
    _updateTimeAndDate();

    // Set up timer to update every second, synchronized with system time
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeAndDate();
    });

    _storageService.init().then((_) {
      checkAuthAndLoadData();
    });

    // Register to listen for changes in the shared controller
    try {
      ever(attendanceController.hasCheckedIn, (_) => update());
      ever(attendanceController.isLate, (_) => update());
      ever(attendanceController.hasCheckedOut, (_) => update());
      ever(attendanceController.isOutsideShiftHours, (_) => update());
    } catch (e) {
      print('Error setting up attendance listeners: $e');
    }

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

  Future<void> checkAuthAndLoadData() async {
    bool isLoggedIn = await _storageService.isLoggedIn();
    if (isLoggedIn) {
      loadUserData();
      loadProducts();

      // Make sure to update attendance data
      try {
        // Load shift data from API first
        await attendanceController.loadShiftList();
        attendanceController.determineShift();
        attendanceController.checkAttendanceStatus();
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

  // Get shift time based on current shift
  String getShiftTime(String shift) {
    try {
      // Try to get shift data from SharedAttendanceController first
      if (attendanceController.shiftMap.value.isNotEmpty) {
        final shiftId = int.tryParse(shift);
        if (shiftId != null &&
            attendanceController.shiftMap.value.containsKey(shiftId)) {
          final shiftData = attendanceController.shiftMap.value[shiftId]!;

          // Use check_in_time and check_out_time from API if available
          if (shiftData.checkInTime != null &&
              shiftData.checkInTime!.isNotEmpty &&
              shiftData.checkOutTime != null &&
              shiftData.checkOutTime!.isNotEmpty) {
            return '${shiftData.checkInTime} - ${shiftData.checkOutTime}';
          }

          // Fallback to start_time and end_time if check_in/out_time not available
          if (shiftData.startTime != null &&
              shiftData.startTime!.isNotEmpty &&
              shiftData.endTime != null &&
              shiftData.endTime!.isNotEmpty) {
            return '${shiftData.startTime} - ${shiftData.endTime}';
          }
        }
      }

      // If no API data available, use hardcoded times as fallback
      final now = DateTime.now();
      final currentTime = now.hour * 60 + now.minute; // Convert to minutes

      // If it's after 21:30 (1290 minutes) or before 07:30 (450 minutes),
      // it's outside of any shift - night time
      if (currentTime >= 1290 || currentTime < 450) {
        return 'Selamat Tidur!';
      }

      switch (shift) {
        case '1':
          return '07:30 - 14:30';
        case '2':
          return '14:30 - 21:30';
        default:
          return '07:30 - 14:30';
      }
    } catch (e) {
      print('Error getting shift time: $e');
      // Return fallback time
      return '07:30 - 14:30';
    }
  }

  // Get status message based on current attendance state
  String getStatusMessage() {
    try {
      // Check if we have shift status from API
      final shiftStatus = attendanceController.shiftStatus.value;

      // If shift status is active, show appropriate message
      if (shiftStatus.isActive) {
        if (!hasCheckedIn.value) {
          return 'Anda Belum Absen';
        } else if (isLate.value) {
          return 'Anda Terlambat';
        } else if (hasCheckedOut.value) {
          return 'Anda Sudah Check-out';
        } else {
          return 'Anda Sudah Absen';
        }
      } else {
        // If shift is not active, show message from API or default
        if (shiftStatus.message.isNotEmpty) {
          return shiftStatus.message;
        } else {
          return 'Tidak Ada Shift Saat Ini';
        }
      }
    } catch (e) {
      print('Error getting status message: $e');
      // Fallback to original logic
      if (!hasCheckedIn.value) {
        if (isOutsideShiftHours.value) {
          return 'Tidak Ada Shift Saat Ini';
        }
        return 'Anda Belum Absen';
      } else if (isLate.value) {
        return 'Anda Terlambat';
      } else if (hasCheckedOut.value) {
        return 'Anda Sudah Check-out';
      } else {
        return 'Anda Sudah Absen';
      }
    }
  }

  // Get status color based on current attendance state
  Color getStatusColor() {
    if (!hasCheckedIn.value) {
      if (isOutsideShiftHours.value) {
        return Colors.grey.shade700;
      }
      return Colors.red.shade700;
    } else if (isLate.value) {
      return Colors.orange.shade700;
    } else if (hasCheckedOut.value) {
      return Colors.blue.shade700;
    } else {
      return Colors.green.shade700;
    }
  }

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
    try {
      await _storageService.clearLoginData();
      Get.offAllNamed('/start');

      // Show success message using Get.snackbar
      Get.snackbar(
        'Logout Berhasil',
        'Anda telah berhasil keluar dari aplikasi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFAED15C),
        colorText: const Color(0xFF282828),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error during logout: $e');
      Get.offAllNamed('/start');

      // Show error message using Get.snackbar
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat logout',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
