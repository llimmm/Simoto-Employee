import 'package:get/get.dart';
import 'SharedAttendanceController.dart';

class AttendanceController extends GetxController {
  // Get shared attendance controller
  SharedAttendanceController get attendanceController =>
      SharedAttendanceController.to;

  // Delegate all attendance-related operations to shared controller
  RxBool get hasCheckedIn => attendanceController.hasCheckedIn;
  RxString get selectedShift => attendanceController.selectedShift;
  RxDouble get attendancePercentage =>
      attendanceController.attendancePercentage;

  void setShift(String shiftNumber) =>
      attendanceController.setShift(shiftNumber);
  void checkIn() => attendanceController.checkIn();
  String getShiftTime(String shift) => attendanceController.getShiftTime(shift);
  String getCurrentDateFormatted() =>
      attendanceController.getCurrentDateFormatted();

  @override
  void onInit() {
    super.onInit();
    // Initialize attendance controller and set up shift detection
    attendanceController.determineShift();
    ever(selectedShift, (_) => attendanceController.determineShift());
  }
}
