import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFEFF5E9),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                SizedBox(height: verticalSpacing),

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

                // Info Cards - Responsive layout based on screen width
                screenWidth < 360
                    ? Column(
                        children: [
                          _buildInfoCard(
                            icon: Icons.school_outlined,
                            title: 'total shift/bulan',
                            value: '10',
                            width: double.infinity,
                          ),
                          SizedBox(height: verticalSpacing * 0.5),
                          _buildInfoCard(
                            icon: Icons.badge_outlined,
                            title: 'Role',
                            value: 'Karyawan',
                            width: double.infinity,
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Total Shift
                          _buildInfoCard(
                            icon: Icons.school_outlined,
                            title: 'total shift/bulan',
                            value: '10',
                            width: screenWidth * 0.42,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          // Role
                          _buildInfoCard(
                            icon: Icons.badge_outlined,
                            title: 'Role',
                            value: 'Karyawan',
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
                          onTap: () => controller.goToHistoryKerjaPage(context),
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
                          icon: Icons.brightness_6,
                          title: 'Ubah Tampilan',
                          onTap: () => Navigator.pushNamed(context, '/theme'),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.logout,
                          title: 'Keluar',
                          onTap: () => Navigator.pushNamed(context, '/logout'),
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
    );
  }

  // Reusable widget for info cards
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade600),
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFEFF5E9),
      ),
      child: Row(
        children: [
          const Icon(Icons.school_outlined, color: Colors.grey, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
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
