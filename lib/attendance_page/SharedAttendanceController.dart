import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:kliktoko/attendance_page/AttendanceApiService';
import 'dart:async';
import 'package:kliktoko/storage/storage_service.dart';
import 'package:kliktoko/attendance_page/AttendanceModel.dart';

class SharedAttendanceController extends GetxController {
  
  static SharedAttendanceController get to => Get.find<SharedAttendanceController>();

  // Observable variables for attendance state
  final RxBool hasCheckedIn = false.obs;
  final RxString selectedShift = '1'.obs;
  final RxDouble attendancePercentage = 0.85.obs;
  final RxString username = ''.obs;
  final RxString userId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Observable model for current attendance
  final Rx<AttendanceModel> currentAttendance = AttendanceModel.empty().obs;
  
  // Services
  final StorageService _storageService = StorageService();
  final AttendanceApiService _attendanceService = AttendanceApiService();

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

    // Shift 1: 07:30-14:30 (450-870 minutes)
    // Shift 2: 14:30-21:30 (870-1290 minutes)
    // After Shift 2: Display "Selamat Malam!"
    if (currentTime >= 450 && currentTime < 870) {
      selectedShift.value = '1';
    } else if (currentTime >= 870 && currentTime < 1290) {
      selectedShift.value = '2';
    } else {
      // After Shift 2 or before Shift 1, just show Shift 2 as the last valid shift
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
      currentAttendance.value = attendance;
      
      print('✅ Attendance status check completed: Checked in = ${hasCheckedIn.value}');
      
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
      currentAttendance.value = checkInResult;
      
      print('✅ Check-in completed: Status = ${hasCheckedIn.value}');
      
      // Force refresh after check-in to ensure data is current
      await Future.delayed(Duration(milliseconds: 500));
      await checkAttendanceStatus();
      
    } catch (e) {
      print('❌ Error during check-in: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to check in: ${e.toString()}';
      throw e; // Re-throw for the controller to handle
    } finally {
      isLoading.value = false;
    }
  }

  // Get formatted shift time
  String getShiftTime(String shift) {
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute; // Convert to minutes

    switch (shift) {
      case '1':
        return '08:00 - 14:00';
      case '2':
        // If current time is after 21:30 (1290 minutes) or before 07:30 (450 minutes),
        // return "Selamat Malam!" instead of regular shift time
        if (currentTime >= 1290 || currentTime < 450) {
          return 'Selamat Malam!';
        }
        return '14:00 - 21:00';
      default:
        return '08:00 - 14:00';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadUserData();
    });
    
    // Schedule periodic shift updates and attendance checks
    Timer.periodic(Duration(minutes: 1), (_) {
      determineShift(); // Update shift based on current time
    });
    
    Timer.periodic(Duration(minutes: 5), (_) {
      checkAttendanceStatus(); // Periodically verify attendance status
    });
  }

  void setShift(String shiftNumber) {
    selectedShift.value = shiftNumber;
    print('👉 Shift manually set to: $shiftNumber');
  }
}