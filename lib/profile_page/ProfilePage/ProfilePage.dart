import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../ProfileController/ProfileController.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive spacings
    final verticalSpacing = screenHeight * 0.025;
    final horizontalPadding = screenWidth * 0.05;

    // Calculate avatar radius based on screen size
    final avatarRadius = screenWidth * 0.125; // 12.5% of screen width

    // Calculate top padding to center content
    // Add extra top padding that's approximately 10% of the screen height
    final topPadding = screenHeight * 0.055;

    // Refresh attendance data when profile page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshAttendanceData();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFEFF5E9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh user data and attendance data
            await controller.loadUserData();
            await controller.refreshAttendanceData();
          },
          color: const Color(0xFFAED15C),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  // Add extra top padding to center content vertically
                  SizedBox(height: topPadding),

                  // Custom Profile Card with Menu
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF282828),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Avatar
                        Obx(() => CircleAvatar(
                              radius: avatarRadius,
                              backgroundColor: const Color(0xFFA9CD47),
                              child: Text(
                                controller.username.value.isNotEmpty 
                                    ? controller.username.value[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  fontSize: avatarRadius * 0.8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )),
                        SizedBox(height: verticalSpacing * 0.8),

                        // Username
                        Obx(() => Text(
                              controller.username.value,
                              style: TextStyle(
                                fontSize: screenWidth < 360 ? 20 : 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(height: verticalSpacing * 0.8),

                        // User Info Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // Total Shift
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    color: const Color(0xFFA9CD47),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Shift Bulan Ini',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Obx(() => Text(
                                              controller.totalShiftsPerMonth.value,
                                              style: const TextStyle(
                                                color: Color(0xFFA9CD47),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Role
                              Row(
                                children: [
                                  Icon(
                                    Icons.badge_outlined,
                                    color: const Color(0xFFA9CD47),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Jabatan',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Obx(() => Text(
                                              controller.userRole.value,
                                              style: const TextStyle(
                                                color: Color(0xFFA9CD47),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: verticalSpacing * 0.8),
                        
                        // Divider
                        Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        
                        SizedBox(height: verticalSpacing * 0.8),
                        
                        // Menu Items
                        _buildMenuItem(
                          context: context,
                          icon: Icons.work_outline,
                          title: 'History Kerja',
                          onTap: () => controller.goToHistoryKerjaPage(context),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.logout,
                          title: 'Keluar',
                          onTap: () => _showLogoutConfirmation(context),
                        ),
                      ],
                    ),
                  ),

                  // Add extra space at the bottom to avoid navigation bar overlap
                  SizedBox(height: screenHeight * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Show logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              controller.logout(); // Call the logout function
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Reusable widget for menu items
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white),
      onTap: onTap,
    );
  }
}
