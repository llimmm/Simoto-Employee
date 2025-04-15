import 'package:get/get.dart';

class AttendanceController extends GetxController {
  // Reactive variables
  final RxBool _hasCheckedIn = false.obs;
  final RxInt _selectedShift = 1.obs;
  final RxDouble _attendancePercentage = 0.75.obs;

  // Getters
  bool get hasCheckedIn => _hasCheckedIn.value;
  int get selectedShift => _selectedShift.value;
  double get attendancePercentage => _attendancePercentage.value;

  // Methods
  void setShift(int shift) {
    _selectedShift.value = shift;
  }

  void checkIn() {
    _hasCheckedIn.value = true;
  }

  String getShiftTime(int shift) {
    switch (shift) {
      case 1:
        return "08:00 - 14:00";
      case 2:
        return "14:00 - 21:00";
      default:
        return "Unknown Shift";
    }
  }

  String getCurrentDateFormatted() {
    DateTime now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }
}
