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
          onPressed: () => Navigator.pop(context),
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
            Row(
              children: [
                const Text(
                  'SHORT BY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: 'Semua',
                      iconSize: 16,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      items: ['Semua', 'Senin', 'Selasa']
                          .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ))
                          .toList(),
                      onChanged: (value) {},
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() => controller.isHistoryLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.attendanceHistory.isEmpty
                  ? const Center(child: Text('Belum ada riwayat kerja'))
                  : ListView.builder(
                      itemCount: controller.attendanceHistory.length,
                      itemBuilder: (context, index) {
                        final record = controller.attendanceHistory[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isAttendanceRecordToday(record) ? Colors.blue : Colors.black12,
                              width: _isAttendanceRecordToday(record) ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: _getAttendanceStatusColor(record),
                                child: Icon(_getAttendanceStatusIcon(record), color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getAttendanceDayName(record),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tanggal: ${_formatAttendanceDate(record)}',
                                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 4),
                                    _buildTimeInfo(record),
                                    _buildLateIndicator(record),
                                  ],
                                ),
                              ),
                              Text(
                                'Shift ${record['shift'] ?? record['shift_id'] ?? '1'}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
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