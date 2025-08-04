import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:kliktoko/storage/storage_service.dart';
import 'package:kliktoko/attendance_page/AttendanceModel.dart';
import 'package:kliktoko/attendance_page/AttendanceApiService.dart';
import 'package:kliktoko/attendance_page/ShiftModel.dart';
import 'package:kliktoko/attendance_page/ShiftStatusModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SharedAttendanceController extends GetxController {
  static SharedAttendanceController get to =>
      Get.find<SharedAttendanceController>();

  // Observable variables for attendance state
  final RxBool hasCheckedIn = false.obs;
  final RxBool hasCheckedOut = false.obs;
  final RxBool isLate = false.obs;
  final RxString selectedShift = '1'.obs;
  final RxDouble attendancePercentage = 0.85.obs;
  final RxString username = ''.obs;
  final RxString userId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isOutsideShiftHours = false.obs;

  // Observable for shift status
  final Rx<ShiftStatusModel> shiftStatus = ShiftStatusModel.empty().obs;

  // New observables for attendance history
  final RxList<Map<String, dynamic>> attendanceHistory =
      <Map<String, dynamic>>[].obs;
  final RxBool isHistoryLoading = false.obs;

  // Observable model for current attendance
  final Rx<AttendanceModel> currentAttendance = AttendanceModel.empty().obs;

  // Services

  // Ubah tipe data untuk menyimpan model ShiftModel yang lengkap
  final RxList<ShiftModel> shiftList = <ShiftModel>[].obs;

  // Tambahkan map untuk akses cepat shift berdasarkan ID
  final Rx<Map<String, ShiftModel>> shiftMap = Rx<Map<String, ShiftModel>>({});

  final StorageService _storageService = StorageService();
  final AttendanceApiService _attendanceService = AttendanceApiService();

  // API service base URL - matches the one in ApiService.dart
  static const String baseUrl = 'https://kliktoko.rplrus.com';

  // Ensure controller is registered
  static void ensureInitialized() {
    if (!Get.isRegistered<SharedAttendanceController>()) {
      Get.put(SharedAttendanceController());
    }
  }

  // Flag to prevent recursive calls in determineShift
  bool _isDeterminingShift = false;

  // Automatically determine shift based on current time - Diperbarui untuk lebih fleksibel
  // Diperbarui untuk menangani shift yang melewati tengah malam
  void determineShift() {
    // Prevent recursive calls
    if (_isDeterminingShift) {
      print('⚠️ Preventing recursive call to determineShift');
      return;
    }

    try {
      _isDeterminingShift = true;

      // Cek apakah ada data shift dari API
      if (!shiftList.isEmpty) {
        // Jika ada data shift dari API, gunakan determineShiftFromServer() sebagai gantinya
        if (!_isDeterminingShiftFromServer) {
          determineShiftFromServer();
        } else {
          print(
              '⚠️ Skipping determineShiftFromServer call to prevent recursion');
        }
        return;
      }

      print('⚠️ Tidak ada data shift dari API, menunggu data shift...');
      // Set nilai default sementara
      selectedShift.value = '1';
      isOutsideShiftHours.value = true;

      // Coba muat ulang data shift
      if (!_isShiftTimerRunning) {
        loadShiftList();
      }
    } finally {
      _isDeterminingShift = false;
    }
  }

  // Flag to prevent recursive calls
  bool _isCheckingAttendanceStatus = false;

  // Method to check shift status from new API endpoint
  Future<void> checkAttendanceStatus() async {
    if (_isCheckingAttendanceStatus) {
      print('⚠️ Mencegah pemanggilan berulang ke checkAttendanceStatus');
      return;
    }

    try {
      _isCheckingAttendanceStatus = true;
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token autentikasi tidak tersedia');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/shifts/status'),
        headers: await _getHeaders(token),
      );

      print('📊 Status shift response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);
        final status = ShiftStatusModel.fromJson(jsonData);
        shiftStatus.value = status;

        // Update observable values based on shift status
        hasCheckedIn.value = status.isActive;
        hasCheckedOut.value = status.data?.checkOut != null;
        isLate.value = status.data?.isLate ?? false;

        if (status.isActive && status.data != null) {
          selectedShift.value = status.data!.shiftNumber.toString();
          print('👉 Shift diperbarui ke: ${selectedShift.value}');
        }

        print(
            '✅ Pemeriksaan status selesai: Aktif = ${status.isActive}, Terlambat = ${status.data?.isLate ?? false}');
      } else {
        print('❌ Gagal mendapatkan status: ${response.statusCode}');
        hasError.value = true;
        errorMessage.value = 'Gagal memverifikasi status kehadiran';
      }
    } catch (e) {
      print('❌ Error saat memeriksa status: $e');
      hasError.value = true;
      errorMessage.value = 'Tidak dapat memverifikasi status kehadiran';
    } finally {
      isLoading.value = false;
      _isCheckingAttendanceStatus = false;
    }
  }

  // Method to handle check-in
  // In SharedAttendanceController.dart
// Update the checkIn method with enhanced error handling and logging

  // Flag to prevent recursive calls in checkIn
  bool _isCheckingIn = false;

  Future<void> checkIn() async {
    // Prevent recursive calls
    if (_isCheckingIn) {
      print('⚠️ Preventing recursive call to checkIn');
      return;
    }

    try {
      _isCheckingIn = true;
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Make sure we have a non-empty selected shift
      if (selectedShift.value.isEmpty) {
        print('⚠️ Warning: Selected shift is empty, defaulting to "1"');
        selectedShift.value = '1';
      }

      print('🔄 Attempting to check in with shift ID: ${selectedShift.value}');

      // Perform check-in using dedicated service
      final checkInResult =
          await _attendanceService.checkIn(shiftId: selectedShift.value);

      // Force updates to the observables immediately
      hasCheckedIn.value = true;
      isLate.value = checkInResult.isLate;
      hasCheckedOut.value = checkInResult.hasCheckedOut;
      currentAttendance.value = checkInResult;

      print('✅ Check-in successful: ${checkInResult.toString()}');

      // Update attendance status after successful check-in
      if (!_isCheckingAttendanceStatus) {
        await checkAttendanceStatus();
        print('✅ Attendance status updated after check-in');
      }

      // Refresh attendance history after checking in
      await loadAttendanceHistory();
      print('✅ Attendance history refreshed after check-in');
    } catch (e) {
      print('❌ Error during check-in: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to check in: ${e.toString()}';
      throw e;
    } finally {
      isLoading.value = false;
      _isCheckingIn = false;
    }
  }

  // Flag to prevent recursive calls in checkOut
  bool _isCheckingOut = false;

  // Method to handle check-out
  Future<void> checkOut() async {
    // Prevent recursive calls
    if (_isCheckingOut) {
      print('⚠️ Preventing recursive call to checkOut');
      return;
    }

    try {
      _isCheckingOut = true;
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Check current status first
      if (!hasCheckedIn.value) {
        hasError.value = true;
        errorMessage.value = 'Anda belum melakukan check-in hari ini.';
        return;
      }

      if (hasCheckedOut.value) {
        hasError.value = true;
        errorMessage.value = 'Anda sudah melakukan check-out hari ini.';
        return;
      }

      // Perform check-out using dedicated service
      final checkOutResult = await _attendanceService.checkOut();

      // Update the observables immediately
      hasCheckedOut.value = true;
      currentAttendance.value = checkOutResult;

      print(
          '✅ Check-out completed. Check-out time: ${checkOutResult.checkOutTime}');

      // Refresh attendance history
      await loadAttendanceHistory();
    } catch (e) {
      print('❌ Error during check-out: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to check out: ${e.toString()}';
      throw e;
    } finally {
      isLoading.value = false;
      _isCheckingOut = false;
    }
  }

  // Flag to prevent recursive calls in loadAttendanceHistory
  bool _isLoadingAttendanceHistory = false;

  // New method to fetch attendance history
  Future<void> loadAttendanceHistory() async {
    // Prevent recursive calls
    if (_isLoadingAttendanceHistory) {
      print('⚠️ Preventing recursive call to loadAttendanceHistory');
      return;
    }

    try {
      _isLoadingAttendanceHistory = true;
      print('🔄 Loading attendance history');
      isHistoryLoading.value = true;

      // Get the token
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        print('❌ No token available for attendance history request');
        return;
      }

      final headers = await _getHeaders(token);

      // Fetch attendance history
      final response = await http.get(
        Uri.parse('$baseUrl/api/attendance/history'),
        headers: headers,
      );

      print(
          '📊 Attendance history API response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);

        List<dynamic> historyData = [];

        // Handle different API response structures
        if (jsonData is List) {
          historyData = jsonData;
        } else if (jsonData is Map &&
            jsonData.containsKey('data') &&
            jsonData['data'] is List) {
          historyData = jsonData['data'];
        } else if (jsonData is Map &&
            jsonData.containsKey('history') &&
            jsonData['history'] is List) {
          historyData = jsonData['history'];
        }

        // Convert to list of maps and sort by date (most recent first)
        final historyList =
            historyData.map((item) => item as Map<String, dynamic>).toList();

        // Sort by date (most recent first)
        historyList.sort((a, b) {
          String dateA = a['date'] ??
              a['attendance_date'] ??
              a['created_at']?.toString() ??
              '';
          String dateB = b['date'] ??
              b['attendance_date'] ??
              b['created_at']?.toString() ??
              '';

          // Parse dates for comparison
          DateTime? parsedDateA;
          DateTime? parsedDateB;

          try {
            parsedDateA = DateTime.parse(dateA);
          } catch (e) {
            print('Error parsing date A: $e');
          }

          try {
            parsedDateB = DateTime.parse(dateB);
          } catch (e) {
            print('Error parsing date B: $e');
          }

          // If both dates parsed successfully, compare them
          if (parsedDateA != null && parsedDateB != null) {
            return parsedDateB.compareTo(parsedDateA); // Descending order
          }

          // Fallback to string comparison if parsing failed
          return dateB.compareTo(dateA);
        });

        attendanceHistory.value = historyList;
        print('✅ Loaded ${historyList.length} attendance history records');
      } else {
        print('❌ Failed to load attendance history: ${response.statusCode}');
        attendanceHistory.value = [];
      }
    } catch (e) {
      print('❌ Error loading attendance history: $e');
      attendanceHistory.value = [];
    } finally {
      isHistoryLoading.value = false;
      _isLoadingAttendanceHistory = false;
    }
  }

  // Helper to get headers for API requests
  Future<Map<String, String>> _getHeaders([String? token]) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        // Try to get token from storage if not provided
        final storedToken = await _storageService.getToken();
        if (storedToken != null && storedToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $storedToken';
        }
      }
    } catch (e) {
      print('Error setting auth headers: $e');
    }

    return headers;
  }

  // Observable for shift loading status
  final RxBool isShiftLoading = false.obs;

  // Get formatted shift time - Diperbarui untuk selalu menggunakan data shift terbaru dari API
  // Diperbarui untuk menangani shift yang melewati tengah malam dengan benar
  String getShiftTime(String shift) {
    // Cek apakah shift ada di shiftMap (data dari API)
    if (shiftMap.value.containsKey(shift)) {
      // Gunakan data shift dari API
      final shiftData = shiftMap.value[shift]!;
      print(
          'ℹ️ Menggunakan data shift dari API: ${shiftData.name} (${shiftData.getFormattedTimeRange()})');

      // Cek apakah shift melewati tengah malam untuk logging
      final startParts = shiftData.startTime.split(':');
      final endParts = shiftData.endTime.split(':');

      if (startParts.length >= 2 && endParts.length >= 2) {
        final startMinutes =
            int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

        if (endMinutes < startMinutes) {
          print(
              '🌙 Menampilkan shift yang melewati tengah malam: ${shiftData.startTime} - ${shiftData.endTime}');
        }
      }

      return shiftData.getFormattedTimeRange();
    }

    // Jika shift tidak ditemukan di data API, cek apakah di luar jam kerja
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute; // Convert to minutes

    // Jika di luar jam shift (setelah 03:30 atau sebelum 07:30)
    if (isOutsideShiftHours.value) {
      return 'Selamat Tidur!';
    }

    // Fallback ke default jika shift tidak ditemukan di API
    print('⚠️ Shift $shift tidak ditemukan di data API, menggunakan default');
    switch (shift) {
      case '1':
        return '07:30 - 14:30';
      case '2':
        return '14:30 - 03:30'; // Diperbarui sesuai perubahan di web admin
      default:
        return '07:30 - 14:30';
    }
  }

  // Get current date formatted
  String getCurrentDateFormatted() {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
  }

  // Flag to prevent recursive calls in loadUserData
  bool _isLoadingUserData = false;

  // Load user data from storage
  Future<void> loadUserData() async {
    // Prevent recursive calls
    if (_isLoadingUserData) {
      print('⚠️ Preventing recursive call to loadUserData');
      return;
    }

    try {
      _isLoadingUserData = true;
      isLoading.value = true;

      // Initialize storage service
      await _storageService.init();

      // Check if user is logged in
      final isLoggedIn = await _storageService.isLoggedIn();
      if (!isLoggedIn) {
        print('❌ User is not logged in');
        return;
      }

      // Get user data
      final userData = await _storageService.getUserData();
      if (userData != null) {
        // Extract user information
        if (userData.containsKey('name')) {
          username.value = userData['name'];
        }

        if (userData.containsKey('id')) {
          userId.value = userData['id'].toString();
        }

        print(
            '👤 Loaded user data: Name=${username.value}, ID=${userId.value}');
      } else {
        print('⚠️ No user data found in storage');
      }

      // Check attendance status when loading user data
      if (!_isCheckingAttendanceStatus) {
        await checkAttendanceStatus();
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to load user data';
    } finally {
      isLoading.value = false;
      _isLoadingUserData = false;
    }
  }

  // Helper method for min function
  int _min(int a, int b) {
    return a < b ? a : b;
  }

  // Flags to manage timer execution
  bool _isShiftTimerRunning = false;
  bool _isAttendanceStatusTimerRunning = false;
  bool _isHistoryTimerRunning = false;

  @override
  void onInit() {
    super.onInit();
    print('➡️ SharedAttendanceController initialized');

    // Muat data shift dari API segera saat controller diinisialisasi
    loadShiftList().then((_) {
      // Tentukan shift berdasarkan data server yang baru dimuat
      determineShiftFromServer();

      // Jadwalkan pembaruan data shift dari API setiap 1 menit dengan perlindungan rekursi
      Timer.periodic(Duration(minutes: 1), (_) async {
        if (!_isShiftTimerRunning) {
          _isShiftTimerRunning = true;
          try {
            print('🔄 Refreshing shift data from API (periodic update)');
            await loadShiftList(); // Ini akan otomatis memanggil determineShiftFromServer()
          } catch (e) {
            print('❌ Error in shift timer: $e');
          } finally {
            _isShiftTimerRunning = false;
          }
        } else {
          print(
              '⚠️ Skipping shift timer as previous execution is still running');
        }
      });
    });

    // Set shift awal berdasarkan waktu lokal sebagai fallback
    determineShift();

    // Load user data immediately
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadUserData();
      // Load attendance history after user data
      await loadAttendanceHistory();
    });

    // Periksa shift berdasarkan waktu lokal setiap menit sebagai fallback dengan perlindungan rekursi
    Timer.periodic(Duration(minutes: 1), (_) {
      // Hanya gunakan determineShift jika tidak ada shift aktif dari server
      if (shiftList.isEmpty && !_isShiftTimerRunning) {
        determineShift();
      }
    });

    // Periksa status kehadiran secara berkala dengan perlindungan rekursi
    Timer.periodic(Duration(minutes: 5), (_) async {
      if (!_isAttendanceStatusTimerRunning && !_isCheckingAttendanceStatus) {
        _isAttendanceStatusTimerRunning = true;
        try {
          await checkAttendanceStatus();
        } catch (e) {
          print('❌ Error in attendance status timer: $e');
        } finally {
          _isAttendanceStatusTimerRunning = false;
        }
      } else {
        print(
            '⚠️ Skipping attendance status timer as previous execution is still running');
      }
    });

    // Refresh attendance history every 15 minutes dengan perlindungan rekursi
    Timer.periodic(Duration(minutes: 15), (_) async {
      if (!_isHistoryTimerRunning && !_isLoadingAttendanceHistory) {
        _isHistoryTimerRunning = true;
        try {
          await loadAttendanceHistory();
        } catch (e) {
          print('❌ Error in history timer: $e');
        } finally {
          _isHistoryTimerRunning = false;
        }
      } else {
        print(
            '⚠️ Skipping history timer as previous execution is still running');
      }
    });
  }

  void setShift(String shiftNumber) {
    selectedShift.value = shiftNumber;
    print('👉 Shift manually set to: $shiftNumber');
  }

  // Flag to prevent recursive calls in determineShiftFromServer
  bool _isDeterminingShiftFromServer = false;

  // Determine shift based on server data dengan peningkatan untuk akurasi yang lebih baik
  // Diperbarui untuk menangani shift yang melewati tengah malam dengan lebih baik
  void determineShiftFromServer() {
    // Prevent recursive calls
    if (_isDeterminingShiftFromServer) {
      print('⚠️ Preventing recursive call to determineShiftFromServer');
      return;
    }

    try {
      _isDeterminingShiftFromServer = true;

      if (shiftList.isEmpty) {
        print('⚠️ Tidak ada data shift tersedia, menggunakan penentuan lokal');
        if (!_isShiftTimerRunning) {
          determineShift();
        }
        return;
      }

      print('🔄 Menentukan shift dari data server');
      final now = DateTime.now();
      final currentTime = now.hour * 60 + now.minute; // Convert to minutes

      print(
          '⏰ Waktu saat ini: ${now.hour}:${now.minute}:${now.second} (${currentTime} menit)');

      // Cek setiap shift dari data server
      bool foundActiveShift = false;
      for (final shift in shiftList) {
        print(
            '🔍 Memeriksa shift ${shift.id}: ${shift.name} (${shift.startTime} - ${shift.endTime})');

        // Gunakan metode isCurrentTimeInShift yang sudah ditingkatkan
        if (shift.isCurrentTimeInShift()) {
          print('✅ Shift aktif ditemukan: ${shift.name} (ID: ${shift.id})');
          selectedShift.value = shift.id.toString();
          isOutsideShiftHours.value = false;
          foundActiveShift = true;

          // Log informasi tambahan untuk shift yang melewati tengah malam
          final startParts = shift.startTime.split(':');
          final endParts = shift.endTime.split(':');

          if (startParts.length >= 2 && endParts.length >= 2) {
            final startMinutes =
                int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
            final endMinutes =
                int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

            if (endMinutes < startMinutes) {
              print(
                  '🌙 Shift ${shift.id} melewati tengah malam: ${shift.startTime} - ${shift.endTime}');
              print(
                  '🕒 Waktu saat ini (${currentTime} menit) berada dalam rentang shift yang melewati tengah malam');
            }
          }

          return;
        }
      }

      // Jika tidak ada shift aktif, gunakan penentuan berbasis waktu lokal
      if (!foundActiveShift) {
        print(
            '⚠️ Tidak ada shift aktif ditemukan, menggunakan penentuan berbasis waktu');
        if (!_isShiftTimerRunning) {
          determineShift();
        }
      }
    } finally {
      _isDeterminingShiftFromServer = false;
    }
  }

  // Flag to prevent recursive calls in loadShiftList
  bool _isLoadingShiftList = false;

  // Fetch shift data from API dengan peningkatan untuk sinkronisasi yang lebih baik
  Future<void> loadShiftList() async {
    // Prevent recursive calls
    if (_isLoadingShiftList) {
      print('⚠️ Preventing recursive call to loadShiftList');
      return;
    }

    try {
      _isLoadingShiftList = true;
      print('🔄 Loading shift list from API');
      isShiftLoading.value = true;
      final token = await _storageService.getToken();
      final headers = await _getHeaders(token);

      // Log waktu saat ini untuk debugging
      final now = DateTime.now();
      print(
          '⏰ Waktu saat memuat shift: ${now.hour}:${now.minute}:${now.second}');

      final response = await http
          .get(Uri.parse('$baseUrl/api/shifts'), headers: headers)
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      print('📊 Shift API response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Log respons mentah untuk debugging
        print('📋 Raw API response: ${response.body}');

        final jsonData = json.decode(response.body);
        List<dynamic> data = [];

        if (jsonData is List) {
          data = jsonData;
          print('📦 API mengembalikan data dalam format List');
        } else if (jsonData is Map &&
            jsonData.containsKey('data') &&
            jsonData['data'] is List) {
          data = jsonData['data'];
          print(
              '📦 API mengembalikan data dalam format Map dengan kunci "data"');
        } else {
          print(
              '⚠️ Format respons API tidak dikenali: ${jsonData.runtimeType}');
        }

        // Jika tidak ada data shift dari API, gunakan default
        if (data.isEmpty) {
          print(
              '⚠️ API mengembalikan daftar shift kosong, menggunakan default');
          _setDefaultShifts();
          return;
        }

        final shifts = data.map((e) => ShiftModel.fromJson(e)).toList();

        // Log detail setiap shift untuk debugging
        for (var shift in shifts) {
          print(
              '📋 Shift ${shift.id}: ${shift.name}, Waktu: ${shift.startTime} - ${shift.endTime}');

          // Tambahkan pengecekan khusus untuk shift yang melewati tengah malam
          final startParts = shift.startTime.split(':');
          final endParts = shift.endTime.split(':');

          if (startParts.length >= 2 && endParts.length >= 2) {
            final startMinutes =
                int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
            final endMinutes =
                int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

            if (endMinutes < startMinutes) {
              print(
                  '🌙 Shift ${shift.id} melewati tengah malam: ${shift.startTime} - ${shift.endTime}');
            }
          }
        }

        shiftList.value = shifts;

        // Perbarui map untuk akses cepat shift berdasarkan ID
        final Map<String, ShiftModel> map = {};
        for (var shift in shifts) {
          map[shift.id.toString()] = shift;
        }
        shiftMap.value = map;

        print('✅ Loaded ${shifts.length} shifts from API');

        // Segera tentukan shift berdasarkan data server yang baru
        // Cek apakah determineShiftFromServer sedang berjalan
        if (!_isShiftTimerRunning) {
          determineShiftFromServer();
        }
      } else {
        print('❌ Failed to load shifts: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        if (shiftList.isEmpty) {
          _setDefaultShifts();
        }
      }
    } catch (e) {
      print('❌ Error loading shifts: $e');
      if (shiftList.isEmpty) {
        _setDefaultShifts();
      }
    } finally {
      isShiftLoading.value = false;
      _isLoadingShiftList = false;
    }
  }

  // Helper method untuk mengatur shift default
  // Diperbarui untuk mencerminkan perubahan dari web admin
  void _setDefaultShifts() {
    print('⚙️ Mengatur shift default dengan perubahan terbaru');
    shiftList.value = [
      ShiftModel(
          id: 1,
          name: 'Shift 1',
          startTime: '07:30:00',
          endTime: '14:30:00',
          description: 'Morning shift'),
      ShiftModel(
          id: 2,
          name: 'Shift 2',
          startTime: '14:30:00',
          endTime: '03:30:00', // Diperbarui sesuai perubahan di web admin
          description: 'Afternoon shift'),
    ];

    // Log detail shift default untuk debugging
    for (var shift in shiftList) {
      print(
          '📋 Default Shift ${shift.id}: ${shift.name}, Waktu: ${shift.startTime} - ${shift.endTime}');

      // Cek apakah shift melewati tengah malam
      final startParts = shift.startTime.split(':');
      final endParts = shift.endTime.split(':');

      if (startParts.length >= 2 && endParts.length >= 2) {
        final startMinutes =
            int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

        if (endMinutes < startMinutes) {
          print(
              '🌙 Default Shift ${shift.id} melewati tengah malam: ${shift.startTime} - ${shift.endTime}');
        }
      }
    }

    final Map<String, ShiftModel> map = {};
    for (var shift in shiftList) {
      map[shift.id.toString()] = shift;
    }
    shiftMap.value = map;
  }
}
