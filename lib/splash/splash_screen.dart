import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';
import '../start.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashController controller = Get.put(SplashController());

  @override
  void initState() {
    super.initState();
    controller.checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const StartPage(),
        Obx(() => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : const SizedBox.shrink()),
      ],
    );
  }
}
