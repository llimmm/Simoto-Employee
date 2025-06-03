import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../ProfileController/ProfileController.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final verticalSpacing = screenHeight * 0.025;
    final horizontalPadding = screenWidth * 0.05;
    final avatarRadius = screenWidth * 0.125;

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
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundImage: const AssetImage('assets/profile.jpg'),
                ),
                SizedBox(height: verticalSpacing * 0.5),
                Obx(() => Text(
                  controller.username.value,
                  style: TextStyle(
                    fontSize: screenWidth < 360 ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )),
                SizedBox(height: verticalSpacing * 0.8),
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
                    _buildInfoCard(
                      icon: Icons.school_outlined,
                      title: 'total shift/bulan',
                      value: '10',
                      width: screenWidth * 0.42,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    _buildInfoCard(
                      icon: Icons.badge_outlined,
                      title: 'Role',
                      value: 'Karyawan',
                      width: screenWidth * 0.42,
                    ),
                  ],
                ),
                SizedBox(height: verticalSpacing),
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
                          onTap: () => controller.goToFormLaporanKerjaPage(context),
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
                          title: 'Logout',
                          onTap: () => _showLogoutConfirmation(context),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          Icon(icon, color: Colors.grey, size: 28),
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

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Yakin ingin keluar?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text("Ya"),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/LoginController');
                    },
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text("Tidak"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
