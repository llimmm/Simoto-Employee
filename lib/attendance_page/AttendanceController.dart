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

  // Perbaikan pada method checkIn
  Future<void> checkIn() async {
    // Show loading indicator
    final loadingDialog = _buildLoadingDialog();
    Get.dialog(loadingDialog, barrierDismissible: false);

    try {
      print('🔄 AttendanceController: Starting check-in process');

      // PERBAIKAN: Refresh status kehadiran terlebih dahulu
      await checkAttendanceStatus();

      // Check if already checked in
      if (hasCheckedIn.value) {
        // Already checked in, close dialog and show a message
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        print('⚠️ User already checked in today');
        Get.snackbar(
          'Sudah Absen',
          'Anda sudah absen hari ini',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFAED15C),
          colorText: const Color(0xFF282828),
        );
        return;
      }

      // PERBAIKAN: Ensure we have the correct shift selected
      print('📋 Selected shift: ${selectedShift.value}');
      attendanceController.determineShift();
      print('📋 Updated shift after determination: ${selectedShift.value}');

      // PERBAIKAN: Tambahkan retry logic untuk mengatasi gagal koneksi
      int retryCount = 0;
      const maxRetries = 2;

      while (retryCount <= maxRetries) {
        try {
          // Attempt to check in via the shared controller
          print(
              '🔄 Calling shared controller check-in method (attempt ${retryCount + 1})');
          await attendanceController.checkIn();
          print('✅ Shared controller check-in completed successfully');

          // Successfully checked in, break the retry loop
          break;
        } catch (e) {
          retryCount++;
          print('⚠️ Check-in attempt ${retryCount} failed: $e');

          // If this was the last retry, rethrow the error
          if (retryCount > maxRetries) {
            throw e;
          }

          // Wait before retry
          await Future.delayed(Duration(seconds: 1));
        }
      }

      // Make sure to close the loading dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // PERBAIKAN: Verifikasi status absensi setelah check-in
      await checkAttendanceStatus();

      // PERBAIKAN: Jika masih belum tercatat absen setelah semua upaya
      if (!hasCheckedIn.value) {
        Get.snackbar(
          'Perhatian',
          'Status absensi belum tercatat di sistem. Silakan coba lagi atau hubungi admin.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[300],
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
        return;
      }

      // Refresh attendance history after check-in
      print('🔄 Refreshing attendance history');
      await loadAttendanceHistory();
      print('✅ Attendance history refreshed');

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

      print('❌ Error in AttendanceController.checkIn: $e');

      // PERBAIKAN: Pesan error yang lebih spesifik
      String errorMessage =
          'Terjadi masalah saat proses absen. Silakan coba lagi.';

      // Customize error message based on the error type
      if (e.toString().contains('timeout')) {
        errorMessage = 'Koneksi timeout. Periksa jaringan Anda dan coba lagi.';
      } else if (e.toString().contains('No authentication token')) {
        errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
      } else if (e.toString().contains('already checked in')) {
        errorMessage = 'Anda sudah melakukan absen hari ini.';
      }

      // Show error message to user
      Get.snackbar(
        'Check-in Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );

      // Force check attendance status after error to ensure UI is in sync
      print('🔄 Checking attendance status after error');
      await checkAttendanceStatus();
    }
  }

  Future<void> checkOut() async {
    // Show loading indicator
    final loadingDialog = _buildLoadingDialog();
    Get.dialog(loadingDialog, barrierDismissible: false);

    try {
      // PERBAIKAN: Refresh status kehadiran terlebih dahulu
      await checkAttendanceStatus();

      // Check if not checked in
      if (!hasCheckedIn.value) {
        // Not checked in yet, close dialog and show error message
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        Get.snackbar(
          'Belum Absen',
          'Anda belum melakukan check-in hari ini',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
        return;
      }

      // Check if already checked out
      if (hasCheckedOut.value) {
        // Already checked out, close dialog and show message
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        Get.snackbar(
          'Sudah Check-out',
          'Anda sudah melakukan check-out hari ini',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFAED15C),
          colorText: const Color(0xFF282828),
        );
        return;
      }

      // PERBAIKAN: Tambahkan retry logic untuk mengatasi gagal koneksi
      int retryCount = 0;
      const maxRetries = 2;

      while (retryCount <= maxRetries) {
        try {
          // Attempt to check out via the shared controller
          await attendanceController.checkOut();

          // Successfully checked out, break the retry loop
          break;
        } catch (e) {
          retryCount++;
          print('⚠️ Check-out attempt ${retryCount} failed: $e');

          // If this was the last retry, rethrow the error
          if (retryCount > maxRetries) {
            throw e;
          }

          // Wait before retry
          await Future.delayed(Duration(seconds: 1));
        }
      }

      // Make sure to close the loading dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // PERBAIKAN: Verifikasi status check-out setelah API call
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

      print('❌ Error in AttendanceController.checkOut: $e');

      // PERBAIKAN: Pesan error yang lebih spesifik
      String errorMessage =
          'Terjadi masalah saat proses check-out. Silakan coba lagi.';

      // Customize error message based on the error type
      if (e.toString().contains('timeout')) {
        errorMessage = 'Koneksi timeout. Periksa jaringan Anda dan coba lagi.';
      } else if (e.toString().contains('No authentication token')) {
        errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
      }

      // Show error message to user
      Get.snackbar(
        'Check-out Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );

      // Force check attendance status after error to ensure UI is in sync
      await checkAttendanceStatus();
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
