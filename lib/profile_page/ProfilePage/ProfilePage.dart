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

                  // Profile Avatar
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: const AssetImage('assets/profile.jpg'),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),

                  // Username
                  Obx(() => Text(
                        controller.username.value,
                        style: TextStyle(
                          fontSize: screenWidth < 360 ? 18 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  SizedBox(height: verticalSpacing * 0.8),

                  // Current Month and Year

                  // Info Cards - Responsive layout based on screen width
                  screenWidth < 360
                      ? Column(
                          children: [
                            _buildTotalShiftCard(
                              width: double.infinity,
                            ),
                            SizedBox(height: verticalSpacing * 0.5),
                            _buildRoleCard(
                              width: double.infinity,
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Total Shift
                            _buildTotalShiftCard(
                              width: screenWidth * 0.42,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            // Role
                            _buildRoleCard(
                              width: screenWidth * 0.42,
                            ),
                          ],
                        ),

                  SizedBox(height: verticalSpacing),

                  // Menu Card
                  Card(
                    color: const Color(0xFF282828),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: verticalSpacing * 0.8,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMenuItem(
                            context: context,
                            icon: Icons.work_outline,
                            title: 'History Kerja',
                            onTap: () =>
                                controller.goToHistoryKerjaPage(context),
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.calendar_today,
                            title: 'Pengaturan Cuti',
                            onTap: () =>
                                controller.goToFormLaporanKerjaPage(context),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                controller.logout(context); // Call the logout function
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Widget for Total Shift Card - Now using dynamic data
  Widget _buildTotalShiftCard({required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month_outlined,
              color: Colors.grey[700], size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'total shift/bulan',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Obx(() => Text(
                      controller.totalShiftsPerMonth.value,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for Role Card - Now using dynamic data
  Widget _buildRoleCard({required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.badge_outlined, color: Colors.grey[700], size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Role',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Obx(() => Text(
                      controller.userRole.value,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
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
