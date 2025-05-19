import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shift_model.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  static const String baseUrl = 'https://kliktoko.rplrus.com/api';

  final String token;

  AttendanceService({required this.token});

  Future<Map<String, dynamic>> checkShiftStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shifts/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = json.decode(response.body);
      return {
        'message': data['message'],
        'isActive': data['is_active'] ?? false,
        'data': data['data'],
      };
    } catch (e) {
      throw Exception('Gagal mengecek status shift: $e');
    }
  }

  Future<AttendanceModel> checkIn() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance/check-in'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = json.decode(response.body);
      if (data['message'] != null && data['message'] == 'Check-in berhasil') {
        return AttendanceModel.fromJson(data['data']['attendance']);
      } else {
        throw Exception(data['message'] ?? 'Gagal melakukan check-in');
      }
    } catch (e) {
      throw Exception('Gagal melakukan check-in: $e');
    }
  }

  Future<AttendanceModel> checkOut() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance/check-out'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = json.decode(response.body);
      if (data['message'] != null && data['message'] == 'Check-out berhasil') {
        return AttendanceModel.fromJson(data['data']['attendance']);
      } else {
        throw Exception(data['message'] ?? 'Gagal melakukan check-out');
      }
    } catch (e) {
      throw Exception('Gagal melakukan check-out: $e');
    }
  }

  Future<List<ShiftModel>> getShifts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shifts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = json.decode(response.body);
      if (data['data'] != null) {
        return (data['data'] as List)
            .map((shift) => ShiftModel.fromJson(shift))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Gagal mengambil data shift: $e');
    }
  }
}