import 'package:get/get.dart';

class ProfileController extends GetxController {
  final name = 'John Doe'.obs;

  void logout() {
    // Arahkan user ke halaman login setelah logout
    Get.offAllNamed('/login');
  }
}
  