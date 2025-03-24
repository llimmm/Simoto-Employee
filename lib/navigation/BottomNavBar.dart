import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/navigation/NavController.dart';

class FloatingBottomNavBar extends StatelessWidget {
  const FloatingBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize or find the navigation controller
    NavController controller;
    try {
      controller = Get.find<NavController>();
    } catch (e) {
      controller = Get.put(NavController(), permanent: true);
    }

    final screenWidth = MediaQuery.of(context).size.width;

    // Navigation bar dimensions - adjust these values to change size
    // Width is relative to screen size (percentage of screen width)
    final navBarWidth =
        screenWidth * 0.44 * 1.35; // Modify this value to adjust width

    // Height is a fixed value in logical pixels
    final navBarHeight = 55.0 * 1.35; // Modify this value to adjust height

    // Border radius - controls the roundness of the navigation bar corners
    final borderRadius =
        30.0 * 1.35; // Modify this value to adjust corner roundness

    return Scaffold(
      // Light mint green background as shown in the reference image
      backgroundColor: const Color(0xFFF1F9E9),

      body: Stack(
        children: [
          // Main content area - displays the selected page
          Obx(() => IndexedStack(
                index: controller.selectedIndex,
                children: controller.pages,
              )),

          // Floating navigation bar
          Positioned(
            bottom: 47.0,
            left: (screenWidth - navBarWidth) / 2,
            child: Container(
              width: navBarWidth,
              height: navBarHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF151515), // Dark background for contrast
                borderRadius: BorderRadius.circular(
                    borderRadius), // Customizable border radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 3,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Home button
                  _buildNavButton(
                    index: 0,
                    controller: controller,
                    selectedColor: const Color(0xFFB5DE42),
                    unselectedColor: const Color(0xFF303030),
                    icon: (isSelected) => _buildHomeIcon(isSelected),
                  ),

                  // Minimal spacing between buttons
                  const SizedBox(width: 11),

                  // Inventory button
                  _buildNavButton(
                    index: 1,
                    controller: controller,
                    selectedColor: const Color(0xFFB5DE42),
                    unselectedColor: const Color(0xFF303030),
                    icon: (isSelected) => _buildInventoryIcon(isSelected),
                  ),

                  // Minimal spacing between buttons
                  const SizedBox(width: 11),

                  // Profile button
                  _buildNavButton(
                    index: 2,
                    controller: controller,
                    selectedColor: const Color(0xFFB5DE42),
                    unselectedColor: const Color(0xFF303030),
                    icon: (isSelected) => _buildProfileIcon(isSelected),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Button builder for navigation items
  Widget _buildNavButton({
    required int index,
    required NavController controller,
    required Color selectedColor,
    required Color unselectedColor,
    required Widget Function(bool isSelected) icon,
  }) {
    return Obx(() {
      final isSelected = controller.selectedIndex == index;
      const double buttonSize = 40.0 * 1.35;

      return GestureDetector(
        onTap: () => controller.changePage(index),
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : unselectedColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: icon(isSelected),
          ),
        ),
      );
    });
  }

  // Home icon implementation
  Widget _buildHomeIcon(bool isSelected) {
    return SizedBox(
      width: 21.0 * 1.35,
      height: 21.0 * 1.35,
      child: Icon(
        Icons.home,
        size: 21.0 * 1.35,
        color: isSelected ? Colors.black : Colors.white,
      ),
    );
  }

  // Inventory icon implementation with selection state
  Widget _buildInventoryIcon(bool isSelected) {
    return SizedBox(
      width: 18.0 * 1.35,
      height: 18.0 * 1.35,
      child: Icon(
        Icons.inventory_2_outlined,
        color: isSelected ? Colors.black : Colors.white,
        size: 18.0 * 1.35,
      ),
    );
  }

  // Profile icon implementation with user icon and selection state
  Widget _buildProfileIcon(bool isSelected) {
    return SizedBox(
      width: 18.0 * 1.35,
      height: 18.0 * 1.35,
      child: Icon(
        Icons.person_outline,
        color: isSelected ? Colors.black : Colors.white,
        size: 18.0 * 1.35,
      ),
    );
  }
}

// Custom painter for home icon - implemented inline for simplicity
class _HomeIconPainter extends CustomPainter {
  final Color color;

  const _HomeIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Draw house shape exactly matching the design
    path.moveTo(size.width * 0.5, 0); // Top center
    path.lineTo(0, size.height * 0.5); // Left middle
    path.lineTo(size.width * 0.2, size.height * 0.5); // Indent for door
    path.lineTo(size.width * 0.2, size.height); // Left side of door
    path.lineTo(size.width * 0.4, size.height); // Bottom left of door
    path.lineTo(size.width * 0.4, size.height * 0.7); // Top left of door
    path.lineTo(size.width * 0.6, size.height * 0.7); // Top right of door
    path.lineTo(size.width * 0.6, size.height); // Right side of door
    path.lineTo(size.width * 0.8, size.height); // Bottom right of door
    path.lineTo(size.width * 0.8, size.height * 0.5); // Right indent for door
    path.lineTo(size.width, size.height * 0.5); // Right middle
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _HomeIconPainter) {
      return oldDelegate.color != color;
    }
    return true;
  }
}
