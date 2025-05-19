import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/attendance_service.dart';
import '../models/attendance_model.dart';
import '../models/shift_model.dart';

class AttendanceController extends GetxController {
  final AttendanceService _service;
  final RxBool isLoading = false.obs;
  final RxString statusMessage = ''.obs;
  final RxBool isActiveShift = false.obs;
  final Rx<ShiftModel?> currentShift = Rx<ShiftModel?>(null);
  final Rx<AttendanceModel?> currentAttendance = Rx<AttendanceModel?>(null);
  final RxBool isCheckedIn = false.obs;
  final RxBool isCheckedOut = false.obs;

  AttendanceController({required String token})
      : _service = AttendanceService(token: token);

  @override
  void onInit() {
    super.onInit();
    checkShiftStatus();
    loadShifts();

    // Set up periodic status check every 5 minutes
    ever(isActiveShift, (_) {
      if (isActiveShift.value) {
        Future.delayed(const Duration(minutes: 5), checkShiftStatus);
      }
    });
  }

  Future<void> checkShiftStatus() async {
    try {
      isLoading.value = true;
      final status = await _service.checkShiftStatus();

      statusMessage.value = status['message'] ?? '';

      // Reset all states first
      isActiveShift.value = false;
      isCheckedIn.value = false;
      isCheckedOut.value = false;

      // Set states based on API response
      if (status['message'] == 'Anda belum absen di shift 1') {
        // User has an active shift but hasn't checked in yet
        isActiveShift.value = true;
        isCheckedIn.value = false;
        isCheckedOut.value = false;
      } else if (status['message'] == 'User aktif' ||
          status['message'] == 'User sedang aktif') {
        // User is currently checked in
        isActiveShift.value = true;
        isCheckedIn.value = true;
        isCheckedOut.value = false;
      } else if (status['message'] == 'User sudah checkout') {
        // User has completed attendance for the day
        isActiveShift.value = true;
        isCheckedIn.value = true;
        isCheckedOut.value = true;
      } else if (status['message'] == 'Anda belum absen di shift 2') {
        // User has completed attendance for the day
        isActiveShift.value = true;
        isCheckedIn.value = true;
        isCheckedOut.value = true;
      } else {
        // No active shift or other states
        isActiveShift.value = false;
        isCheckedIn.value = false;
        isCheckedOut.value = false;
      }

      // Load current attendance data if available
      if (status['data'] != null) {
        try {
          currentAttendance.value = AttendanceModel.fromJson(status['data']);
        } catch (e) {
          print('Error parsing attendance data: $e');
        }
      }
    } catch (e) {
      statusMessage.value = 'Gagal mengecek status: $e';
      isActiveShift.value = false;
      isCheckedIn.value = false;
      isCheckedOut.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> performCheckIn() async {
    if (!canCheckIn()) {
      statusMessage.value = 'Tidak dapat melakukan check-in saat ini';
      return;
    }

    try {
      isLoading.value = true;
      final attendance = await _service.checkIn();

      if (attendance != null) {
        currentAttendance.value = attendance;
        isCheckedIn.value = true;
        isCheckedOut.value = false;
        statusMessage.value = 'Check-in berhasil';

        // Refresh status after successful check-in
        await Future.delayed(const Duration(milliseconds: 500));
        await checkShiftStatus();
      } else {
        statusMessage.value = 'Gagal melakukan check-in';
      }
    } catch (e) {
      statusMessage.value = 'Gagal melakukan check-in: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> performCheckOut() async {
    if (!canCheckOut()) {
      statusMessage.value = 'Tidak dapat melakukan check-out saat ini';
      return;
    }

    try {
      isLoading.value = true;
      final attendance = await _service.checkOut();

      if (attendance != null) {
        currentAttendance.value = attendance;
        isCheckedOut.value = true;
        statusMessage.value = 'Check-out berhasil';

        // Refresh status after successful check-out
        await Future.delayed(const Duration(milliseconds: 500));
        await checkShiftStatus();
      } else {
        statusMessage.value = 'Gagal melakukan check-out';
      }
    } catch (e) {
      statusMessage.value = 'Gagal melakukan check-out: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadShifts() async {
    try {
      final shifts = await _service.getShifts();
      if (shifts.isNotEmpty) {
        // Find current shift based on time
        final now = DateTime.now();
        final currentTime = DateFormat('HH:mm:ss').format(now);

        // Try to find an active shift
        for (final shift in shifts) {
          try {
            final shiftStart = DateFormat('HH:mm:ss').parse(shift.checkInTime);
            final shiftEnd = DateFormat('HH:mm:ss').parse(shift.checkOutTime);
            final current = DateFormat('HH:mm:ss').parse(currentTime);

            // Check if current time is within shift time (allowing for late arrival)
            if (current
                    .isAfter(shiftStart.subtract(const Duration(hours: 1))) &&
                current.isBefore(shiftEnd.add(const Duration(hours: 1)))) {
              currentShift.value = shift;
              break;
            }
          } catch (e) {
            print('Error parsing shift times: $e');
          }
        }

        // If no shift found, set the first one as default
        if (currentShift.value == null && shifts.isNotEmpty) {
          currentShift.value = shifts.first;
        }
      }
    } catch (e) {
      print('Gagal memuat data shift: $e');
    }
  }

  bool canCheckIn() {
    return !isLoading.value &&
        isActiveShift.value &&
        !isCheckedIn.value &&
        !isCheckedOut.value &&
        (statusMessage.value == 'Anda belum absen di shift 1' ||
            statusMessage.value == 'Anda belum absen di shift 2');
  }

  bool canCheckOut() {
    return !isLoading.value &&
        isActiveShift.value &&
        isCheckedIn.value &&
        !isCheckedOut.value &&
        statusMessage.value == 'User sedang aktif';
  }

  // Helper method to get readable status
  String getReadableStatus() {
    if (isLoading.value) {
      return 'Memuat...';
    } else if (isCheckedOut.value) {
      return 'Sudah Check-out';
    } else if (isCheckedIn.value) {
      return 'Sudah Check-in';
    } else if (isActiveShift.value &&
        statusMessage.value == 'Anda belum aktif') {
      return 'Belum Check-in';
    } else if (!isActiveShift.value) {
      return 'Tidak Ada Shift Aktif';
    } else {
      return statusMessage.value.isNotEmpty
          ? statusMessage.value
          : 'Status Tidak Diketahui';
    }
  }

  // Debug method to check current state
  void printCurrentState() {
    print('=== Attendance Controller State ===');
    print('isLoading: ${isLoading.value}');
    print('statusMessage: ${statusMessage.value}');
    print('isActiveShift: ${isActiveShift.value}');
    print('isCheckedIn: ${isCheckedIn.value}');
    print('isCheckedOut: ${isCheckedOut.value}');
    print('canCheckIn: ${canCheckIn()}');
    print('canCheckOut: ${canCheckOut()}');
    print('currentShift: ${currentShift.value?.name ?? 'null'}');
    print('currentAttendance: ${currentAttendance.value?.id ?? 'null'}');
    print('===================================');
  }
}
