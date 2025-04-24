import 'package:get/get.dart';
import 'package:kliktoko/attendance_page/SharedAttendanceController.dart';
import 'package:kliktoko/storage/storage_service.dart';
import '../../APIService/ApiService.dart';
import '../../gudang_page/GudangModel/ProductModel.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;
  var isLoading = false.obs;
  var outOfStockProducts = <Product>[].obs;
  var newArrivals = <Product>[].obs;
  var username = ''.obs;
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // Get shared attendance controller
  SharedAttendanceController get attendanceController =>
      SharedAttendanceController.to;

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
      loadUserData();
      loadProducts();
    });
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      final products = await _apiService.getProducts();

      // Filter out-of-stock products
      outOfStockProducts.value = products.where((p) => p.stock == 0).toList();

      // Filter new arrivals
      newArrivals.value = products.where((p) => p.isNew).toList();
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String getShiftTime(String shift) => attendanceController.getShiftTime(shift);

  Future<void> loadUserData() async {
    try {
      // First try to get user data from local storage
      final userData = await _storageService.getUserData();
      if (userData != null && userData.containsKey('name')) {
        username.value = userData['name'];
        print('Loaded username from storage in HomeController: ${username.value}');
      } else {
        print('No username found in storage');
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
        }
      } else {
        print('No token available, could not refresh from API');
      }
    } catch (e) {
      print('Error in loadUserData: $e');
    }
  }

  Future<void> logout() async {
    await _storageService.clearLoginData();
    Get.offAllNamed('/login');
  }
}