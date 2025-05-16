class AttendanceModel {
  final bool isCheckedIn;
  final String date;
  final String shiftId;
  final String? checkInTime;
  final String? checkOutTime;
  final String? username;
  final String? userId;
  final bool isLate;

  AttendanceModel({
    required this.isCheckedIn,
    required this.date,
    required this.shiftId,
    this.checkInTime,
    this.checkOutTime,
    this.username,
    this.userId,
    this.isLate = false,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    // PERBAIKAN: Tambahkan logging untuk help debugging
    print('📊 Processing attendance model from JSON: ${json.keys.join(', ')}');
    
    // Parse check-in time to determine if late
    bool isUserLate = false;
    String? checkInTimeStr = json['check_in_time'] ?? json['check_in'] ?? '';
    
    if (checkInTimeStr != null && checkInTimeStr.isNotEmpty) {
      try {
        // If API explicitly provides late status, use it
        if (json.containsKey('is_late')) {
          isUserLate = json['is_late'] == true;
          print('📋 Late status from API: $isUserLate');
        } else {
          // Otherwise try to determine based on time
          String shiftId = '1';
          
          // Extract shift ID from nested structure or direct field
          if (json.containsKey('shift') && json['shift'] is Map<String, dynamic>) {
            shiftId = json['shift']['id']?.toString() ?? '1';
          } else {
            shiftId = json['shift_id']?.toString() ?? json['shift']?.toString() ?? '1';
          }
          
          print('📋 Shift ID for late calculation: $shiftId');
          
          // Format: "2025-05-06T01:20:43.000000Z"
          String timeOnly;
          if (checkInTimeStr.contains('T')) {
            timeOnly = checkInTimeStr.split('T')[1].split('.')[0];
          } else if (checkInTimeStr.contains(' ')) {
            timeOnly = checkInTimeStr.split(' ')[1];
          } else {
            timeOnly = checkInTimeStr;
          }
          
          print('📋 Check-in time parsed: $timeOnly');
          
          // Extract hours and minutes
          List<String> timeParts = timeOnly.split(':');
          if (timeParts.length >= 2) {
            int hour = int.tryParse(timeParts[0]) ?? 0;
            int minute = int.tryParse(timeParts[1]) ?? 0;
            
            print('📋 Check-in hour: $hour, minute: $minute');
            
            // Shift 1: late after 7:30 AM (07:30)
            // Shift 2: late after 2:30 PM (14:30)
            if (shiftId == '1') {
              isUserLate = (hour > 7 || (hour == 7 && minute > 30));
            } else if (shiftId == '2') {
              isUserLate = (hour > 14 || (hour == 14 && minute > 30));
            }
            
            print('📋 Calculated late status: $isUserLate');
          }
        }
      } catch (e) {
        print('❌ Error determining late status: $e');
      }
    }

    // PERBAIKAN: Handle nested shift object more robustly
    String shiftId = '1';
    try {
      if (json.containsKey('shift')) {
        var shift = json['shift'];
        if (shift is Map<String, dynamic>) {
          shiftId = shift['id']?.toString() ?? '1';
        } else if (shift is String) {
          shiftId = shift;
        } else if (shift is int) {
          shiftId = shift.toString();
        }
      } else if (json.containsKey('shift_id')) {
        var shiftIdValue = json['shift_id'];
        if (shiftIdValue is String) {
          shiftId = shiftIdValue;
        } else if (shiftIdValue is int) {
          shiftId = shiftIdValue.toString();
        }
      }
    } catch (e) {
      print('❌ Error extracting shift ID: $e');
      shiftId = '1'; // Default to shift 1
    }
    
    print('📋 Final shift ID: $shiftId');

    // Handle different date formats
    String date = '';
    if (json.containsKey('date')) {
      String rawDate = json['date'].toString();
      // Convert ISO format to just date
      if (rawDate.contains('T')) {
        date = rawDate.split('T')[0];
      } else {
        date = rawDate;
      }
    } else {
      date = json['attendance_date'] ?? json['created_at']?.toString().split('T')[0] ?? '';
    }
    
    print('📋 Date extracted: $date');

    // Format check-in time for display
    String? formattedCheckInTime;
    if (checkInTimeStr != null && checkInTimeStr.isNotEmpty) {
      if (checkInTimeStr.contains('T')) {
        formattedCheckInTime = checkInTimeStr.split('T')[1].split('.')[0];
      } else if (checkInTimeStr.contains(' ')) {
        formattedCheckInTime = checkInTimeStr.split(' ')[1];
      } else {
        formattedCheckInTime = checkInTimeStr;
      }
    }
    
    print('📋 Formatted check-in time: $formattedCheckInTime');

    // Format check-out time for display
    String? checkOutTimeStr = json['check_out_time'] ?? json['check_out'] ?? '';
    String? formattedCheckOutTime;
    if (checkOutTimeStr != null && checkOutTimeStr.isNotEmpty) {
      if (checkOutTimeStr.contains('T')) {
        formattedCheckOutTime = checkOutTimeStr.split('T')[1].split('.')[0];
      } else if (checkOutTimeStr.contains(' ')) {
        formattedCheckOutTime = checkOutTimeStr.split(' ')[1];
      } else {
        formattedCheckOutTime = checkOutTimeStr;
      }
    }
    
    print('📋 Formatted check-out time: $formattedCheckOutTime');

    // PERBAIKAN: Lebih robust dalam menentukan apakah checked in
    bool isCheckedIn = false;
    if (json['checked_in'] == true || json['is_checked_in'] == true) {
      isCheckedIn = true;
    } else if (checkInTimeStr != null && checkInTimeStr.isNotEmpty) {
      isCheckedIn = true;
    } else if (json.containsKey('status') && json['status'] is String) {
      isCheckedIn = json['status'].toString().toLowerCase().contains('checked in');
    }
    
    print('📋 Is checked in: $isCheckedIn');

    return AttendanceModel(
      isCheckedIn: isCheckedIn,
      date: date,
      shiftId: shiftId,
      checkInTime: formattedCheckInTime,
      checkOutTime: formattedCheckOutTime,
      username: json['username'] ?? 
                json['user_name'] ?? 
                (json.containsKey('user') && json['user'] is Map ? json['user']['name'] : ''),
      userId: json['user_id'] ?? 
              json['id']?.toString() ?? 
              (json.containsKey('user') && json['user'] is Map ? json['user']['id'].toString() : ''),
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

  @override
  String toString() {
    return 'AttendanceModel{isCheckedIn: $isCheckedIn, date: $date, shiftId: $shiftId, checkInTime: $checkInTime, checkOutTime: $checkOutTime, username: $username, isLate: $isLate}';
  }
}