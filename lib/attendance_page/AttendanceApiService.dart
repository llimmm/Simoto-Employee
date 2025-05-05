import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:kliktoko/attendance_page/AttendanceModel.dart';
import 'package:kliktoko/storage/storage_service.dart';
import 'package:http/http.dart' as http;

class AttendanceApiService {
  static const String baseUrl = 'https://kliktoko.rplrus.com';
  
  final http.Client _client = http.Client();
  final StorageService _storageService = StorageService();

  // Check attendance status using the status API endpoint
  Future<AttendanceModel> checkAttendanceStatus() async {
    try {
      // Get token
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token available. Please login first.');
      }
      
      // Get current date in API expected format
      final today = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(today);
      
      // Update to use the status endpoint if available
      final response = await _client.get(
        Uri.parse('$baseUrl/api/attendance/status?date=$todayStr'),
        headers: await _getHeaders(token),
      );

      print('Attendance status API response status: ${response.statusCode}');
      print('Attendance status API response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final jsonData = json.decode(response.body);
          
          // Handle different API response structures
          Map<String, dynamic> attendanceData = {};
          
          if (jsonData is Map<String, dynamic>) {
            if (jsonData.containsKey('data')) {
              attendanceData = jsonData['data'];
            } else {
              attendanceData = jsonData;
            }
          }
          
          // Create AttendanceModel from response
          return AttendanceModel.fromJson(attendanceData);
        } catch (e) {
          print('Error parsing attendance status response: $e');
          return AttendanceModel.empty(); // Return empty model on parse error
        }
      } else {
        // Fallback to checking attendance history
        return await _getAttendanceStatusFromHistory(todayStr);
      }
    } catch (e) {
      print('Error checking attendance status: $e');
      return AttendanceModel.empty(); // Return empty model on error
    }
  }
  
  // Method to handle check-in
  Future<AttendanceModel> checkIn(String shiftId) async {
    try {
      // Get token
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token available. Please login first.');
      }
      
      // Prepare request body
      final body = json.encode({
        'shift_id': shiftId,
      });
      
      print('Sending check-in request with shift: $shiftId');
      
      // Make API call
      final response = await _client.post(
        Uri.parse('$baseUrl/api/attendance/check-in'),
        headers: await _getHeaders(token),
        body: body,
      );

      print('Check-in API response status: ${response.statusCode}');
      print('Check-in API response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final jsonData = json.decode(response.body);
          
          // Handle different API response structures
          Map<String, dynamic> attendanceData = {};
          
          if (jsonData is Map<String, dynamic>) {
            if (jsonData.containsKey('data')) {
              attendanceData = jsonData['data'];
            } else {
              attendanceData = jsonData;
            }
            
            // If there's no specific attendance data, create a simple "success" model
            if (attendanceData.isEmpty && (jsonData.containsKey('success') || jsonData.containsKey('message'))) {
              final now = DateTime.now();
              // Determine if late based on current time and shift
              bool isLate = false;
              if (shiftId == '1') {
                // Shift 1: Late after 7:30 AM
                isLate = now.hour > 7 || (now.hour == 7 && now.minute > 30);
              } else if (shiftId == '2') {
                // Shift 2: Late after 2:30 PM
                isLate = now.hour > 14 || (now.hour == 14 && now.minute > 30);
              }
              
              return AttendanceModel(
                isCheckedIn: true,
                date: DateFormat('yyyy-MM-dd').format(now),
                shiftId: shiftId,
                checkInTime: DateFormat('HH:mm:ss').format(now),
                isLate: isLate,
              );
            }
          }
          
          // Create AttendanceModel from response
          final model = AttendanceModel.fromJson(attendanceData);
          
          // Force isCheckedIn to true on successful check-in
          return AttendanceModel(
            isCheckedIn: true,
            date: model.date,
            shiftId: model.shiftId,
            checkInTime: model.checkInTime,
            checkOutTime: model.checkOutTime,
            username: model.username,
            userId: model.userId,
            isLate: model.isLate,
          );
        } catch (e) {
          print('Error parsing check-in response: $e');
          // Return a basic success model on parse error but successful HTTP response
          final now = DateTime.now();
          // Determine if late based on current time and shift
          bool isLate = false;
          if (shiftId == '1') {
            // Shift 1: Late after 7:30 AM
            isLate = now.hour > 7 || (now.hour == 7 && now.minute > 30);
          } else if (shiftId == '2') {
            // Shift 2: Late after 2:30 PM
            isLate = now.hour > 14 || (now.hour == 14 && now.minute > 30);
          }
          
          return AttendanceModel(
            isCheckedIn: true,
            date: DateFormat('yyyy-MM-dd').format(now),
            shiftId: shiftId,
            checkInTime: DateFormat('HH:mm:ss').format(now),
            isLate: isLate,
          );
        }
      } else {
        throw Exception('Check-in failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during check-in: $e');
      throw e; // Re-throw for controller to handle
    }
  }
  
  // Method to handle check-out
  Future<AttendanceModel> checkOut() async {
    try {
      // Get token
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token available. Please login first.');
      }
      
      // Make API call
      final response = await _client.post(
        Uri.parse('$baseUrl/api/attendance/check-out'),
        headers: await _getHeaders(token),
      );

      print('Check-out API response status: ${response.statusCode}');
      print('Check-out API response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final jsonData = json.decode(response.body);
          
          // Handle different API response structures
          Map<String, dynamic> attendanceData = {};
          
          if (jsonData is Map<String, dynamic>) {
            if (jsonData.containsKey('data')) {
              attendanceData = jsonData['data'];
            } else {
              attendanceData = jsonData;
            }
            
            // If there's no specific attendance data, but success message exists
            if (attendanceData.isEmpty && (jsonData.containsKey('success') || jsonData.containsKey('message'))) {
              // Get current attendance first to update with check-out time
              final currentAttendance = await checkAttendanceStatus();
              return AttendanceModel(
                isCheckedIn: currentAttendance.isCheckedIn,
                date: currentAttendance.date,
                shiftId: currentAttendance.shiftId,
                checkInTime: currentAttendance.checkInTime,
                checkOutTime: DateFormat('HH:mm:ss').format(DateTime.now()),
                username: currentAttendance.username,
                userId: currentAttendance.userId,
                isLate: currentAttendance.isLate,
              );
            }
          }
          
          // Create AttendanceModel from response
          return AttendanceModel.fromJson(attendanceData);
        } catch (e) {
          print('Error parsing check-out response: $e');
          // Get current attendance first to update with check-out time
          final currentAttendance = await checkAttendanceStatus();
          return AttendanceModel(
            isCheckedIn: currentAttendance.isCheckedIn,
            date: currentAttendance.date,
            shiftId: currentAttendance.shiftId,
            checkInTime: currentAttendance.checkInTime,
            checkOutTime: DateFormat('HH:mm:ss').format(DateTime.now()),
            username: currentAttendance.username,
            userId: currentAttendance.userId,
            isLate: currentAttendance.isLate,
          );
        }
      } else {
        throw Exception('Check-out failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during check-out: $e');
      throw e; // Re-throw for controller to handle
    }
  }
  
  // Helper method to extract attendance status from history
  Future<AttendanceModel> _getAttendanceStatusFromHistory(String dateStr) async {
    try {
      // Get token
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token available. Please login first.');
      }
      
      // Get attendance history
      final response = await _client.get(
        Uri.parse('$baseUrl/api/attendance/history'),
        headers: await _getHeaders(token),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);
        
        List<dynamic> historyData = [];
        
        // Handle different API response structures
        if (jsonData is List) {
          historyData = jsonData;
        } else if (jsonData is Map && jsonData.containsKey('data') && jsonData['data'] is List) {
          historyData = jsonData['data'];
        } else if (jsonData is Map && jsonData.containsKey('history') && jsonData['history'] is List) {
          historyData = jsonData['history'];
        }
        
        // Find entry for today
        final todayEntry = historyData.where((item) {
          final itemDate = item['date'] ?? item['created_at'] ?? '';
          return itemDate.toString().contains(dateStr);
        }).toList();
        
        if (todayEntry.isNotEmpty) {
          return AttendanceModel.fromJson(todayEntry.first);
        } else {
          return AttendanceModel.empty();
        }
      } else {
        return AttendanceModel.empty();
      }
    } catch (e) {
      print('Error getting attendance from history: $e');
      return AttendanceModel.empty();
    }
  }
  
  // Helper to get headers for API requests
  Future<Map<String, String>> _getHeaders([String? token]) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        // Try to get token from storage if not provided
        final storedToken = await _storageService.getToken();
        if (storedToken != null && storedToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $storedToken';
        }
      }
    } catch (e) {
      print('Error setting auth headers: $e');
    }

    return headers;
  }
}