import 'package:get/get.dart';
import 'package:kliktoko/navigation/NavController.dart';

class NavBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavController>(() => NavController());
  }
}
