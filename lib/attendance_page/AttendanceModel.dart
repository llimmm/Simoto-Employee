class AttendanceModel {
  final bool isCheckedIn;
  final String date;
  final String shiftId;
  final String? checkInTime;
  final String? checkOutTime;
  final String? username;
  final String? userId;

  AttendanceModel({
    required this.isCheckedIn,
    required this.date,
    required this.shiftId,
    this.checkInTime,
    this.checkOutTime,
    this.username,
    this.userId,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      isCheckedIn: json['checked_in'] == true || json['is_checked_in'] == true,
      date: json['date'] ?? json['attendance_date'] ?? json['created_at']?.toString().split(' ')[0] ?? '',
      shiftId: json['shift_id'] ?? json['shift'] ?? '1',
      checkInTime: json['check_in_time'] ?? json['check_in'] ?? '',
      checkOutTime: json['check_out_time'] ?? json['check_out'] ?? '',
      username: json['username'] ?? json['user_name'] ?? '',
      userId: json['user_id'] ?? json['id']?.toString() ?? '',
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

  // For debugging purposes
  @override
  String toString() {
    return 'AttendanceModel{isCheckedIn: $isCheckedIn, date: $date, shiftId: $shiftId, checkInTime: $checkInTime, username: $username}';
  }
}