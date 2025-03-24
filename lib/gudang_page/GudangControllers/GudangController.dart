import 'package:get/get.dart';

class GudangController extends GetxController {
  // Observable variables for inventory management
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var inventoryItems = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize inventory data
    loadInventoryData();
  }

  void loadInventoryData() {
    isLoading.value = true;
    // TODO: Implement API call to fetch inventory data
    // For now, we'll just simulate a delay
    Future.delayed(Duration(seconds: 1), () {
      isLoading.value = false;
    });
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    // Implement search logic here
  }

  void refreshInventory() {
    loadInventoryData();
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}
