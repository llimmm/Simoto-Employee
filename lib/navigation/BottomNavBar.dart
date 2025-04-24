import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'NavController.dart';

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

    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Navigation bar dimensions - responsive to screen width
    final navBarWidth = screenWidth * 0.85;
    final navBarHeight = screenHeight < 600 ? 65.0 : 70.0;

    // Responsive button sizes
    final buttonSize = screenWidth < 360 ? 45.0 : 50.0;

    // Space for center button
    final centerButtonSpace = buttonSize * 1.2;

    // Responsive icon sizes
    final iconSize = screenWidth < 360 ? 24.0 : 28.0;

    // Calculate bottom padding to account for safe area and screen size
    final adaptiveBottomPadding = bottomPadding > 0
        ? bottomPadding + 10.0 // For devices with notches/safe areas
        : (screenHeight < 700 ? 15.0 : 25.0); // For devices without notches

    return Scaffold(
      backgroundColor: const Color(0xFFF1F9E9),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Main content area - displays the selected page
          Obx(() => IndexedStack(
                index: controller.selectedIndex,
                children: controller.pages,
              )),

          // Floating navigation bar
          Positioned(
            bottom: adaptiveBottomPadding,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Custom shaped navigation bar with notch
                  CustomPaint(
                    size: Size(navBarWidth, navBarHeight),
                    painter: NavBarPainter(
                      color: const Color(0xFF282828),
                    ),
                  ),

                  // Navigation buttons
                  Container(
                    width: navBarWidth,
                    height: navBarHeight,
                    padding:
                        EdgeInsets.symmetric(vertical: navBarHeight * 0.15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Home button
                        _buildNavButton(
                          index: 0,
                          controller: controller,
                          isActive: true,
                          icon: Icons.home,
                          buttonSize: buttonSize,
                          iconSize: iconSize,
                        ),

                        // Inventory button
                        _buildNavButton(
                          index: 1,
                          controller: controller,
                          isActive: true,
                          icon: Icons.inventory_2_outlined,
                          buttonSize: buttonSize,
                          iconSize: iconSize,
                        ),

                        // Empty space for the add button
                        SizedBox(width: centerButtonSpace),

                        // Calendar button
                        _buildNavButton(
                          index: 3,
                          controller: controller,
                          isActive: true,
                          icon: Icons.calendar_month_outlined,
                          buttonSize: buttonSize,
                          iconSize: iconSize,
                        ),

                        // Profile button
                        _buildNavButton(
                          index: 4,
                          controller: controller,
                          isActive: true,
                          icon: Icons.person_outline,
                          buttonSize: buttonSize,
                          iconSize: iconSize,
                        ),
                      ],
                    ),
                  ),

                  // Center floating add button
                  Positioned(
                    top: -(buttonSize * 0.55),
                    child: GestureDetector(
                      onTap: () => controller.handleAddButton(),
                      child: Container(
                        width: buttonSize + 4,
                        height: buttonSize + 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5DE42),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF000000),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              spreadRadius: 0,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        // Inner container for double ring effect
                        child: Container(
                          margin: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB5DE42),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.qr_code_scanner_sharp,
                              color: const Color(0xFF282828),
                              size: iconSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Simplified button builder for navigation items
  Widget _buildNavButton({
    required int index,
    required NavController controller,
    required bool isActive,
    required IconData icon,
    required double buttonSize,
    required double iconSize,
  }) {
    return Obx(() {
      final isSelected = controller.selectedIndex == index;

      return GestureDetector(
        onTap: () => controller.changePage(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFB5DE42) : const Color(0xFF303030),
            shape: BoxShape.circle,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFF282828) : Colors.white,
              size: iconSize,
            ),
          ),
        ),
      );
    });
  }
}

// Custom painter for drawing the navigation bar with a notch for the add button
class NavBarPainter extends CustomPainter {
  final Color color;

  NavBarPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Make corner radius responsive to the size of the nav bar
    final double cornerRadius = size.height * 0.5;

    // Calculate notch size proportional to width
    final notchWidth = size.width * 0.078; // ~33px on a standard screen

    // Create path for the navigation bar with exact notch shape
    final path = Path();

    // Start from the top-left with rounded corner
    path.moveTo(cornerRadius, 0);

    // Draw top edge to notch start
    path.lineTo(size.width / 2 - notchWidth, 0);

    // Draw precise notch curve
    path.arcToPoint(
      Offset(size.width / 2 + notchWidth, 0),
      radius: Radius.circular(notchWidth),
      clockwise: false,
    );

    // Draw top edge from notch to top-right corner
    path.lineTo(size.width - cornerRadius, 0);

    // Draw top-right rounded corner
    path.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Draw right edge
    path.lineTo(size.width, size.height - cornerRadius);

    // Draw bottom-right rounded corner
    path.arcToPoint(
      Offset(size.width - cornerRadius, size.height),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Draw bottom edge
    path.lineTo(cornerRadius, size.height);

    // Draw bottom-left rounded corner
    path.arcToPoint(
      Offset(0, size.height - cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Draw left edge
    path.lineTo(0, cornerRadius);

    // Draw top-left rounded corner
    path.arcToPoint(
      Offset(cornerRadius, 0),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Close the path
    path.close();

    // Add shadow for floating effect
    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 8, true);

    // Draw the navigation bar
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
