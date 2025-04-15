
import 'package:flutter/material.dart';
import '../ProfileController/ProfileController.dart';

final ProfileController _controller = ProfileController();


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF5E9),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile.jpg'), // ganti sesuai gambar kamu
              ),
              const SizedBox(height: 12),
              const Text(
                'Arka Narendra',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // --- Info shift dan role yang baru ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Total Shift
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade600),
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFFEFF5E9),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.school_outlined, color: Colors.grey, size: 28),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'total shift/bulan',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            Text(
                              '10',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Role
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade600),
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFFEFF5E9),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.badge_outlined, color: Colors.grey, size: 28),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Role',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            Text(
                              'Karyawan',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // --------------------------------------

              const SizedBox(height: 30),

              // Card menu hitam
              Card(
                color: const Color(0xFF282828),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.work_outline, color: Colors.white),
                        title: const Text('History Kerja', style: TextStyle(color: Colors.white)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white),
                        onTap: () {
                          _controller.goToHistoryKerjaPage(context);
                        },

                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_today, color: Colors.white),
                        title: const Text('Pengaturan Cuti', style: TextStyle(color: Colors.white)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white),
                        onTap: () {
                          _controller.goToHistoryKerjaPage(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.brightness_6, color: Colors.white),
                        title: const Text('Ubah Tampilan', style: TextStyle(color: Colors.white)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white),
                        onTap: () {
                          Navigator.pushNamed(context, '/theme');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.white),
                        title: const Text('Keluar', style: TextStyle(color: Colors.white)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white),
                        onTap: () {
                          Navigator.pushNamed(context, '/logout');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
