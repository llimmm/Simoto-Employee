import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/attendance_page/AttendanceController.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Make sure controller is initialized and registered with Get
    if (!Get.isRegistered<AttendanceController>()) {
      Get.put(AttendanceController());
    }

    final controller = Get.find<AttendanceController>();

    // Ensure user data is loaded from shared controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.attendanceController.loadUserData();
    });

    // Get screen dimensions for responsive design - matching HomePage approach
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F9E9), // Light green background
      body: SafeArea(
        child: GetX<AttendanceController>(
          builder: (ctrl) {
            if (ctrl.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAED15C)),
                ),
              );
            }
            return _buildContent(context, screenWidth, screenHeight, ctrl);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, double screenWidth,
      double screenHeight, AttendanceController controller) {
    return RefreshIndicator(
      onRefresh: () async {
        // Check attendance status directly from server
        await controller.checkAttendanceStatus();
        controller.attendanceController.loadUserData();
        controller.attendanceController.determineShift();
        // Load attendance history
        await controller.attendanceController.loadAttendanceHistory();
        return;
      },
      color: const Color(0xFFAED15C),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          // Match padding approach from HomePage
          padding: EdgeInsets.fromLTRB(
              screenWidth * 0.04, // Horizontal padding (4% of screen width)
              screenHeight * 0.04, // Top padding (4% of screen height)
              screenWidth * 0.04, // Horizontal padding (4% of screen width)
              screenWidth * 0.04), // Bottom padding (4% of screen width)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with profile
              _buildHeader(screenWidth, controller),
              SizedBox(height: screenHeight * 0.04),
              // Status Cards
              _buildAttendanceStatusCard(screenWidth, screenHeight, controller),
              SizedBox(height: screenHeight * 0.025),
              // Shift Info Card
              _buildShiftInfoCard(screenWidth, screenHeight, controller),
              SizedBox(height: screenHeight * 0.025),
              // Attendance History Card (Replacing Percentage Card)
              _buildAttendanceHistoryCard(screenWidth, screenHeight, controller),
              // Spacer (matching HomePage approach)
              SizedBox(height: screenHeight * 0.04),
              // Check-in/Check-out Button
              _buildActionButton(screenWidth, screenHeight, controller),
              // Add extra space at the bottom to avoid navigation bar overlap
              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      ),
    );
  }

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
                          controller.attendanceController.username.value
                                  .isNotEmpty
                              ? controller.attendanceController.username.value
                              : 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )),
                    // Check if outside shift hours for greeting
                    Obx(() {
                      final isOutsideShiftHours = controller
                          .attendanceController.isOutsideShiftHours.value;
                      return Row(
                        children: [
                          Flexible(
                            child: Text(
                              isOutsideShiftHours
                                  ? 'Selamat Beristirahat'
                                  : 'Selamat Datang Kembali',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                              isOutsideShiftHours
                                  ? Icons.nightlight_round
                                  : Icons.waving_hand,
                              color: isOutsideShiftHours
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

  Widget _buildAttendanceStatusCard(double screenWidth, double screenHeight,
      AttendanceController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Match HomePage shadow
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: EdgeInsets.all(screenWidth * 0.0399),
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
          const SizedBox(height: 11.5), // Konsisten dengan nilai HomePage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Properly scoped Obx for loading indicator and status message
                    Obx(() {
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
                                fontSize: screenWidth < 360 ? 16 : 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        );
                      }

                      // Determine status text and color based on check-in and late status
                      String statusText;
                      Color? statusColor;

                      if (!controller.hasCheckedIn.value) {
                        statusText = 'Anda Belum Absen';
                        statusColor = Colors.red[700];
                      } else if (controller.isLate.value) {
                        statusText = 'Anda Terlambat';
                        statusColor = Colors.orange[700];
                      } else {
                        statusText = 'Anda Sudah Absen';
                        statusColor = Colors.green[700];
                      }

                      // Add check-out information if applicable
                      if (controller.hasCheckedIn.value &&
                          controller.hasCheckedOut.value) {
                        statusText = 'Anda Sudah Check-out';
                        statusColor = Colors.blue[700];
                      }

                      // Special status for outside shift hours
                      final isOutsideShiftHours = controller
                          .attendanceController.isOutsideShiftHours.value;
                      if (isOutsideShiftHours &&
                          !controller.hasCheckedIn.value) {
                        statusText = 'Diluar Jam Kerja';
                        statusColor = Colors.indigo[700];
                      }

                      return Text(
                        statusText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth < 360 ? 18 : 20,
                          color: statusColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                    SizedBox(height: screenHeight * 0.005),
                    // Shift info
                    Obx(() {
                      // Get shift time
                      final shiftTime = controller
                          .getShiftTime(controller.selectedShift.value);

                      // Check if it's night time message
                      final bool isNightMessage = shiftTime == 'Selamat Tidur!';

                      return isNightMessage
                          ? Text(
                              shiftTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.indigo[400],
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : Row(
                              children: [
                                Text(
                                  'Shift ${controller.selectedShift.value} | ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    shiftTime,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                    }),
                    SizedBox(height: screenHeight * 0.005),
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
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Add check-in time if available
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
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    // Add check-out time if available
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
                                  fontWeight: FontWeight.w500,
                                ),
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
              // Navigation button removed as requested
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShiftInfoCard(double screenWidth, double screenHeight,
      AttendanceController controller) {
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
      padding: EdgeInsets.all(screenWidth * 0.0399),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final isOutsideShiftHours =
                controller.attendanceController.isOutsideShiftHours.value;
            return Text(
              isOutsideShiftHours ? 'Status Waktu:' : 'Shift Saat Ini:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            );
          }),
          SizedBox(height: screenHeight * 0.015),
          // Properly scoped Obx for shift info
          Obx(() {
            // Get shift time
            final shiftTime =
                controller.getShiftTime(controller.selectedShift.value);

            // Check if it's "Selamat Tidur!" message
            final bool isNightMessage = shiftTime == 'Selamat Tidur!';
            final isOutsideShiftHours =
                controller.attendanceController.isOutsideShiftHours.value;

            if (isNightMessage || isOutsideShiftHours) {
              return Text(
                'Selamat Tidur!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              );
            } else {
              return Text(
                'Shift ${controller.selectedShift.value} : (${controller.getShiftTime(controller.selectedShift.value)})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              );
            }
          }),
        ],
      ),
    );
  }

  // New widget to replace the attendance percentage with attendance history
  Widget _buildAttendanceHistoryCard(double screenWidth, double screenHeight,
      AttendanceController controller) {
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
      padding: EdgeInsets.all(screenWidth * 0.0399),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Kehadiran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              // Add a small refresh button
              InkWell(
                onTap: () => controller.attendanceController.loadAttendanceHistory(),
                child: Icon(
                  Icons.refresh,
                  size: 18,
                  color: Colors.blue[400],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          // Attendance history list
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[300]!),
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
                      Icon(
                        Icons.history_toggle_off,
                        size: 36,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada riwayat kehadiran',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            // Show most recent 3 attendance records
            final historyToShow = controller.attendanceController.attendanceHistory
                .take(3)
                .toList();
                
            return Column(
              children: [
                ...historyToShow.map((item) => _buildHistoryItem(item, screenWidth)),
                // Show "See more" button if there are more than 3 items
                if (controller.attendanceController.attendanceHistory.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          // Navigate to detailed history page
                          // TODO: Implement navigation to full history page
                          Get.snackbar(
                            'Informasi',
                            'Halaman detail riwayat kehadiran akan segera hadir',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.blue[100],
                            colorText: Colors.blue[800],
                          );
                        },
                        child: Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
  
  // Helper widget to build each history item
  Widget _buildHistoryItem(Map<String, dynamic> item, double screenWidth) {
    // Extract date
    String date = item['date'] ?? item['attendance_date'] ?? item['created_at']?.toString().split(' ')[0] ?? '';
    
    // Try to format the date nicely if possible
    try {
      if (date.isNotEmpty) {
        final parsedDate = DateTime.parse(date);
        date = DateFormat('d MMM yyyy', 'id_ID').format(parsedDate);
      }
    } catch (e) {
      // If date parsing fails, keep the original string
      print('Error parsing date: $e');
    }
    
    // Extract check-in and check-out times
    String checkInTime = item['check_in_time'] ?? item['check_in'] ?? '-';
    String checkOutTime = item['check_out_time'] ?? item['check_out'] ?? '-';
    
    // Clean up the times if they are DateTime strings
    if (checkInTime.contains(' ')) {
      checkInTime = checkInTime.split(' ')[1];
    }
    if (checkOutTime.contains(' ')) {
      checkOutTime = checkOutTime.split(' ')[1];
    }
    
    // Determine if the attendance was late
    bool isLate = false;
    if (item['is_late'] == true) {
      isLate = true;
    } else if (checkInTime != '-') {
      // Try to determine based on time
      String shiftId = item['shift_id']?.toString() ?? item['shift']?.toString() ?? '1';
      
      // Extract hours and minutes
      List<String> timeParts = checkInTime.split(':');
      if (timeParts.length >= 2) {
        int hour = int.tryParse(timeParts[0]) ?? 0;
        int minute = int.tryParse(timeParts[1]) ?? 0;
        
        // Shift 1: late after 7:30 AM (07:30)
        // Shift 2: late after 2:30 PM (14:30)
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
          // Date column
          Expanded(
            flex: 3,
            child: Text(
              date,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
          // Check-in time with status indicator
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(
                  Icons.login,
                  size: 14,
                  color: isLate ? Colors.orange[700] : Colors.green[600],
                ),
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
                  Icon(
                    Icons.warning_rounded,
                    size: 12,
                    color: Colors.orange[700],
                  ),
              ],
            ),
          ),
          // Check-out time
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  size: 14,
                  color: checkOutTime != '-' ? Colors.blue[600] : Colors.grey[400],
                ),
                const SizedBox(width: 2),
                Text(
                  checkOutTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: checkOutTime != '-' ? Colors.blue[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(double screenWidth, double screenHeight,
      AttendanceController controller) {
    return Obx(() {
      // Check if outside shift hours
      final isOutsideShiftHours =
          controller.attendanceController.isOutsideShiftHours.value;

      // Determine button action and appearance based on check-in/check-out status
      final bool isCheckedIn = controller.hasCheckedIn.value;
      final bool isCheckedOut = controller.hasCheckedOut.value;

      // If outside shift hours and not checked in, show disabled button
      if (isOutsideShiftHours && !isCheckedIn) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Diluar Jam Kerja',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      }

      // If already checked out, disable button
      if (isCheckedIn && isCheckedOut) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Sudah Check-out',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      }

      // If checked in but not checked out, show check-out button
      if (isCheckedIn && !isCheckedOut) {
        return GestureDetector(
          onTap: () => controller.checkOut(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Check-out',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }

      // If not checked in, show check-in button
      return GestureDetector(
        onTap: () => controller.checkIn(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
          decoration: BoxDecoration(
            color: const Color(0xFFAED15C),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Absen Sekarang',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    });
  }
}