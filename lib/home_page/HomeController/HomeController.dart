import 'package:get/get.dart';
import 'package:kliktoko/attendance_page/SharedAttendanceController.dart';
import 'package:kliktoko/storage/storage_service.dart';
import '../../APIService/ApiService.dart';
import '../../gudang_page/GudangModel/ProductModel.dart';
import '../../storage/storage_service.dart';

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
    loadProducts();
    loadUserData();
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
      final token = await _storageService.getToken();
      if (token != null) {
        final userData = await _apiService.getUserData(token);
        username.value = userData['name'] ?? '';
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> logout() async {
    await _storageService.clearLoginData();
    Get.offAllNamed('/login');
  }
}
