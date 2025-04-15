import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/navigation/NavController.dart';

class GudangController extends GetxController {
  // Non-reactive state (no .obs)
  bool isLoading = false;
  String searchQuery = '';
  List<dynamic> inventoryItems = [];
  List<dynamic> filteredItems = [];

  // Only keep reactive state for the filter and current route
  var selectedFilter = 'All'.obs;
  List<String> filterOptions = [
    'All',
    'New Arrival',
    'XL Size',
    'L Size',
    'M Size'
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

  void loadInventoryData() {
    isLoading = true;
    update(); // Notify UI of loading state change

    // Simulate API call to fetch inventory data
    Future.delayed(Duration(milliseconds: 800), () {
      // Example inventory items (replace with your actual data structure)
      inventoryItems = [
        {
          'name': 'Koko Abu',
          'size': 'M',
          'stock': 3,
          'isNew': true,
          'price': 120000
        },
        {
          'name': 'Hem',
          'size': 'L',
          'stock': 0,
          'isNew': false,
          'price': 95000
        },
        {
          'name': 'Koko Abu',
          'size': 'S',
          'stock': 2,
          'isNew': false,
          'price': 120000
        },
        {
          'name': 'Setelan Koko Anak',
          'size': 'XL',
          'stock': 5,
          'isNew': true,
          'price': 60000
        },
        // Add more items as needed
      ];

      // Initial filtering
      applyFilter();
      isLoading = false;
      update(); // Notify UI of state changes
    });
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
          .where((item) => item['name']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Apply category filter if not "All"
    if (selectedFilter.value != 'All') {
      switch (selectedFilter.value) {
        case 'New Arrival':
          result = result.where((item) => item['isNew'] == true).toList();
          break;
        case 'XL Size':
          result = result.where((item) => item['size'] == 'XL').toList();
          break;
        case 'L Size':
          result = result.where((item) => item['size'] == 'L').toList();
          break;
        case 'M Size':
          result = result.where((item) => item['size'] == 'M').toList();
          break;
      }
    }

    // Update the filtered items
    filteredItems = result;
    update(); // Notify UI of state changes
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
