class ShiftModel {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final String? description;
  final int lateTolerance;
  final dynamic lateThreshold;
  final String? salaryPerShift;
  final String? checkInTime;
  final String? checkOutTime;

  ShiftModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.description,
    this.lateTolerance = 15,
    this.lateThreshold,
    this.salaryPerShift,
    this.checkInTime,
    this.checkOutTime,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    // Tambahkan log untuk debugging
    print('📊 Parsing shift from JSON: ${json.keys.join(', ')}');

    return ShiftModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      description: json['description']?.toString(),
      lateTolerance: json['late_tolerance'] is int
          ? json['late_tolerance']
          : int.tryParse(json['late_tolerance'].toString()) ?? 15,
      lateThreshold: json['late_threshold'],
      salaryPerShift: json['salary_per_shift']?.toString(),
      checkInTime: json['check_in_time']?.toString(),
      checkOutTime: json['check_out_time']?.toString(),
    );
  }

  // Method untuk format jam shift untuk display
  String getFormattedTimeRange() {
    // Gunakan checkInTime dan checkOutTime jika tersedia
    if (checkInTime != null &&
        checkInTime!.isNotEmpty &&
        checkOutTime != null &&
        checkOutTime!.isNotEmpty) {
      String formattedStart = _formatTime(checkInTime!);
      String formattedEnd = _formatTime(checkOutTime!);
      return '$formattedStart - $formattedEnd';
    }

    // Fallback ke startTime dan endTime jika checkInTime/checkOutTime tidak tersedia
    String formattedStart = _formatTime(startTime);
    String formattedEnd = _formatTime(endTime);
    return '$formattedStart - $formattedEnd';
  }

  String _formatTime(String time) {
    if (time.isEmpty) return '';

    try {
      // Cek apakah format ISO (2025-07-25T00:30:00.000000Z)
      if (time.contains('T') && time.contains('-')) {
        final dateTime = DateTime.parse(time);
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }

      // Jika format sudah HH:mm, return as is
      if (time.length == 5) return time;

      // Jika format HH:mm:ss, ambil HH:mm saja
      if (time.length >= 5) {
        return time.substring(0, 5);
      }

      return time;
    } catch (e) {
      print('⚠️ Error formatting time: $e');
      return '';
    }
  }

  // Helper method untuk mengkonversi string waktu ke menit
  int _parseTimeToMinutes(String time) {
    try {
      // Cek apakah format ISO (2025-07-25T00:30:00.000000Z)
      if (time.contains('T') && time.contains('-')) {
        final dateTime = DateTime.parse(time);
        return dateTime.hour * 60 + dateTime.minute;
      }

      // Format HH:mm atau HH:mm:ss
      final parts = time.split(':');
      if (parts.length >= 2) {
        return int.parse(parts[0]) * 60 + int.parse(parts[1]);
      }

      print('⚠️ Format waktu tidak valid: $time');
      return 0;
    } catch (e) {
      print('⚠️ Error parsing time to minutes: $e');
      return 0;
    }
  }

  // Method untuk check apakah waktu saat ini ada dalam rentang shift ini
  // Diperbarui untuk menangani shift yang melewati tengah malam dengan lebih baik
  bool isCurrentTimeInShift() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // Gunakan checkInTime dan checkOutTime jika tersedia
    final String timeStart = (checkInTime != null && checkInTime!.isNotEmpty)
        ? checkInTime!
        : startTime;
    final String timeEnd = (checkOutTime != null && checkOutTime!.isNotEmpty)
        ? checkOutTime!
        : endTime;

    final startMinutes = _parseTimeToMinutes(timeStart);
    final endMinutes = _parseTimeToMinutes(timeEnd);

    if (startMinutes == 0 && endMinutes == 0) {
      print('⚠️ Format waktu shift tidak valid: $timeStart - $timeEnd');
      return false;
    }

    print(
        '🔍 Memeriksa shift: waktu saat ini=$currentMinutes menit, mulai=$startMinutes menit, selesai=$endMinutes menit');

    // Tambahkan buffer 30 menit sebelum shift dimulai untuk memungkinkan check-in lebih awal
    final startWithBuffer = startMinutes - 30;

    // Handle case where shift crosses midnight (endMinutes < startMinutes)
    if (endMinutes < startMinutes) {
      final isInShift =
          currentMinutes >= startWithBuffer || currentMinutes < endMinutes;
      print(
          '🌙 Shift melewati tengah malam: ${isInShift ? "AKTIF" : "tidak aktif"}');
      return isInShift;
    }

    final isInShift =
        currentMinutes >= startWithBuffer && currentMinutes < endMinutes;
    print('🔄 Shift normal: ${isInShift ? "AKTIF" : "tidak aktif"}');
    return isInShift;
  }

  // Method untuk check apakah terlambat
  bool isLateForShift(DateTime checkInTime) {
    final checkInMinutes = checkInTime.hour * 60 + checkInTime.minute;

    // Gunakan checkInTime jika tersedia, jika tidak gunakan startTime
    final String timeStart =
        (this.checkInTime != null && this.checkInTime!.isNotEmpty)
            ? this.checkInTime!
            : startTime;
    final startParts = timeStart.split(':');

    if (startParts.length < 2) return false;

    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);

    // Tambahkan toleransi keterlambatan
    final lateMinutes = startMinutes + lateTolerance;

    return checkInMinutes > lateMinutes;
  }

  @override
  String toString() {
    return 'ShiftModel{id: $id, name: $name, timeRange: ${getFormattedTimeRange()}, lateTolerance: $lateTolerance}';
  }

  // Helper method untuk mengecek apakah shift sudah berakhir
  bool isShiftEnded() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // Gunakan checkOutTime jika tersedia, jika tidak gunakan endTime
    final String timeEnd = (checkOutTime != null && checkOutTime!.isNotEmpty)
        ? checkOutTime!
        : endTime;
    final endParts = timeEnd.split(':');

    if (endParts.length < 2) return false;

    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    // Jika shift melewati tengah malam dan sekarang sebelum waktu berakhir
    final String timeStart = (checkInTime != null && checkInTime!.isNotEmpty)
        ? checkInTime!
        : startTime;
    final startParts = timeStart.split(':');

    if (startParts.length < 2) return false;

    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);

    if (endMinutes < startMinutes) {
      // Jika sekarang setelah tengah malam tapi sebelum waktu berakhir
      if (currentMinutes < endMinutes) return false;
      // Jika sekarang setelah waktu mulai tapi sebelum tengah malam
      if (currentMinutes >= startMinutes) return false;
      return true;
    }

    return currentMinutes >= endMinutes;
  }
}
