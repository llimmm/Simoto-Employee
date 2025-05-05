class AttendanceModel {
  final bool isCheckedIn;
  final String date;
  final String shiftId;
  final String? checkInTime;
  final String? checkOutTime;
  final String? username;
  final String? userId;
  final bool isLate; // New property to track if attendance is late

  AttendanceModel({
    required this.isCheckedIn,
    required this.date,
    required this.shiftId,
    this.checkInTime,
    this.checkOutTime,
    this.username,
    this.userId,
    this.isLate = false, // Default to not late
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    // Parse check-in time to determine if late
    bool isUserLate = false;
    String? checkInTimeStr = json['check_in_time'] ?? json['check_in'] ?? '';
    
    if (checkInTimeStr != null && checkInTimeStr.isNotEmpty) {
      try {
        // If API explicitly provides late status, use it
        if (json.containsKey('is_late')) {
          isUserLate = json['is_late'] == true;
        } else {
          // Otherwise try to determine based on time
          String shiftId = json['shift_id']?.toString() ?? json['shift']?.toString() ?? '1';
          String timeOnly = checkInTimeStr.contains(' ') 
              ? checkInTimeStr.split(' ')[1] 
              : checkInTimeStr;
          
          // Extract hours and minutes
          List<String> timeParts = timeOnly.split(':');
          if (timeParts.length >= 2) {
            int hour = int.tryParse(timeParts[0]) ?? 0;
            int minute = int.tryParse(timeParts[1]) ?? 0;
            
            // Shift 1: late after 7:30 AM (07:30)
            // Shift 2: late after 2:30 PM (14:30)
            if (shiftId == '1') {
              isUserLate = (hour > 7 || (hour == 7 && minute > 30));
            } else if (shiftId == '2') {
              isUserLate = (hour > 14 || (hour == 14 && minute > 30));
            }
          }
        }
      } catch (e) {
        print('Error determining late status: $e');
      }
    }

    return AttendanceModel(
      isCheckedIn: json['checked_in'] == true || json['is_checked_in'] == true,
      date: json['date'] ?? json['attendance_date'] ?? json['created_at']?.toString().split(' ')[0] ?? '',
      shiftId: json['shift_id'] ?? json['shift'] ?? '1',
      checkInTime: json['check_in_time'] ?? json['check_in'] ?? '',
      checkOutTime: json['check_out_time'] ?? json['check_out'] ?? '',
      username: json['username'] ?? json['user_name'] ?? '',
      userId: json['user_id'] ?? json['id']?.toString() ?? '',
      isLate: isUserLate,
    );
  }

  // Empty model for when there's no attendance data
  factory AttendanceModel.empty() {
    return AttendanceModel(
      isCheckedIn: false,
      date: '',
      shiftId: '1',
    );
  }

  // Check if the user has checked out
  bool get hasCheckedOut => checkOutTime != null && checkOutTime!.isNotEmpty;

  // For debugging purposes
  @override
  String toString() {
    return 'AttendanceModel{isCheckedIn: $isCheckedIn, date: $date, shiftId: $shiftId, checkInTime: $checkInTime, checkOutTime: $checkOutTime, username: $username, isLate: $isLate}';
  }
}