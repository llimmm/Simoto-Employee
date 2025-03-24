import 'package:get/get.dart';
import 'package:kliktoko/gudang_page/GudangControllers/GudangController.dart';

class GudangBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GudangController>(() => GudangController());
  }
}
