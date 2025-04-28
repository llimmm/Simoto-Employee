import 'package:get/get.dart';
import 'package:kliktoko/navigation/NavController.dart';
import 'package:kliktoko/APIService/ApiService.dart';
import 'package:kliktoko/gudang_page/GudangModel/ProductModel.dart';
import 'package:kliktoko/home_page/HomeController/HomeController.dart';
import 'package:kliktoko/storage/storage_service.dart';

class GudangController extends GetxController {
  // Non-reactive state (no .obs)
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  String searchQuery = '';
  List<Product> inventoryItems = [];
  List<Product> filteredItems = [];
  List<Product> outOfStockItems = []; // To display in the Out Of Stock section
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // Only keep reactive state for the filter and current route
  var selectedFilter = 'All'.obs;
  List<String> filterOptions = [
    'All',
    'New Arrival',
    'S Size',
    'M Size',
    'L Size',
    'XL Size',
    'XXL Size',
    'XXXL Size',
    '3L Size',
  ];

  // Signal to close dropdown
  var shouldCloseDropdown = false.obs;

  @override
  void onInit() {
    super.onInit();
    // First check if the user is logged in
    checkAuthAndLoadData();

    // Set up listener for the filter changes
    ever(selectedFilter, (_) => applyFilter());

    // Listen to tab changes from NavController
    if (Get.isRegistered<NavController>()) {
      final navController = Get.find<NavController>();
      navController.selectedIndex.listen((_) => closeDropdown());
    }

    // Simplified route handling
    ever(RxString(Get.currentRoute), (_) {
      closeDropdown();
    });
  }

  Future<void> checkAuthAndLoadData() async {
    // Check if user is logged in
    bool isLoggedIn = await _storageService.isLoggedIn();
    if (isLoggedIn) {
      loadInventoryData();
    } else {
      // User is not logged in, redirect to login
      hasError = true;
      errorMessage = 'You need to login first to view inventory.';
      update();
      
      // Delay the navigation to allow the error message to be seen
      Future.delayed(Duration(seconds: 2), () {
        Get.offAllNamed('/login');
      });
    }
  }

  Future<void> loadInventoryData() async {
    try {
      isLoading = true;
      hasError = false;
      errorMessage = '';
      update();

      // Check if token exists
      final token = await _storageService.getToken();
      if (token == null) {
        hasError = true;
        errorMessage = 'Authentication token not found. Please log in again.';
        update();
        
        // Redirect to login after showing error message
        Future.delayed(Duration(seconds: 2), () {
          Get.offAllNamed('/login');
        });
        return;
      }

      // Fetch products from API
      inventoryItems = await _apiService.getProducts();
      
      // Extract out of stock items for special display
      outOfStockItems = inventoryItems.where((item) => item.stock == 0).toList();
      
      // Update the HomeController if it's registered
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.outOfStockProducts.value = outOfStockItems;
      }
      
      applyFilter();
      
      print('Loaded ${inventoryItems.length} products from API');
      print('Found ${outOfStockItems.length} out of stock items');
    } catch (e) {
      print('Error loading inventory data: $e');
      hasError = true;
      
      // Check if it's an auth error
      if (e is HttpException && e.statusCode == 401) {
        errorMessage = 'Your session has expired. Please log in again.';
        // Clear login data and redirect to login
        await _storageService.clearLoginData();
        
        // Delay navigation to allow error message to be seen
        Future.delayed(Duration(seconds: 2), () {
          Get.offAllNamed('/login');
        });
      } else {
        errorMessage = 'Failed to load products. Please try again later.';
      }
      
      inventoryItems = [];
      outOfStockItems = [];
      filteredItems = [];
    } finally {
      isLoading = false;
      update();
    }
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    applyFilter();
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
    // Filtering will be triggered by the reaction
  }

  void applyFilter() {
    // Start with all items
    var result = [...inventoryItems];

    // Apply search query filter if any
    if (searchQuery.isNotEmpty) {
      result = result
          .where((item) =>
              item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              item.size.toLowerCase().contains(searchQuery.toLowerCase()) ||
              (item.code != null && item.code!.toLowerCase().contains(searchQuery.toLowerCase())))
          .toList();
    }

    // Apply category filter if not "All"
    if (selectedFilter.value != 'All') {
      switch (selectedFilter.value) {
        case 'New Arrival':
          result = result.where((item) => item.isNew).toList();
          break;
        case 'S Size':
          result = result.where((item) => item.size == 'S').toList();
          break;
        case 'M Size':
          result = result.where((item) => item.size == 'M').toList();
          break;
        case 'L Size':
          result = result.where((item) => item.size == 'L').toList();
          break;
        case 'XL Size':
          result = result.where((item) => item.size == 'XL').toList();
          break;
        case 'XXL Size':
          result = result.where((item) => item.size == 'XXL').toList();
          break;
        case 'XXXL Size':
          result = result.where((item) => item.size == 'XXXL').toList();
          break;
        case '3L Size':
          result = result.where((item) => item.size == '3L').toList();
          break;
      }
    }

    // Update the filtered items
    filteredItems = result;
    update();
  }

  // Method to get limited out of stock items for display
  List<Product> getOutOfStockItemsForDisplay(int limit) {
    return outOfStockItems.take(limit).toList();
  }

  // Method to create a product
  Future<bool> createProduct(Product product) async {
    try {
      isLoading = true;
      update();
      
      await _apiService.createProduct(product);
      await loadInventoryData(); // Reload the data after creation
      
      return true;
    } catch (e) {
      print('Error creating product: $e');
      
      // Check if it's an auth error
      if (e is HttpException && e.statusCode == 401) {
        errorMessage = 'Your session has expired. Please log in again.';
        // Handle auth error
        await _storageService.clearLoginData();
        Future.delayed(Duration(seconds: 1), () {
          Get.offAllNamed('/login');
        });
      }
      
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  // Method to update a product
  Future<bool> updateProduct(int id, Product product) async {
    try {
      isLoading = true;
      update();
      
      await _apiService.updateProduct(id, product);
      await loadInventoryData(); // Reload the data after update
      
      return true;
    } catch (e) {
      print('Error updating product: $e');
      
      // Check if it's an auth error
      if (e is HttpException && e.statusCode == 401) {
        errorMessage = 'Your session has expired. Please log in again.';
        // Handle auth error
        await _storageService.clearLoginData();
        Future.delayed(Duration(seconds: 1), () {
          Get.offAllNamed('/login');
        });
      }
      
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  // Method to delete a product
  Future<bool> deleteProduct(int id) async {
    try {
      isLoading = true;
      update();
      
      final result = await _apiService.deleteProduct(id);
      await loadInventoryData(); // Reload the data after deletion
      
      return result;
    } catch (e) {
      print('Error deleting product: $e');
      
      // Check if it's an auth error
      if (e is HttpException && e.statusCode == 401) {
        errorMessage = 'Your session has expired. Please log in again.';
        // Handle auth error
        await _storageService.clearLoginData();
        Future.delayed(Duration(seconds: 1), () {
          Get.offAllNamed('/login');
        });
      }
      
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  void refreshInventory() {
    loadInventoryData();
  }

  // Helper methods for dropdown
  void resetDropdownFlag() {
    shouldCloseDropdown.value = false;
  }

  void closeDropdown() {
    shouldCloseDropdown.value = true;
  }

  // Manually trigger this when pages change to close dropdown
  void onPageChanged() {
    shouldCloseDropdown.value = true;
  }

  // Add this method to handle outside clicks
  void handleOutsideClick() {
    shouldCloseDropdown.value = true;
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}

extension on int {
  void listen(void Function(dynamic _) param0) {}
}