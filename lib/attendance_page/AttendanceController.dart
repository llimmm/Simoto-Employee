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
  RxBool get hasCheckedOut => attendanceController.hasCheckedOut;
  RxBool get isLate => attendanceController.isLate;
  RxString get selectedShift => attendanceController.selectedShift;
  RxDouble get attendancePercentage =>
      attendanceController.attendancePercentage;
  RxBool get isLoading => attendanceController.isLoading;
  RxBool get hasError => attendanceController.hasError;
  RxString get errorMessage => attendanceController.errorMessage;
  Rx<AttendanceModel> get currentAttendance =>
      attendanceController.currentAttendance;
  RxString get username => attendanceController.username;

  // New getters for attendance history
  RxList<Map<String, dynamic>> get attendanceHistory =>
      attendanceController.attendanceHistory;
  RxBool get isHistoryLoading => attendanceController.isHistoryLoading;

  // Function to check attendance status from server
  Future<void> checkAttendanceStatus() async {
    try {
      await attendanceController.checkAttendanceStatus();
    } catch (e) {
      print('Error checking attendance status in controller: $e');
    }
  }

  // Function to load attendance history from server
  Future<void> loadAttendanceHistory() async {
    try {
      await attendanceController.loadAttendanceHistory();
    } catch (e) {
      print('Error loading attendance history in controller: $e');
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

      // Refresh attendance history after check-in
      await loadAttendanceHistory();

      // Show success message with appropriate text based on status
      String title = 'Absen Berhasil';
      String message = isLate.value
          ? 'Kehadiran anda telah tercatat, namun anda terlambat'
          : 'Kehadiran anda telah tercatat';

      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
            isLate.value ? Colors.orange[300] : const Color(0xFFAED15C),
        colorText: const Color(0xFF282828),
        duration: Duration(seconds: isLate.value ? 5 : 3),
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

  Future<void> checkOut() async {
    // First check current status (directly from server)
    await checkAttendanceStatus();

    if (!hasCheckedIn.value) {
      // Not checked in yet, show error message
      Get.snackbar(
        'Belum Absen',
        'Anda belum melakukan check-in hari ini',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return;
    }

    if (hasCheckedOut.value) {
      // Already checked out, show message
      Get.snackbar(
        'Sudah Check-out',
        'Anda sudah melakukan check-out hari ini',
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
      // Attempt to check out via the shared controller
      await attendanceController.checkOut();

      // Make sure to close the loading dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Force set checked out to true immediately for better UI response
      hasCheckedOut.value = true;

      // Force status refresh after check-out
      await Future.delayed(Duration(milliseconds: 800));
      await checkAttendanceStatus();

      // Refresh attendance history after check-out
      await loadAttendanceHistory();

      // Show success message
      Get.snackbar(
        'Check-out Berhasil',
        'Terima kasih atas pekerjaan anda hari ini',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFAED15C),
        colorText: const Color(0xFF282828),
      );
    } catch (e) {
      // Make sure to close the loading dialog even on error
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      print('Error in AttendanceController.checkOut: $e');

      // Show error message to user
      Get.snackbar(
        'Check-out Error',
        'Terjadi masalah saat proses check-out. Silakan coba lagi.',
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

      // Load attendance history
      await loadAttendanceHistory();
    });

    // Listen for changes in check-in status
    ever(hasCheckedIn, (bool checked) {
      print('Check-in status changed: $checked');
    });

    // Listen for changes in check-out status
    ever(hasCheckedOut, (bool checkedOut) {
      print('Check-out status changed: $checkedOut');
    });

    // Listen for changes in late status
    ever(isLate, (bool late) {
      print('Late status changed: $late');
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
