import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/attendance_page/AttendanceController.dart';
import 'package:kliktoko/camera_page/AttendanceCameraPage.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    if (!Get.isRegistered<AttendanceController>()) {
      Get.put(AttendanceController());
    }
    final controller = Get.find<AttendanceController>();

    // Load user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.attendanceController.loadUserData();
    });

    // Responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F9E9),
      body: SafeArea(
        child: GetX<AttendanceController>(
          builder: (ctrl) => ctrl.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFAED15C)),
                  ),
                )
              : _buildContent(context, screenWidth, screenHeight, ctrl),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, double screenWidth,
      double screenHeight, AttendanceController controller) {
    return RefreshIndicator(
        onRefresh: () async {
          await controller.checkAttendanceStatus();
          controller.attendanceController.loadUserData();
          controller.attendanceController.determineShift();
          await controller.attendanceController.loadAttendanceHistory();
        },
        color: const Color(0xFFAED15C),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            child: Padding(
              padding: EdgeInsets.fromLTRB(screenWidth * 0.04,
                  screenHeight * 0.04, screenWidth * 0.04, screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(screenWidth, controller),
                  SizedBox(height: screenHeight * 0.04),
                  _buildAttendanceStatusCard(
                      screenWidth, screenHeight, controller),
                  SizedBox(height: screenHeight * 0.025),
                  _buildShiftInfoCard(screenWidth, screenHeight, controller),
                  SizedBox(height: screenHeight * 0.025),
                  _buildAttendanceHistoryCard(
                      screenWidth, screenHeight, controller),
                  SizedBox(height: screenHeight * 0.04),
                  _buildCheckInOutButton(controller),
                  SizedBox(height: screenHeight * 0.08),
                ],
              ),
            ),
          ),
        ));
  }

  // Header with profile info
  Widget _buildHeader(double screenWidth, AttendanceController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                backgroundImage: const AssetImage('assets/profile_pic.jpg'),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          controller.username.value.isNotEmpty
                              ? controller.username.value
                              : 'User',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        )),
                    Obx(() {
                      final isOutsideShiftHours = controller
                          .attendanceController.isOutsideShiftHours.value;
                      final shiftStatus =
                          controller.attendanceController.shiftStatus.value;
                      return Row(
                        children: [
                          Flexible(
                            child: Text(
                              isOutsideShiftHours || !shiftStatus.isActive
                                  ? 'Selamat Beristirahat'
                                  : 'Selamat Datang Kembali',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                              isOutsideShiftHours || !shiftStatus.isActive
                                  ? Icons.nightlight_round
                                  : Icons.waving_hand,
                              color:
                                  isOutsideShiftHours || !shiftStatus.isActive
                                      ? Colors.indigo
                                      : Colors.amber,
                              size: 18)
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.notifications_outlined, color: Colors.red),
      ],
    );
  }

  // Card showing attendance status
  Widget _buildAttendanceStatusCard(double screenWidth, double screenHeight,
      AttendanceController controller) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Kehadiran',
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 11.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      // Loading indicator
                      if (controller.isLoading.value) {
                        return Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFAED15C)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Memeriksa status...',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        );
                      }

                      // Status text and color based on shift status
                      String statusText;
                      Color? statusColor;

                      final status =
                          controller.attendanceController.shiftStatus.value;

                      if (status.isActive) {
                        if (status.data?.checkOut != null) {
                          statusText = 'Anda Sudah Check-out';
                          statusColor = Colors.blue[700];
                        } else if (status.data?.isLate ?? false) {
                          statusText = 'Anda Terlambat';
                          statusColor = Colors.orange[700];
                        } else {
                          statusText = 'Anda Sedang Aktif';
                          statusColor = Colors.green[700];
                        }
                      } else {
                        if (controller
                            .attendanceController.isOutsideShiftHours.value) {
                          statusText = 'Di Luar Jam Kerja';
                          statusColor = Colors.indigo[700];
                        } else {
                          statusText = status.message;
                          statusColor = Colors.red[700];
                        }
                      }

                      return Text(
                        statusText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: statusColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                    SizedBox(height: screenHeight * 0.005),

                    SizedBox(height: screenHeight * 0.005),

                    // Date
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                                .format(DateTime.now()),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Check-in time
                    Obx(() {
                      if (controller.hasCheckedIn.value &&
                          controller.currentAttendance.value.checkInTime !=
                              null &&
                          controller.currentAttendance.value.checkInTime!
                              .isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.login,
                                  size: 14, color: Colors.green[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Check-in: ${controller.currentAttendance.value.checkInTime}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    // Check-out time
                    Obx(() {
                      if (controller.hasCheckedOut.value &&
                          controller.currentAttendance.value.checkOutTime !=
                              null &&
                          controller.currentAttendance.value.checkOutTime!
                              .isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.logout,
                                  size: 14, color: Colors.blue[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Check-out: ${controller.currentAttendance.value.checkOutTime}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[600],
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card showing shift info
  Widget _buildShiftInfoCard(double screenWidth, double screenHeight,
      AttendanceController controller) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final isOutsideShiftHours =
                controller.attendanceController.isOutsideShiftHours.value;
            final shiftStatus =
                controller.attendanceController.shiftStatus.value;
            return Text(
              isOutsideShiftHours || !shiftStatus.isActive
                  ? 'Status Waktu:'
                  : 'Shift Saat Ini:',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            );
          }),
          SizedBox(height: screenHeight * 0.015),
          Obx(() {
            final isOutsideShiftHours =
                controller.attendanceController.isOutsideShiftHours.value;
            final shiftStatus =
                controller.attendanceController.shiftStatus.value;

            if (isOutsideShiftHours || !shiftStatus.isActive) {
              return Text(
                'Tidak ada shift saat ini.',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              );
            } else {
              final shiftTime =
                  controller.getShiftTime(controller.selectedShift.value);
              return Text(
                'Shift ${controller.selectedShift.value} : ($shiftTime)',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              );
            }
          }),
        ],
      ),
    );
  }

  // Card showing attendance history
  Widget _buildAttendanceHistoryCard(double screenWidth, double screenHeight,
      AttendanceController controller) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Riwayat Kehadiran',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800])),
              InkWell(
                onTap: () =>
                    controller.attendanceController.loadAttendanceHistory(),
                child: Icon(Icons.refresh, size: 18, color: Colors.blue[400]),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          Obx(() {
            if (controller.attendanceController.isHistoryLoading.value) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blue[300]!),
                    ),
                  ),
                ),
              );
            }

            if (controller.attendanceController.attendanceHistory.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history_toggle_off,
                          size: 36, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('Belum ada riwayat kehadiran',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              );
            }

            // Show most recent 3 attendance records
            final historyToShow = controller
                .attendanceController.attendanceHistory
                .take(3)
                .toList();

            return Column(
              children: [
                ...historyToShow
                    .map((item) => _buildHistoryItem(item, screenWidth)),
                if (controller.attendanceController.attendanceHistory.length >
                    3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          Get.snackbar(
                            'Informasi',
                            'Halaman detail riwayat kehadiran akan segera hadir',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.blue[100],
                            colorText: Colors.blue[800],
                          );
                        },
                        child: Text('Lihat Semua',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // Helper widget to build history items
  Widget _buildHistoryItem(Map<String, dynamic> item, double screenWidth) {
    // Extract and format date
    String date = item['date'] ??
        item['attendance_date'] ??
        item['created_at']?.toString().split(' ')[0] ??
        '';
    try {
      if (date.isNotEmpty) {
        final parsedDate = DateTime.parse(date);
        date = DateFormat('d MMM yyyy', 'id_ID').format(parsedDate);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    // Extract and format times
    String checkInTime = item['check_in_time'] ?? item['check_in'] ?? '-';
    String checkOutTime = item['check_out_time'] ?? item['check_out'] ?? '-';

    if (checkInTime.contains(' ')) checkInTime = checkInTime.split(' ')[1];
    if (checkOutTime.contains(' ')) checkOutTime = checkOutTime.split(' ')[1];

    // Determine if late
    bool isLate = item['is_late'] == true;
    if (!isLate && checkInTime != '-') {
      String shiftId =
          item['shift_id']?.toString() ?? item['shift']?.toString() ?? '1';
      List<String> timeParts = checkInTime.split(':');
      if (timeParts.length >= 2) {
        int hour = int.tryParse(timeParts[0]) ?? 0;
        int minute = int.tryParse(timeParts[1]) ?? 0;

        if (shiftId == '1') {
          isLate = (hour > 7 || (hour == 7 && minute > 30));
        } else if (shiftId == '2') {
          isLate = (hour > 14 || (hour == 14 && minute > 30));
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Date
          Expanded(
            flex: 3,
            child: Text(date,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.grey[700])),
          ),
          // Check-in time
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.login,
                    size: 14,
                    color: isLate ? Colors.orange[700] : Colors.green[600]),
                const SizedBox(width: 2),
                Text(
                  checkInTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLate ? Colors.orange[700] : Colors.green[600],
                    fontWeight: isLate ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (isLate)
                  Icon(Icons.warning_rounded,
                      size: 12, color: Colors.orange[700]),
              ],
            ),
          ),
          // Check-out time
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.logout,
                    size: 14,
                    color: checkOutTime != '-'
                        ? Colors.blue[600]
                        : Colors.grey[400]),
                const SizedBox(width: 2),
                Text(
                  checkOutTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: checkOutTime != '-'
                        ? Colors.blue[600]
                        : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Improved Check-in/Check-out button
  Widget _buildCheckInOutButton(AttendanceController controller) {
    return Obx(() {
      final bool isCheckedIn = controller.hasCheckedIn.value;
      final bool isCheckedOut = controller.hasCheckedOut.value;
      final bool isLoading = controller.isLoading.value;
      final bool isOutsideShiftHours =
          controller.attendanceController.isOutsideShiftHours.value;

      // Loading state
      if (isLoading) {
        return _buildButton(
          color: Colors.grey[400]!,
          onPressed: null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Memproses...',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
        );
      }

      // Outside shift hours or no active shift
      if ((isOutsideShiftHours ||
              controller.attendanceController.shiftStatus.value.message ==
                  "Shift tidak ada, silahkan istirahat") &&
          !isCheckedIn) {
        return _buildButton(
          color: Colors.grey[400]!,
          onPressed: null,
          child: const Text('Diluar Jam Kerja',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        );
      }

      // Already checked out
      if (isCheckedIn && isCheckedOut) {
        return _buildButton(
          color: Colors.grey,
          onPressed: null,
          child: const Text('Sudah Check-out',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        );
      }

      // Checked in but not checked out - show checkout button
      if (isCheckedIn && !isCheckedOut) {
        return _buildButton(
          color: Colors.red,
          onPressed: () => controller.checkOut(),
          child: const Text('Check-out',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        );
      }

      // Not checked in - show check-in button with options
      return Column(
        children: [
          _buildButton(
            color: const Color(0xFFAED15C),
            onPressed: () async {
              // Verify attendance status before attempting check-in
              await controller.checkAttendanceStatus();

              if (controller.hasCheckedIn.value) {
                Get.snackbar(
                  'Sudah Absen',
                  'Anda sudah absen hari ini',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFFAED15C),
                  colorText: const Color(0xFF282828),
                );
                return;
              }

              await controller.checkIn();
            },
            child: const Text('Absen Sekarang',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ),
          const SizedBox(height: 10),
          _buildButton(
            color: const Color(0xFF8BC34A),
            onPressed: () async {
              // Verify attendance status before attempting check-in
              await controller.checkAttendanceStatus();

              if (controller.hasCheckedIn.value) {
                Get.snackbar(
                  'Sudah Absen',
                  'Anda sudah absen hari ini',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFFAED15C),
                  colorText: const Color(0xFF282828),
                );
                return;
              }
              
              // Navigate to camera page for check-in with photo
              final result = await Get.to(
                () => AttendanceCameraPage(shiftId: controller.selectedShift.value),
              );
              
              // Refresh attendance status if check-in was successful
              if (result == true) {
                await controller.checkAttendanceStatus();
                await controller.loadAttendanceHistory();
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.camera_alt, color: Colors.black),
                SizedBox(width: 8),
                Text('Absen dengan Foto',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          ),
        ],
      );
    });
  }

  // Helper method to create consistent cards
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  // Helper method to create consistent buttons
  Widget _buildButton(
      {required Color color,
      required VoidCallback? onPressed,
      required Widget child}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
