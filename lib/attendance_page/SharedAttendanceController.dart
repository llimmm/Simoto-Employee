import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kliktoko/storage/storage_service.dart';

class SharedAttendanceController extends GetxController {
  
  static SharedAttendanceController get to => Get.find();

  // Observable variables for attendance state
  final RxBool hasCheckedIn = false.obs;
  final RxString selectedShift = '1'.obs;
  final RxDouble attendancePercentage = 0.85.obs;
  final RxString username = ''.obs;
  
  // Storage service for user data
  final StorageService _storageService = StorageService();

  // Automatically determine shift based on current time
  void determineShift() {
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute; // Convert to minutes

    // Shift 1: 07:30-14:30 (450-870 minutes)
    // Shift 2: 14:30-21:30 (870-1290 minutes)
    if (currentTime >= 450 && currentTime < 870) {
      selectedShift.value = '1';
    } else if (currentTime >= 870 && currentTime < 1290) {
      selectedShift.value = '2';
    }
  }

  // Method to handle check-in
  void checkIn() {
    hasCheckedIn.value = true;
    // Add your API call or business logic here
  }

  // Get formatted shift time
  String getShiftTime(String shift) {
    switch (shift) {
      case '1':
        return '08:00 - 14:00';
      case '2':
        return '14:00 - 21:00';
      case '3':
        return '21:00 - 08:00';
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
      await _storageService.init();
      final userData = await _storageService.getUserData();
      if (userData != null && userData.containsKey('name')) {
        username.value = userData['name'];
        print('Loaded username from storage in SharedAttendanceController: ${username.value}');
      }
    } catch (e) {
      print('Error loading user data in SharedAttendanceController: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    determineShift(); // Set initial shift based on current time
    loadUserData(); // Load user data from storage
    // Schedule periodic shift updates
    ever(selectedShift, (_) => determineShift());
  }

  void setShift(String shiftNumber) {
    selectedShift.value = shiftNumber;
  }
}