import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AttendanceController.dart';

class AttendancePage extends GetView<AttendanceController> {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F9E9), // Light green background
      body: SafeArea(
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
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey,
                          backgroundImage: AssetImage('assets/profile_pic.jpg'),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arka Narendra',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
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
                    Icon(Icons.notifications_outlined, color: Colors.red),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Attendance Status Card
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(16),
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
                      SizedBox(height: 11.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => Text(
                                    controller.hasCheckedIn
                                        ? 'Anda Sudah Absen'
                                        : 'Anda Belum Absen',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  )),
                              SizedBox(height: 4),
                              Obx(() => Row(
                                    children: [
                                      Text(
                                        'Shift ${controller.selectedShift} | ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        controller.getShiftTime(
                                            controller.selectedShift),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  )),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
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

              SizedBox(height: 16),

              // Shift Selection Section
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Shift :',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildShiftOption(
                        shiftNumber: 1,
                        startTime: "08:00",
                        endTime: "14:00",
                      ),
                      SizedBox(height: 12),
                      _buildShiftOption(
                        shiftNumber: 2,
                        startTime: "14:00",
                        endTime: "21:00",
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Attendance Percentage Card
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Persentase Kehadiran',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_month,
                                  size: 14, color: Colors.blue[200]),
                              SizedBox(width: 4),
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
                                  value: controller.attendancePercentage,
                                  strokeWidth: 7,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue),
                                ),
                              ),
                              Text(
                                '${(controller.attendancePercentage * 100).toInt()}%',
                                style: TextStyle(
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

              SizedBox(height: 65),

              // Check-in Button
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: GestureDetector(
                  onTap: () => controller.checkIn(),
                  child: Obx(() => Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: controller.hasCheckedIn
                              ? Color(0xFFAED15C)
                              : Color(0xFF4D4D4D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            controller.hasCheckedIn
                                ? 'Absen Berhasil!'
                                : 'Absen Sekarang',
                            style: TextStyle(
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
    );
  }

  Widget _buildShiftOption({
    required int shiftNumber,
    required String startTime,
    required String endTime,
  }) {
    return Obx(() => GestureDetector(
          onTap: () => controller.setShift(shiftNumber),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shift $shiftNumber | $startTime - $endTime',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: controller.selectedShift == shiftNumber
                        ? Colors.green
                        : Colors.grey,
                    width: 2,
                  ),
                ),
                child: controller.selectedShift == shiftNumber
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                        ),
                      )
                    : Container(),
              ),
            ],
          ),
        ));
  }
}
