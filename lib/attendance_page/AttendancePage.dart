import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/attendance_page/AttendanceController.dart';

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

    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive paddings
    final horizontalPadding = screenWidth * 0.05; // 5% of screen width
    final cardPadding = screenWidth * 0.04; // 4% of screen width

    return Scaffold(
      backgroundColor: const Color(0xFFF1F9E9), // Light green background
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section with profile
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey,
                                backgroundImage:
                                    AssetImage('assets/profile_pic.jpg'),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Username from the shared attendance controller
                                    Obx(() => Text(
                                          controller.attendanceController
                                                  .username.value.isNotEmpty
                                              ? controller.attendanceController
                                                  .username.value
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
                                        Icon(Icons.waving_hand,
                                            color: Colors.amber, size: 18)
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.notifications_outlined,
                            color: Colors.red),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Attendance Status Card
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.01),
                    child: Container(
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
                      padding: EdgeInsets.all(cardPadding),
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
                          SizedBox(height: screenHeight * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(() => Text(
                                          controller.hasCheckedIn.value
                                              ? 'Anda Sudah Absen'
                                              : 'Anda Belum Absen',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                screenWidth < 360 ? 18 : 20,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                    SizedBox(height: screenHeight * 0.005),
                                    Obx(() => Row(
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
                                                controller.getShiftTime(
                                                    controller
                                                        .selectedShift.value),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        )),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            controller
                                                .getCurrentDateFormatted(),
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  // Shift Info Section
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: screenHeight * 0.01),
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
                    padding: EdgeInsets.all(cardPadding),
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
                        Obx(() => Text(
                              'Shift ${controller.selectedShift.value} : (${controller.getShiftTime(controller.selectedShift.value)})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            )),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  // Attendance Percentage Card
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.01),
                    child: Container(
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
                      padding: EdgeInsets.symmetric(
                          horizontal: cardPadding,
                          vertical: cardPadding * 0.75),
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
                                        'November 2024',
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
                                        value: controller
                                            .attendancePercentage.value,
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
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),

                  // Spacer that fills available space
                  SizedBox(height: screenHeight * 0.1),

                  // Check-in Button
                  Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.01,
                      bottom: screenHeight * 0.03,
                    ),
                    child: GestureDetector(
                      onTap: () => controller.checkIn(),
                      child: Obx(() => Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02),
                            decoration: BoxDecoration(
                              color: controller.hasCheckedIn.value
                                  ? const Color(0xFFAED15C)
                                  : const Color(0xFF4D4D4D),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
