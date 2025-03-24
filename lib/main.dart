import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/navigation/NavBindings.dart';
import 'package:kliktoko/navigation/NavController.dart';
import 'package:kliktoko/start.dart'; 

void main() {
  // Ensure bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize controller immediately
  Get.put(NavController(), permanent: true);
  
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
      home: StartPage(), // Or whatever your initial page is
      debugShowCheckedModeBanner: false,
    );
  }
}