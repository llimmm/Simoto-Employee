import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'controllers/attendance_controller.dart';
import 'models/attendance_model.dart';
import 'models/shift_model.dart';

class AttendancePage extends GetView<AttendanceController> {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F9E9),
      body: SafeArea(
        child: _buildContent(context, screenWidth, screenHeight),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, double screenWidth, double screenHeight) {
    return RefreshIndicator(
        onRefresh: () async {
          await controller.checkShiftStatus();
        },
        color: const Color(0xFFAED15C),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(screenWidth * 0.04,
                  screenHeight * 0.04, screenWidth * 0.04, screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(screenWidth),
                  SizedBox(height: screenHeight * 0.04),
                  _buildAttendanceStatusCard(screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.025),
                  _buildShiftInfoCard(screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.025),
                  _buildAttendanceHistoryCard(screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.04),
                  _buildCheckInOutButton(),
                  SizedBox(height: screenHeight * 0.08),
                ],
              ),
            ),
          ),
        ));
  }

  // Header with profile info
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
                    const Text(
                      'John Doe',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'Selamat Datang Kembali',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
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

  // Card showing attendance status
  Widget _buildAttendanceStatusCard(double screenWidth, double screenHeight) {
    return _buildCard(
      child: Obx(() {
        final isLoading = controller.isLoading.value;
        final statusMessage = controller.statusMessage.value;
        final isCheckedIn = controller.isCheckedIn.value;
        final isCheckedOut = controller.isCheckedOut.value;
        final currentAttendance = controller.currentAttendance.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status Kehadiran',
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 11.5),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status text with better logic
                        Text(
                          _getDisplayStatusMessage(
                              statusMessage, isCheckedIn, isCheckedOut),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: _getStatusColor(isCheckedIn, isCheckedOut),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenHeight * 0.005),

                        // Shift info
                        if (currentAttendance?.shift != null)
                          Row(
                            children: [
                              Text(
                                '${currentAttendance!.shift!.name} | ',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              Expanded(
                                child: Text(
                                  currentAttendance.shift!
                                      .getFormattedShiftTime(),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
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
                      ],
                    ),
                  ),
                ],
              ),
          ],
        );
      }),
    );
  }

  // Helper method to get appropriate status message
  String _getDisplayStatusMessage(
      String statusMessage, bool isCheckedIn, bool isCheckedOut) {
    if (isCheckedOut) {
      return 'Sudah Check-out';
    } else if (isCheckedIn) {
      return 'Sudah Check-in';
    } else if (statusMessage == 'Anda belum aktif') {
      return 'Belum Check-in';
    } else if (statusMessage == 'User aktif') {
      return 'Aktif';
    } else {
      return statusMessage.isNotEmpty ? statusMessage : 'Tidak Ada Shift';
    }
  }

  // Helper method to get status color
  Color _getStatusColor(bool isCheckedIn, bool isCheckedOut) {
    if (isCheckedOut) {
      return Colors.grey[700]!;
    } else if (isCheckedIn) {
      return Colors.green[700]!;
    } else {
      return Colors.red[700]!;
    }
  }

  // Card showing shift info
  Widget _buildShiftInfoCard(double screenWidth, double screenHeight) {
    return _buildCard(
      child: Obx(() {
        final currentShift = controller.currentShift.value;
        final isActiveShift = controller.isActiveShift.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shift Saat Ini:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              currentShift != null && isActiveShift
                  ? '${currentShift.name} : (${currentShift.checkInTime.substring(0, 5)} - ${currentShift.checkOutTime.substring(0, 5)})'
                  : 'Tidak ada shift aktif',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isActiveShift ? Colors.blue : Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        );
      }),
    );
  }

  // Card showing attendance history
  Widget _buildAttendanceHistoryCard(double screenWidth, double screenHeight) {
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
                onTap: () {
                  // Refresh action
                  controller.checkShiftStatus();
                },
                child: Icon(Icons.refresh, size: 18, color: Colors.blue[400]),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),

          // Static attendance history data
          Column(
            children: [
              _buildHistoryItem({
                'date': '2024-05-16',
                'check_in_time': '07:45',
                'check_out_time': '15:35',
                'is_late': true,
                'shift_id': '1'
              }, screenWidth),
              _buildHistoryItem({
                'date': '2024-05-15',
                'check_in_time': '07:25',
                'check_out_time': '15:30',
                'is_late': false,
                'shift_id': '1'
              }, screenWidth),
              _buildHistoryItem({
                'date': '2024-05-14',
                'check_in_time': '07:30',
                'check_out_time': '15:40',
                'is_late': false,
                'shift_id': '1'
              }, screenWidth),

              // Show more button
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      // Show all attendance records action
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
          ),
        ],
      ),
    );
  }

  // Helper widget to build history items
  Widget _buildHistoryItem(Map<String, dynamic> item, double screenWidth) {
    // Extract and format date
    String date = item['date'] ?? '';
    try {
      if (date.isNotEmpty) {
        final parsedDate = DateTime.parse(date);
        date = DateFormat('d MMM yyyy', 'id_ID').format(parsedDate);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    // Extract and format times
    String checkInTime = item['check_in_time'] ?? '-';
    String checkOutTime = item['check_out_time'] ?? '-';

    if (checkInTime.contains(' ')) checkInTime = checkInTime.split(' ')[1];
    if (checkOutTime.contains(' ')) checkOutTime = checkOutTime.split(' ')[1];

    // Determine if late
    bool isLate = item['is_late'] == true;

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

  // Fixed Check-in/Check-out button with better logic
  Widget _buildCheckInOutButton() {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final isCheckedIn = controller.isCheckedIn.value;
      final isCheckedOut = controller.isCheckedOut.value;
      final isActiveShift = controller.isActiveShift.value;
      final statusMessage = controller.statusMessage.value;

      // Show loading indicator
      if (isLoading) {
        return _buildButton(
          color: Colors.grey[400]!,
          onPressed: null,
          child: const Row(
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
              SizedBox(width: 10),
              Text('Loading...',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
        );
      }

      // Button logic based on status
      if (isCheckedOut) {
        // Already checked out for the day
        return _buildButton(
          color: Colors.grey[600]!,
          onPressed: null,
          child: const Text('Sudah Check-out',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        );
      } else if (isCheckedIn && !isCheckedOut) {
        // Checked in, can check out
        return _buildButton(
          color: Colors.red[600]!,
          onPressed: controller.canCheckOut()
              ? () => controller.performCheckOut()
              : null,
          child: const Text('Check-out',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        );
      } else if (!isCheckedIn &&
              isActiveShift &&
              statusMessage == 'Anda belum absen di shift 1' ||
          statusMessage == 'Anda belum absen di shift 2') {
        // Can check in
        return _buildButton(
          color: const Color(0xFFAED15C),
          onPressed: controller.canCheckIn()
              ? () => controller.performCheckIn()
              : null,
          child: const Text(
            'Absen Sekarang',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        );
      } else {
        // No active shift or other states
        String buttonText = 'Tidak Ada Shift';
        Color buttonColor = Colors.grey[600]!;
        Color textColor = Colors.white;

        if (!isActiveShift) {
          buttonText = 'Tidak Ada Shift Aktif';
        } else if (statusMessage.isEmpty) {
          buttonText = 'Memuat...';
        } else {
          buttonText = 'Tidak Tersedia';
        }

        return _buildButton(
          color: buttonColor,
          onPressed: null,
          child: Text(
            buttonText,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        );
      }
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
          elevation: onPressed != null ? 2 : 0,
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
