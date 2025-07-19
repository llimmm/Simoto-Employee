import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/attendance_page/AttendanceController.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class AttendanceConfirmationPage extends StatelessWidget {
  final String photoPath;
  final AttendanceController controller;

  const AttendanceConfirmationPage({
    Key? key,
    required this.photoPath,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentTime = DateTime.now();
    final timeFormat = DateFormat('HH:mm:ss');
    final dateFormat = DateFormat('dd MMMM yyyy');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Konfirmasi Absen Masuk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Foto Berhasil Diambil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    dateFormat.format(currentTime),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Photo Preview
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Image.file(
                    File(photoPath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Time and Status Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  // Time
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFF2E7D32),
                        size: 24,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jam Masuk',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            timeFormat.format(currentTime),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Status
                  Obx(() {
                    // Determine if late based on current shift
                    bool isLate = _isLateForCurrentShift(currentTime);
                    
                    return Row(
                      children: [
                        Icon(
                          isLate ? Icons.warning : Icons.check_circle,
                          color: isLate ? Colors.orange : const Color(0xFF2E7D32),
                          size: 24,
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status Kehadiran',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              isLate ? 'Terlambat' : 'Tepat Waktu',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isLate ? Colors.orange : const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),

                  // Shift Information
                  Obx(() {
                    return Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: Color(0xFF2E7D32),
                          size: 24,
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Shift',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Shift ${controller.selectedShift.value}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Action Buttons
            Row(
              children: [
                // Retake Photo Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Go back to camera
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Ambil Ulang',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),

                // Confirm Button
                Expanded(
                  flex: 2,
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed: controller.attendanceController.isLoading.value
                          ? null
                          : () => _confirmCheckIn(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: controller.attendanceController.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Konfirmasi Absen',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Check if current time is late for the selected shift
  bool _isLateForCurrentShift(DateTime currentTime) {
    try {
      // Get current shift information
      final shifts = controller.attendanceController.shiftList;
      final selectedShiftId = controller.selectedShift.value;
      
      if (shifts.isNotEmpty && selectedShiftId.isNotEmpty) {
        final currentShift = shifts.firstWhere(
          (shift) => shift.id == selectedShiftId,
          orElse: () => shifts.first,
        );
        
        // Parse shift start time
        final shiftStartTime = _parseTimeString(currentShift.startTime);
        if (shiftStartTime != null) {
          final currentTimeOnly = DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            currentTime.hour,
            currentTime.minute,
            currentTime.second,
          );
          
          return currentTimeOnly.isAfter(shiftStartTime);
        }
      }
      
      return false;
    } catch (e) {
      print('Error checking if late: $e');
      return false;
    }
  }

  // Parse time string to DateTime
  DateTime? _parseTimeString(String timeString) {
    try {
      // Handle ISO 8601 datetime format
      if (timeString.contains('T') || timeString.contains('Z')) {
        return DateTime.parse(timeString);
      }
      
      // Handle simple time format (HH:MM:SS or HH:MM)
      if (timeString.contains(':')) {
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          final second = parts.length >= 3 ? int.parse(parts[2]) : 0;
          
          final now = DateTime.now();
          return DateTime(now.year, now.month, now.day, hour, minute, second);
        }
      }
      
      return null;
    } catch (e) {
      print('Error parsing time string "$timeString": $e');
      return null;
    }
  }

  // Confirm check-in with photo
  void _confirmCheckIn() async {
    try {
      // Perform check-in with photo
      await controller.checkIn(photoPath: photoPath);
      
      // Navigate back to attendance page
      Get.back(); // Close confirmation page
      Get.back(); // Close camera page if still in stack
      
      // Show success message
      Get.snackbar(
        'Berhasil',
        'Absen masuk berhasil dicatat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Error confirming check-in: $e');
      Get.snackbar(
        'Error',
        'Gagal melakukan absen. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}