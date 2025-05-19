import 'package:get/get.dart';
import 'package:kliktoko/navigation/NavController.dart';
import 'package:kliktoko/attendance_page/controllers/attendance_controller.dart';
import 'package:kliktoko/storage/storage_service.dart';

class NavBindings extends Bindings {
  @override
  void dependencies() async {
    Get.put(NavController());

    // Dapatkan token dari storage
    final storageService = Get.find<StorageService>();
    final token = await storageService.getToken();

    if (token != null) {
      Get.put(AttendanceController(token: token), permanent: true);
    } else {
      print('Token tidak ditemukan untuk AttendanceController');
    }
  }
}
