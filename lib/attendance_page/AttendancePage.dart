import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/attendance_page/AttendanceController.dart';
import 'package:intl/intl.dart';

class AttendancePage extends GetView<AttendanceController> {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Make sure controller is initialized and registered with Get
    if (!Get.isRegistered<AttendanceController>()) {
      Get.put(AttendanceController());
    }

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
        child: Obx(() => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAED15C)),
                ),
              )
            : _buildContent(context, screenWidth, screenHeight)),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, double screenWidth, double screenHeight) {
    return RefreshIndicator(
      onRefresh: () async {
        // Check attendance status directly from server
        await controller.checkAttendanceStatus();
        controller.attendanceController.loadUserData();
        controller.attendanceController.determineShift();
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
              _buildHeader(screenWidth),
              SizedBox(height: screenHeight * 0.04),
              // Status Cards
              _buildAttendanceStatusCard(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.025),
              // Shift Info Card
              _buildShiftInfoCard(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.025),
              // Attendance Percentage Card
              _buildAttendancePercentageCard(screenWidth, screenHeight),
              // Spacer (matching HomePage approach)
              SizedBox(height: screenHeight * 0.04),
              // Check-in Button
              _buildCheckInButton(screenWidth, screenHeight),
              // Add extra space at the bottom to avoid navigation bar overlap
              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
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
                    Row(
                      children: const [
                        Flexible(
                          child: Text(
                            'Selamat Datang Kembali',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.waving_hand, color: Colors.amber, size: 18)
                      ],
                    ),
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

  Widget _buildAttendanceStatusCard(double screenWidth, double screenHeight) {
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
                    Obx(() {
                      // Check if loading
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

                      // Show status based on hasCheckedIn
                      return Text(
                        controller.hasCheckedIn.value
                            ? 'Anda Sudah Absen'
                            : 'Anda Belum Absen',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth < 360 ? 18 : 20,
                          color: controller.hasCheckedIn.value
                              ? Colors.green[700]
                              : Colors.red[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                    SizedBox(height: screenHeight * 0.005),
                    Obx(() {
                      // Get shift time
                      final shiftTime = controller
                          .getShiftTime(controller.selectedShift.value);

                      // Check if it's "Selamat Malam!" message
                      final bool isEveningMessage =
                          shiftTime == 'Selamat Malam!';

                      return isEveningMessage
                          ? Text(
                              shiftTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
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

  Widget _buildShiftInfoCard(double screenWidth, double screenHeight) {
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
          const Text(
            'Shift Saat Ini:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          Obx(() {
            // Get shift time
            final shiftTime =
                controller.getShiftTime(controller.selectedShift.value);

            // Check if it's "Selamat Malam!" message
            final bool isEveningMessage = shiftTime == 'Selamat Malam!';

            return Text(
              isEveningMessage
                  ? shiftTime // Just show "Selamat Malam!"
                  : 'Shift ${controller.selectedShift.value} : (${controller.getShiftTime(controller.selectedShift.value)})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAttendancePercentageCard(
      double screenWidth, double screenHeight) {
    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Persentase Kehadiran',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenHeight * 0.005),
                Row(
                  children: [
                    Icon(Icons.calendar_month,
                        size: 14, color: Colors.blue[200]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[200],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Obx(() => SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        value: controller.attendancePercentage.value,
                        strokeWidth: 7,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
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
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCheckInButton(double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: controller.hasCheckedIn.value ? null : () => controller.checkIn(),
      child: Obx(() => Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
            decoration: BoxDecoration(
              color: controller.hasCheckedIn.value
                  ? const Color(0xFFAED15C).withOpacity(0.7)
                  : const Color(0xFFAED15C),
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
    );
  }
}
