class EmployeeController {
  // Singleton pattern
  static final EmployeeController _instance = EmployeeController._internal();
  
  factory EmployeeController() {
    return _instance;
  }
  
  EmployeeController._internal();
  
  // State variables
  bool _hasCheckedIn = false;
  DateTime? _checkInTime;
  
  // Getters
  bool get hasCheckedIn => _hasCheckedIn;
  DateTime? get checkInTime => _checkInTime;
  
  // Methods
  void checkIn() {
    if (!_hasCheckedIn) {
      _hasCheckedIn = true;
      _checkInTime = DateTime.now();
    }
  }
  
  void reset() {
    _hasCheckedIn = false;
    _checkInTime = null;
  }
  
  // Calculate attendance percentage for current month
  double calculateAttendancePercentage() {
    // In a real app, this would use actual attendance data
    // For demo purposes, we'll return a fixed value
    return 0.5; // 50%
  }
  
  // Format check-in time
  String getFormattedCheckInTime() {
    if (_checkInTime == null) return '';
    return '${_checkInTime!.hour.toString().padLeft(2, '0')}:${_checkInTime!.minute.toString().padLeft(2, '0')}';
  }
  
  // Get current date formatted
  String getCurrentDateFormatted() {
    final now = DateTime.now();
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}