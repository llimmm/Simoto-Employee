import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        child: RefreshIndicator(
          onRefresh: () async {
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
                  SizedBox(height: verticalSpacing * 1.5),
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: Color(0xFFA9CD47),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Shift Bulan Ini',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Obx(() => Text(
                                              controller
                                                  .totalShiftsPerMonth.value,
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
                              Row(
                                children: [
                                  const Icon(
                                    Icons.badge_outlined,
                                    color: Color(0xFFA9CD47),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Jabatan',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
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
                        Container(
                            height: 1, color: Colors.white.withOpacity(0.1)),
                        SizedBox(height: verticalSpacing * 0.8),
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
                          icon: Icons.logout,
                          title: 'Keluar',
                          onTap: () => _showLogoutConfirmation(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.1),
                ],
              ),
            ),
          ),
        ),
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
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 48),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text("Ya"),
                    onPressed: () {
                      Navigator.pop(context);
                      controller.logout();
                    },
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
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
