import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:kliktoko/gudang_page/GudangControllers/GudangController.dart';

class GudangBindings extends Bindings {
  @override
  void dependencies() {
    // Register the controller
    Get.lazyPut<GudangController>(() => GudangController());
    
    // Register a simple navigation observer that will call our controller
    final routeObserver = Get.put<RouteObserver<ModalRoute<dynamic>>>(
      _GudangRouteObserver(), 
      tag: 'gudangRouteObserver',
      permanent: true
    );
  }
}

// Simple route observer that works with the controller
class _GudangRouteObserver extends RouteObserver<ModalRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _notifyController();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _notifyController();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _notifyController();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _notifyController();
  }

  void _notifyController() {
    // If controller exists, tell it to close the dropdown
    if (Get.isRegistered<GudangController>()) {
      Get.find<GudangController>().closeDropdown();
    }
  }
}