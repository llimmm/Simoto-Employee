import 'package:get/get.dart';
import 'package:kliktoko/home_page/HomeController/HomeController.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
