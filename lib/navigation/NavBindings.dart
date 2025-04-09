import 'package:get/get.dart';
import 'NavController.dart';

class NavBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavController>(() => NavController());
  }
}
