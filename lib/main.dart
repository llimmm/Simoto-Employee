import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/attendance_page/AttendanceController.dart';
import 'package:kliktoko/navigation/NavBindings.dart';
import 'package:kliktoko/navigation/NavController.dart';
import 'package:kliktoko/routes/app_routes.dart';
import 'package:kliktoko/start.dart'; 

void main() {
  // Ensure bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize controller immediately
  Get.put(NavController(), permanent: true);
  
  // Add standard RouteObserver
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  Get.put(routeObserver, permanent: true);
  
  // Initialize controllers
  Get.lazyPut(() => AttendanceController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KlikToko',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialBinding: NavBindings(),
      navigatorObservers: [Get.find<RouteObserver<PageRoute>>()],
      getPages: AppRoutes.routes,  // Use your existing routes
      home: StartPage(), // Or whatever your initial page is
      debugShowCheckedModeBanner: false,
    );
  }
}

