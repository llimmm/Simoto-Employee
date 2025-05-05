import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../ProfileController/ProfileController.dart';

class HistoryKerjaPage extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  HistoryKerjaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure attendance history is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAttendanceHistory();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFEFF8E2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Go back to the ProfilePage
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'History Kerja',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attendance history list
            Expanded(
              child: Obx(() {
                if (controller.isHistoryLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final attendanceHistory = controller.attendanceHistory;
                
                if (attendanceHistory.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off, 
                             size: 48, 
                             color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada riwayat kehadiran',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: attendanceHistory.length,
                  itemBuilder: (context, index) {
                    final attendanceRecord = attendanceHistory[index];
                    
                    // Check if this record is for today
                    final bool isToday = _isAttendanceRecordToday(attendanceRecord);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isToday ? Colors.blue : Colors.black12,
                          width: isToday ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: _getAttendanceStatusColor(attendanceRecord),
                          child: Icon(
                            _getAttendanceStatusIcon(attendanceRecord),
                            color: Colors.white
                          ),
                        ),
                        title: Text(
                          _getAttendanceDayName(attendanceRecord),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal: ${_formatAttendanceDate(attendanceRecord)}'),
                            
                            // Show check-in and check-out times
                            _buildTimeInfo(attendanceRecord),
                            
                            // Show "Late" indicator if needed
                            _buildLateIndicator(attendanceRecord),
                          ],
                        ),
                        trailing: const Text(
                          'Total 1 Shift',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper to build time information
  Widget _buildTimeInfo(Map<String, dynamic> record) {
    final checkInTime = record['check_in_time'] ?? record['check_in'] ?? '-';
    final checkOutTime = record['check_out_time'] ?? record['check_out'] ?? '-';
    
    // Clean time strings
    String inTime = checkInTime;
    if (inTime.contains(' ')) {
      inTime = inTime.split(' ')[1];
    }
    
    String outTime = checkOutTime;
    if (outTime.contains(' ')) {
      outTime = outTime.split(' ')[1];
    }
    
    return Row(
      children: [
        Icon(Icons.access_time, size: 14, color: Colors.blue[700]),
        const SizedBox(width: 4),
        Text(
          'In: $inTime',
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        outTime != '-' ? Icon(Icons.logout, size: 14, color: Colors.green[700]) : const SizedBox(),
        outTime != '-' ? const SizedBox(width: 4) : const SizedBox(),
        outTime != '-' ? Text(
          'Out: $outTime',
          style: TextStyle(
            fontSize: 12,
            color: Colors.green[700],
            fontWeight: FontWeight.w500,
          ),
        ) : const SizedBox(),
      ],
    );
  }
  
  // Helper to build late indicator
  Widget _buildLateIndicator(Map<String, dynamic> record) {
    // Check if the record indicates late attendance
    bool isLate = false;
    
    if (record.containsKey('is_late') && record['is_late'] == true) {
      isLate = true;
    } else {
      // Try to determine based on check-in time
      String checkInTime = record['check_in_time'] ?? record['check_in'] ?? '';
      String shiftId = record['shift_id']?.toString() ?? record['shift']?.toString() ?? '1';
      
      if (checkInTime.isNotEmpty && checkInTime != '-') {
        // Extract time part if there's a space (datetime format)
        if (checkInTime.contains(' ')) {
          checkInTime = checkInTime.split(' ')[1];
        }
        
        // Extract hours and minutes
        List<String> timeParts = checkInTime.split(':');
        if (timeParts.length >= 2) {
          int hour = int.tryParse(timeParts[0]) ?? 0;
          int minute = int.tryParse(timeParts[1]) ?? 0;
          
          // Shift 1: late after 7:30 AM
          // Shift 2: late after 2:30 PM
          if (shiftId == '1') {
            isLate = (hour > 7 || (hour == 7 && minute > 30));
          } else if (shiftId == '2') {
            isLate = (hour > 14 || (hour == 14 && minute > 30));
          }
        }
      }
    }
    
    if (isLate) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange[700]),
            const SizedBox(width: 4),
            Text(
              'Terlambat',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
  
  // Helper to determine if a record is for today
  bool _isAttendanceRecordToday(Map<String, dynamic> record) {
    String dateStr = record['date'] ?? 
                  record['attendance_date'] ?? 
                  record['created_at']?.toString().split(' ')[0] ?? '';
    
    if (dateStr.isEmpty) return false;
    
    try {
      final date = DateTime.parse(dateStr);
      final today = DateTime.now();
      
      return date.year == today.year && 
             date.month == today.month && 
             date.day == today.day;
    } catch (e) {
      print('Error checking if record is for today: $e');
      return false;
    }
  }
  
  // Format date for display
  String _formatAttendanceDate(Map<String, dynamic> record) {
    String dateStr = record['date'] ?? 
                  record['attendance_date'] ?? 
                  record['created_at']?.toString().split(' ')[0] ?? '';
    
    if (dateStr.isEmpty) return 'Tanggal tidak tersedia';
    
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      print('Error formatting date: $e');
      return dateStr; // Return original string if parsing fails
    }
  }
  
  // Get day name for the attendance record
  String _getAttendanceDayName(Map<String, dynamic> record) {
    String dateStr = record['date'] ?? 
                  record['attendance_date'] ?? 
                  record['created_at']?.toString().split(' ')[0] ?? '';
    
    if (dateStr.isEmpty) return 'Laporan Kerja';
    
    try {
      final date = DateTime.parse(dateStr);
      return 'Laporan Kerja ${DateFormat('EEEE', 'id_ID').format(date)}';
    } catch (e) {
      print('Error getting day name: $e');
      return 'Laporan Kerja';
    }
  }
  
  // Get appropriate status icon for attendance record
  IconData _getAttendanceStatusIcon(Map<String, dynamic> record) {
    final checkOutTime = record['check_out_time'] ?? record['check_out'] ?? '-';
    final isLate = record['is_late'] == true;
    
    if (checkOutTime != '-') {
      return Icons.check_circle; // Completed shift
    } else if (isLate) {
      return Icons.access_time; // Late but no checkout
    } else {
      return Icons.person_outline; // Regular attendance, no checkout
    }
  }
  
  // Get status color for the avatar
  Color _getAttendanceStatusColor(Map<String, dynamic> record) {
    final checkOutTime = record['check_out_time'] ?? record['check_out'] ?? '-';
    bool isLate = false;
    
    if (record.containsKey('is_late') && record['is_late'] == true) {
      isLate = true;
    } else {
      // Try to determine based on check-in time
      String checkInTime = record['check_in_time'] ?? record['check_in'] ?? '';
      String shiftId = record['shift_id']?.toString() ?? record['shift']?.toString() ?? '1';
      
      if (checkInTime.isNotEmpty && checkInTime != '-') {
        // Extract time part if there's a space (datetime format)
        if (checkInTime.contains(' ')) {
          checkInTime = checkInTime.split(' ')[1];
        }
        
        // Extract hours and minutes
        List<String> timeParts = checkInTime.split(':');
        if (timeParts.length >= 2) {
          int hour = int.tryParse(timeParts[0]) ?? 0;
          int minute = int.tryParse(timeParts[1]) ?? 0;
          
          // Shift 1: late after 7:30 AM
          // Shift 2: late after 2:30 PM
          if (shiftId == '1') {
            isLate = (hour > 7 || (hour == 7 && minute > 30));
          } else if (shiftId == '2') {
            isLate = (hour > 14 || (hour == 14 && minute > 30));
          }
        }
      }
    }
    
    if (checkOutTime != '-') {
      return Colors.green[700]!; // Completed shift
    } else if (isLate) {
      return Colors.orange[700]!; // Late but no checkout
    } else {
      return Colors.blue[700]!; // Regular attendance, no checkout
    }
  }
}