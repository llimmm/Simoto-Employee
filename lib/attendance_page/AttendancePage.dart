import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatelessWidget {
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

  Widget _buildContent(BuildContext context, double screenWidth, double screenHeight) {
    return RefreshIndicator(
      onRefresh: () async {
        // Future refresh implementation
      },
      color: const Color(0xFFAED15C),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(screenWidth * 0.04, screenHeight * 0.04,
              screenWidth * 0.04, screenWidth * 0.04),
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
    );
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
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
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
                        Icon(
                            Icons.waving_hand,
                            color: Colors.amber,
                            size: 18)
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
                    // Status text - example: not checked in yet
                    Text(
                      'Anda Belum Absen',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.red[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenHeight * 0.005),

                    // Shift info
                    Row(
                      children: [
                        Text(
                          'Shift 1 | ',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600]),
                        ),
                        Expanded(
                          child: Text(
                            '07:30 - 15:30',
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

                    // Example check-in time (can be commented out to show "not checked in" state)
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 4.0),
                    //   child: Row(
                    //     children: [
                    //       Icon(Icons.login,
                    //           size: 14, color: Colors.green[600]),
                    //       const SizedBox(width: 4),
                    //       Text(
                    //         'Check-in: 07:45',
                    //         style: TextStyle(
                    //             fontSize: 12,
                    //             color: Colors.green[600],
                    //             fontWeight: FontWeight.w500),
                    //       ),
                    //     ],
                    //   ),
                    // ),
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
  Widget _buildShiftInfoCard(double screenWidth, double screenHeight) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shift Saat Ini:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: screenHeight * 0.015),
          const Text(
            'Shift 1 : (07:30 - 15:30)',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
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

  // Check-in/Check-out button
  Widget _buildCheckInOutButton() {
    // Static state - can be changed to show different button states
    const bool isCheckedIn = false;
    const bool isCheckedOut = false;
    const bool isLoading = false;
    const bool isOutsideShiftHours = false;

    // Example states for different scenarios:
    
    // Loading state
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
            Text('Memproses...',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
      );
    }

    // Outside shift hours
    if (isOutsideShiftHours && !isCheckedIn) {
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
        onPressed: () {
          // Check-out action
        },
        child: const Text('Check-out',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      );
    }

    // Not checked in - show check-in button (default state)
    return _buildButton(
      color: const Color(0xFFAED15C),
      onPressed: () {
        // Check-in action
      },
      child: const Text('Absen Sekarang',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18)),
    );
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