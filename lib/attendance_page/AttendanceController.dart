import 'package:get/get.dart';
import 'SharedAttendanceController.dart';
import 'package:flutter/material.dart';
import 'package:kliktoko/attendance_page/AttendanceModel.dart';

class AttendanceController extends GetxController {
  // Get shared attendance controller
  SharedAttendanceController get attendanceController {
    // Ensure the shared controller is registered
    SharedAttendanceController.ensureInitialized();
    return SharedAttendanceController.to;
  }

  // Delegate all attendance-related operations to shared controller
  RxBool get hasCheckedIn => attendanceController.hasCheckedIn;
  RxString get selectedShift => attendanceController.selectedShift;
  RxDouble get attendancePercentage =>
      attendanceController.attendancePercentage;
  RxBool get isLoading => attendanceController.isLoading;
  RxBool get hasError => attendanceController.hasError;
  RxString get errorMessage => attendanceController.errorMessage;
  Rx<AttendanceModel> get currentAttendance =>
      attendanceController.currentAttendance;
  RxString get username => attendanceController.username;

  // Function to check attendance status from server
  Future<void> checkAttendanceStatus() async {
    try {
      await attendanceController.checkAttendanceStatus();
    } catch (e) {
      print('Error checking attendance status in controller: $e');
    }
  }

  void setShift(String shiftNumber) =>
      attendanceController.setShift(shiftNumber);

  Future<void> checkIn() async {
    // First check if already checked in (directly from server)
    await checkAttendanceStatus();

    if (hasCheckedIn.value) {
      // Already checked in, show a message
      Get.snackbar(
        'Sudah Absen',
        'Anda sudah absen hari ini',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFAED15C),
        colorText: const Color(0xFF282828),
      );
      return;
    }

    // Show loading indicator
    final loadingDialog = _buildLoadingDialog();
    Get.dialog(loadingDialog, barrierDismissible: false);

    try {
      // Attempt to check in via the shared controller
      await attendanceController.checkIn();

      // Make sure to close the loading dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Force set checked in to true immediately for better UI response
      hasCheckedIn.value = true;

      // Force status refresh after check-in
      await Future.delayed(Duration(milliseconds: 800));
      await checkAttendanceStatus();

      // Show success message regardless of status check
      Get.snackbar(
        'Absen Berhasil',
        'Kehadiran anda telah tercatat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFAED15C),
        colorText: const Color(0xFF282828),
      );
    } catch (e) {
      // Make sure to close the loading dialog even on error
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      print('Error in AttendanceController.checkIn: $e');

      // Show error message to user
      Get.snackbar(
        'Check-in Error',
        'Terjadi masalah saat proses absen. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }

  Widget _buildLoadingDialog() {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAED15C)),
            ),
            const SizedBox(height: 15),
            const Text('Memproses...'),
          ],
        ),
      ),
    );
  }

  String getShiftTime(String shift) => attendanceController.getShiftTime(shift);
  String getCurrentDateFormatted() =>
      attendanceController.getCurrentDateFormatted();

  @override
  void onInit() {
    super.onInit();
    print('AttendanceController initialized');

    // Initialize attendance controller and set up shift detection
    attendanceController.determineShift();

    // Check attendance status immediately when controller initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkAttendanceStatus();
    });

    // Listen for changes in check-in status
    ever(hasCheckedIn, (bool checked) {
      print('Check-in status changed: $checked');
    });

    ever(selectedShift, (_) => print('Shift changed: ${selectedShift.value}'));

    // Listen for error messages
    ever(hasError, (bool hasErr) {
      if (hasErr && errorMessage.value.isNotEmpty) {
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
      }
    });
  }
}
