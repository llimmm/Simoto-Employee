import 'package:get/get.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize any required data or state here
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}
