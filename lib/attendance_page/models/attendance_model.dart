import 'package:kliktoko/attendance_page/models/shift_model.dart';

class AttendanceModel {
  final int id;
  final int userId;
  final int shiftId;
  final DateTime date;
  final DateTime checkIn;
  final DateTime? checkOut;
  final bool isLate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ShiftModel? shift;
  final UserModel? user;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.shiftId,
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.isLate,
    required this.createdAt,
    required this.updatedAt,
    this.shift,
    this.user,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      userId: json['user_id'],
      shiftId: json['shift_id'],
      date: DateTime.parse(json['date']),
      checkIn: DateTime.parse(json['check_in']),
      checkOut:
          json['check_out'] != null ? DateTime.parse(json['check_out']) : null,
      isLate: json['is_late'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      shift: json['shift'] != null ? ShiftModel.fromJson(json['shift']) : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shift_id': shiftId,
      'date': date.toIso8601String(),
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
      'is_late': isLate,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'shift': shift?.toJson(),
      'user': user?.toJson(),
    };
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int isActive;
  final String? deletedAt;
  final int isCheckedIn;
  final String? lastCheckIn;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.deletedAt,
    required this.isCheckedIn,
    this.lastCheckIn,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'],
      deletedAt: json['deleted_at'],
      isCheckedIn: json['is_checked_in'],
      lastCheckIn: json['last_check_in'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'deleted_at': deletedAt,
      'is_checked_in': isCheckedIn,
      'last_check_in': lastCheckIn,
    };
  }
}
