import 'package:get/get.dart';
import 'package:kliktoko/navigation/NavController.dart';
import 'package:kliktoko/APIService/ApiService.dart';
import 'package:kliktoko/gudang_page/GudangModel/ProductModel.dart';

class GudangController extends GetxController {
  // Non-reactive state (no .obs)
  bool isLoading = false;
  String searchQuery = '';
  List<Product> inventoryItems = [];
  List<Product> filteredItems = [];
  final ApiService _apiService = ApiService();

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
    // Initialize inventory data
    loadInventoryData();

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

  Future<void> loadInventoryData() async {
    try {
      isLoading = true;
      update();

      inventoryItems = await _apiService.getProducts();
      applyFilter();
    } catch (e) {
      print('Error loading inventory data: $e');
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
              item.name.toLowerCase().contains(searchQuery.toLowerCase()))
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
