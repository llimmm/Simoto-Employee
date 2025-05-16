class ShiftModel {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final String? description;

  ShiftModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.description,
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
    );
  }

  // Method untuk format jam shift untuk display
  String getFormattedTimeRange() {
    // Convert dari format HH:mm:ss ke HH:mm
    String formattedStart = _formatTime(startTime);
    String formattedEnd = _formatTime(endTime);
    return '$formattedStart - $formattedEnd';
  }

  String _formatTime(String time) {
    if (time.isEmpty) return '';

    // Jika format sudah HH:mm, return as is
    if (time.length == 5) return time;

    // Jika format HH:mm:ss, ambil HH:mm saja
    if (time.length >= 5) {
      return time.substring(0, 5);
    }

    return time;
  }

  // Method untuk check apakah waktu saat ini ada dalam rentang shift ini
  // Diperbarui untuk menangani shift yang melewati tengah malam dengan lebih baik
  bool isCurrentTimeInShift() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    final startParts = startTime.split(':');
    final endParts = endTime.split(':');

    if (startParts.length < 2 || endParts.length < 2) {
      print('⚠️ Format waktu shift tidak valid: $startTime - $endTime');
      return false;
    }

    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    print(
        '🔍 Memeriksa shift: waktu saat ini=$currentMinutes menit, mulai=$startMinutes menit, selesai=$endMinutes menit');

    // Handle case where shift crosses midnight (endMinutes < startMinutes)
    if (endMinutes < startMinutes) {
      final isInShift =
          currentMinutes >= startMinutes || currentMinutes < endMinutes;
      print(
          '🌙 Shift melewati tengah malam: ${isInShift ? "AKTIF" : "tidak aktif"}');
      return isInShift;
    }

    final isInShift =
        currentMinutes >= startMinutes && currentMinutes < endMinutes;
    print('🔄 Shift normal: ${isInShift ? "AKTIF" : "tidak aktif"}');
    return isInShift;
  }

  // Method untuk check apakah terlambat
  bool isLateForShift(DateTime checkInTime) {
    final checkInMinutes = checkInTime.hour * 60 + checkInTime.minute;
    final startParts = startTime.split(':');

    if (startParts.length < 2) return false;

    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);

    return checkInMinutes > startMinutes;
  }

  @override
  String toString() {
    return 'ShiftModel{id: $id, name: $name, timeRange: ${getFormattedTimeRange()}}';
  }
}
