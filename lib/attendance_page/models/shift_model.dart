import 'package:intl/intl.dart';

class ShiftModel {
  final int id;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final int lateTolerance;
  final dynamic lateThreshold;
  final double salaryPerShift;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String checkInTime;
  final String checkOutTime;

  ShiftModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.lateTolerance,
    this.lateThreshold,
    required this.salaryPerShift,
    required this.createdAt,
    required this.updatedAt,
    required this.checkInTime,
    required this.checkOutTime,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'],
      name: json['name'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      lateTolerance: json['late_tolerance'],
      lateThreshold: json['late_threshold'],
      salaryPerShift: double.parse(json['salary_per_shift']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'late_tolerance': lateTolerance,
      'late_threshold': lateThreshold,
      'salary_per_shift': salaryPerShift.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
    };
  }

  String getFormattedShiftTime() {
    return '$checkInTime - $checkOutTime';
  }

  bool isLate(DateTime checkInTime) {
    final shiftStartTime = DateFormat('HH:mm:ss').parse(this.checkInTime);
    final actualCheckInTime = DateFormat('HH:mm:ss').format(checkInTime);
    final parsedActualCheckInTime =
        DateFormat('HH:mm:ss').parse(actualCheckInTime);

    final toleranceMinutes = Duration(minutes: lateTolerance);
    final maxAllowedTime = shiftStartTime.add(toleranceMinutes);

    return parsedActualCheckInTime.isAfter(maxAllowedTime);
  }
}
