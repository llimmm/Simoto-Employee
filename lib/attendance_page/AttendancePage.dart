import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/attendance_page/AttendanceController.dart';

class AttendancePage extends GetView<AttendanceController> {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F9E9), // Light green background
      body: SafeArea(
        child: SingleChildScrollView(
          // Added ScrollView to prevent overflow
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey,
                            backgroundImage:
                                AssetImage('assets/profile_pic.jpg'),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Arka Narendra',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: const [
                                  Text(
                                    'Selamat Datang Kembali',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.waving_hand,
                                      color: Colors.amber, size: 18)
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.notifications_outlined,
                          color: Colors.red),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Attendance Status Card
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Kehadiran',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 11.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() => Text(
                                      controller.hasCheckedIn.value
                                          ? 'Anda Sudah Absen'
                                          : 'Anda Belum Absen',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    )),
                                const SizedBox(height: 4),
                                Obx(() => Row(
                                      children: [
                                        Text(
                                          'Shift ${controller.selectedShift.value} | ',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          controller.getShiftTime(
                                              controller.selectedShift.value),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    )),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      controller.getCurrentDateFormatted(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Shift Info Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shift Saat Ini:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() => Text(
                            'Shift ${controller.selectedShift.value} : (${controller.getShiftTime(controller.selectedShift.value)})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Attendance Percentage Card
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Persentase Kehadiran',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_month,
                                    size: 14, color: Colors.blue[200]),
                                const SizedBox(width: 4),
                                Text(
                                  'November 2024',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[200],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Obx(() => Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: CircularProgressIndicator(
                                    value:
                                        controller.attendancePercentage.value,
                                    strokeWidth: 7,
                                    backgroundColor: Colors.grey[200],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.blue),
                                  ),
                                ),
                                Text(
                                  '${(controller.attendancePercentage.value * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 65),

                // Check-in Button
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: GestureDetector(
                    onTap: () => controller.checkIn(),
                    child: Obx(() => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: controller.hasCheckedIn.value
                                ? const Color(0xFFAED15C)
                                : const Color(0xFF4D4D4D),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              controller.hasCheckedIn.value
                                  ? 'Absen Berhasil!'
                                  : 'Absen Sekarang',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
