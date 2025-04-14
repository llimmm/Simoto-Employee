import 'package:get/get.dart';

class AttendanceController extends GetxController {
  // Singleton pattern
  static final AttendanceController _instance =
      AttendanceController._internal();

  factory AttendanceController() {
    return _instance;
  }

  AttendanceController._internal();

  // Observable state variables
  final _hasCheckedIn = false.obs;
  final _checkInTime = Rxn<DateTime>();
  final _selectedShift = 1.obs;

  // Getters
  bool get hasCheckedIn => _hasCheckedIn.value;
  DateTime? get checkInTime => _checkInTime.value;
  int get selectedShift => _selectedShift.value;

  // Methods
  void checkIn() {
    if (!_hasCheckedIn.value) {
      _hasCheckedIn.value = true;
      _checkInTime.value = DateTime.now();
    }
  }

  void reset() {
    _hasCheckedIn.value = false;
    _checkInTime.value = null;
  }

  void setShift(int shift) {
    if (shift == 1 || shift == 2) {
      _selectedShift.value = shift;
    }
  }

  String getShiftTime(int shift) {
    return shift == 1 ? '08:00 - 14:00' : '14:00 - 21:00';
  }

  // Calculate attendance percentage for current month
  double calculateAttendancePercentage() {
    // In a real app, this would use actual attendance data
    // For demo purposes, we'll return a fixed value
    return 0.5; // 50%
  }

  // Format check-in time
  String getFormattedCheckInTime() {
    if (_checkInTime.value == null) return '';
    return '${_checkInTime.value!.hour.toString().padLeft(2, '0')}:${_checkInTime.value!.minute.toString().padLeft(2, '0')}';
  }

  // Get current date formatted
  String getCurrentDateFormatted() {
    final now = DateTime.now();
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
