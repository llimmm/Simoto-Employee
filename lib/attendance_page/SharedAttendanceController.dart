import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:kliktoko/storage/storage_service.dart';
import 'package:kliktoko/attendance_page/AttendanceModel.dart';
import 'package:kliktoko/attendance_page/AttendanceApiService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SharedAttendanceController extends GetxController {
  
  static SharedAttendanceController get to => Get.find<SharedAttendanceController>();

  // Observable variables for attendance state
  final RxBool hasCheckedIn = false.obs;
  final RxBool hasCheckedOut = false.obs; // New observable for check-out status
  final RxBool isLate = false.obs; // New observable for late status
  final RxString selectedShift = '1'.obs;
  final RxDouble attendancePercentage = 0.85.obs;
  final RxString username = ''.obs;
  final RxString userId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isOutsideShiftHours = false.obs; // New observable for tracking outside shift hours
  
  // New observables for attendance history
  final RxList<Map<String, dynamic>> attendanceHistory = <Map<String, dynamic>>[].obs;
  final RxBool isHistoryLoading = false.obs;
  
  // Observable model for current attendance
  final Rx<AttendanceModel> currentAttendance = AttendanceModel.empty().obs;
  
  // Services
  final StorageService _storageService = StorageService();
  final AttendanceApiService _attendanceService = AttendanceApiService();
  
  // API service base URL - matches the one in ApiService.dart
  static const String baseUrl = 'https://kliktoko.rplrus.com';

  // Ensure controller is registered
  static void ensureInitialized() {
    if (!Get.isRegistered<SharedAttendanceController>()) {
      Get.put(SharedAttendanceController());
    }
  }

  // Automatically determine shift based on current time
  void determineShift() {
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute; // Convert to minutes

    // Check if outside shift hours (after 21:30 or before 07:30)
    isOutsideShiftHours.value = (currentTime >= 1290 || currentTime < 450);

    // Shift 1: 07:30-14:30 (450-870 minutes)
    // Shift 2: 14:30-21:30 (870-1290 minutes)
    // After Shift 2: Display "Selamat Tidur!"
    if (currentTime >= 450 && currentTime < 870) {
      selectedShift.value = '1';
    } else if (currentTime >= 870 && currentTime < 1290) {
      selectedShift.value = '2';
    } else {
      // After Shift 2 or before Shift 1, just use Shift 2 as reference
      selectedShift.value = '2';
    }
  }

  // Method specifically to check if user has already checked in today
  Future<void> checkAttendanceStatus() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      // Try to get token
      final token = await _storageService.getToken();
      if (token == null) {
        errorMessage.value = 'No authentication token found. Please login.';
        hasError.value = true;
        return;
      }
      
      // Log the check attempt
      print('🔍 Checking attendance status with token: ${token.substring(0, _min(token.length, 10))}...');
      
      // Check attendance using specialized service
      final attendance = await _attendanceService.checkAttendanceStatus();
      
      // Update observable values based on result
      hasCheckedIn.value = attendance.isCheckedIn;
      isLate.value = attendance.isLate;
      hasCheckedOut.value = attendance.hasCheckedOut;
      currentAttendance.value = attendance;
      
      print('✅ Attendance status check completed: Checked in = ${hasCheckedIn.value}, Late = ${isLate.value}, Checked out = ${hasCheckedOut.value}');
      
      // If checked in, ensure we update the shift ID too
      if (attendance.isCheckedIn && attendance.shiftId.isNotEmpty) {
        selectedShift.value = attendance.shiftId;
        print('👉 Updated shift to: ${selectedShift.value}');
      }
    } catch (e) {
      print('❌ Error checking attendance status: $e');
      hasError.value = true;
      errorMessage.value = 'Could not verify attendance status. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Method to handle check-in
  Future<void> checkIn() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      // First check if already checked in
      await checkAttendanceStatus();
      
      if (hasCheckedIn.value) {
        print('⚠️ User has already checked in today');
        return; // Already checked in, no need to proceed
      }
      
      print('🔄 Attempting check-in with shift: ${selectedShift.value}');
      
      // Perform check-in using dedicated service
      final checkInResult = await _attendanceService.checkIn(selectedShift.value);
      
      // Force updates to the observables
      hasCheckedIn.value = true; // Force set to true on successful check-in
      isLate.value = checkInResult.isLate; // Update late status
      hasCheckedOut.value = checkInResult.hasCheckedOut; // Update check-out status
      currentAttendance.value = checkInResult;
      
      print('✅ Check-in completed: Status = ${hasCheckedIn.value}, Late = ${isLate.value}');
      
      // Force refresh after check-in to ensure data is current
      await Future.delayed(Duration(milliseconds: 500));
      await checkAttendanceStatus();
      
      // Refresh attendance history after checking in
      await loadAttendanceHistory();
      
    } catch (e) {
      print('❌ Error during check-in: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to check in: ${e.toString()}';
      throw e; // Re-throw for the controller to handle
    } finally {
      isLoading.value = false;
    }
  }

  // Method to handle check-out
  Future<void> checkOut() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      // First check current status
      await checkAttendanceStatus();
      
      if (!hasCheckedIn.value) {
        print('⚠️ User has not checked in today yet');
        hasError.value = true;
        errorMessage.value = 'Anda belum melakukan check-in hari ini.';
        return;
      }
      
      if (hasCheckedOut.value) {
        print('⚠️ User has already checked out today');
        hasError.value = true;
        errorMessage.value = 'Anda sudah melakukan check-out hari ini.';
        return;
      }
      
      print('🔄 Attempting check-out');
      
      // Perform check-out using dedicated service
      final checkOutResult = await _attendanceService.checkOut();
      
      // Update the observables
      hasCheckedOut.value = true;
      currentAttendance.value = checkOutResult;
      
      print('✅ Check-out completed. Check-out time: ${checkOutResult.checkOutTime}');
      
      // Force refresh after check-out to ensure data is current
      await Future.delayed(Duration(milliseconds: 500));
      await checkAttendanceStatus();
      
      // Refresh attendance history after checking out
      await loadAttendanceHistory();
      
    } catch (e) {
      print('❌ Error during check-out: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to check out: ${e.toString()}';
      throw e; // Re-throw for the controller to handle
    } finally {
      isLoading.value = false;
    }
  }

  // New method to fetch attendance history
  Future<void> loadAttendanceHistory() async {
    try {
      print('🔄 Loading attendance history');
      isHistoryLoading.value = true;
      
      // Get the token
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        print('❌ No token available for attendance history request');
        return;
      }
      
      final headers = await _getHeaders(token);
      
      // Fetch attendance history
      final response = await http.get(
        Uri.parse('$baseUrl/api/attendance/history'),
        headers: headers,
      );
      
      print('📊 Attendance history API response status: ${response.statusCode}');
      
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
        
        // Convert to list of maps and sort by date (most recent first)
        final historyList = historyData.map((item) => item as Map<String, dynamic>).toList();
        
        // Sort by date (most recent first)
        historyList.sort((a, b) {
          String dateA = a['date'] ?? a['attendance_date'] ?? a['created_at']?.toString() ?? '';
          String dateB = b['date'] ?? b['attendance_date'] ?? b['created_at']?.toString() ?? '';
          
          // Parse dates for comparison
          DateTime? parsedDateA;
          DateTime? parsedDateB;
          
          try {
            parsedDateA = DateTime.parse(dateA);
          } catch (e) {
            print('Error parsing date A: $e');
          }
          
          try {
            parsedDateB = DateTime.parse(dateB);
          } catch (e) {
            print('Error parsing date B: $e');
          }
          
          // If both dates parsed successfully, compare them
          if (parsedDateA != null && parsedDateB != null) {
            return parsedDateB.compareTo(parsedDateA); // Descending order
          }
          
          // Fallback to string comparison if parsing failed
          return dateB.compareTo(dateA);
        });
        
        attendanceHistory.value = historyList;
        print('✅ Loaded ${historyList.length} attendance history records');
      } else {
        print('❌ Failed to load attendance history: ${response.statusCode}');
        attendanceHistory.value = [];
      }
    } catch (e) {
      print('❌ Error loading attendance history: $e');
      attendanceHistory.value = [];
    } finally {
      isHistoryLoading.value = false;
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

  // Get formatted shift time
  String getShiftTime(String shift) {
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute; // Convert to minutes

    // If it's after 21:30 (1290 minutes) or before 07:30 (450 minutes),
    // it's outside of any shift - night time
    if (currentTime >= 1290 || currentTime < 450) {
      return 'Selamat Tidur!';
    }

    switch (shift) {
      case '1':
        return '07:30 - 14:30'; // Updated to match late detection logic
      case '2':
        return '14:30 - 21:30'; // Updated to match late detection logic
      default:
        return '07:30 - 14:30';
    }
  }

  // Get current date formatted
  String getCurrentDateFormatted() {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
  }

  // Load user data from storage
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      
      // Initialize storage service
      await _storageService.init();
      
      // Check if user is logged in
      final isLoggedIn = await _storageService.isLoggedIn();
      if (!isLoggedIn) {
        print('❌ User is not logged in');
        return;
      }
      
      // Get user data
      final userData = await _storageService.getUserData();
      if (userData != null) {
        // Extract user information
        if (userData.containsKey('name')) {
          username.value = userData['name'];
        }
        
        if (userData.containsKey('id')) {
          userId.value = userData['id'].toString();
        }
        
        print('👤 Loaded user data: Name=${username.value}, ID=${userId.value}');
      } else {
        print('⚠️ No user data found in storage');
      }
      
      // Check attendance status when loading user data
      await checkAttendanceStatus();
      
    } catch (e) {
      print('❌ Error loading user data: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to load user data';
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method for min function
  int _min(int a, int b) {
    return a < b ? a : b;
  }

  @override
  void onInit() {
    super.onInit();
    print('➡️ SharedAttendanceController initialized');
    determineShift(); // Set initial shift based on current time
    
    // Load user data immediately
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadUserData();
      // Load attendance history after user data
      await loadAttendanceHistory();
    });
    
    // Schedule periodic shift updates and attendance checks
    Timer.periodic(Duration(minutes: 1), (_) {
      determineShift(); // Update shift based on current time
    });
    
    Timer.periodic(Duration(minutes: 5), (_) async {
      await checkAttendanceStatus(); // Periodically verify attendance status
    });
    
    // Refresh attendance history every 15 minutes
    Timer.periodic(Duration(minutes: 15), (_) async {
      await loadAttendanceHistory();
    });
  }

  void setShift(String shiftNumber) {
    selectedShift.value = shiftNumber;
    print('👉 Shift manually set to: $shiftNumber');
  }
}