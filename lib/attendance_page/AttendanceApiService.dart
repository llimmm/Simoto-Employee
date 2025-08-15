import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:kliktoko/attendance_page/AttendanceModel.dart';
import 'package:kliktoko/attendance_page/ShiftModel.dart';
import 'package:kliktoko/storage/storage_service.dart';

class AttendanceApiService {
  static const String baseUrl = 'https://adminkliktoko.my.id';
  final StorageService _storageService = StorageService();
  bool isDebugMode = true; // Set sesuai dengan mode aplikasi

  // Timer untuk auto checkout
  Timer? _autoCheckoutTimer;

  // Method untuk mendapatkan semua shift yang tersedia
  Future<List<ShiftModel>> getShifts() async {
    try {
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token available');
      }

      _logDebug(
          '🔍 Mengambil data shift dengan token: ${token.substring(0, math.min(10, token.length))}...');

      final response = await http
          .get(
        Uri.parse('$baseUrl/api/shifts'),
        headers: await _getHeaders(token),
      )
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      _logDebug('📊 Shifts response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);
        List<dynamic> shiftsData = [];

        if (jsonData is Map &&
            jsonData.containsKey('data') &&
            jsonData['data'] is List) {
          shiftsData = jsonData['data'];
        } else if (jsonData is List) {
          shiftsData = jsonData;
        }

        _logDebug('📋 Shifts data: $shiftsData');

        List<ShiftModel> shifts = shiftsData
            .map((shiftData) =>
                ShiftModel.fromJson(_convertToStringDynamicMap(shiftData)))
            .toList();

        return shifts;
      } else {
        _logDebug(
            '❌ Failed to get shifts: ${response.statusCode}, ${response.body}');
        throw Exception(
            'Failed to get shifts. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _logDebug('❌ Error getting shifts: $e');
      throw Exception('Failed to get shifts: $e');
    }
  }

  // Method untuk mendapatkan status shift saat ini
  Future<Map<String, dynamic>> getShiftStatus() async {
    try {
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token available');
      }

      _logDebug(
          '🔍 Mengambil status shift dengan token: ${token.substring(0, math.min(10, token.length))}...');

      final response = await http
          .get(
        Uri.parse('$baseUrl/api/shifts/status'),
        headers: await _getHeaders(token),
      )
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      _logDebug('📊 Shift status response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);
        _logDebug('📋 Shift status data: $jsonData');

        // Setup auto checkout jika user sedang aktif
        if (jsonData is Map &&
            jsonData.containsKey('is_active') &&
            jsonData['is_active'] == true) {
          _setupAutoCheckout(jsonData);
        }

        return jsonData is Map ? Map<String, dynamic>.from(jsonData) : {};
      } else {
        _logDebug(
            '❌ Failed to get shift status: ${response.statusCode}, ${response.body}');
        throw Exception(
            'Failed to get shift status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _logDebug('❌ Error getting shift status: $e');
      throw Exception('Failed to get shift status: $e');
    }
  }

  // Method untuk setup auto checkout berdasarkan data shift
  void _setupAutoCheckout(Map<dynamic, dynamic> shiftData) {
    try {
      // Cancel timer yang sudah ada jika ada
      _autoCheckoutTimer?.cancel();

      // Konversi Map<dynamic, dynamic> ke Map<String, dynamic>
      final Map<String, dynamic> convertedShiftData =
          _convertToStringDynamicMap(shiftData);

      // Cek apakah ada data shift dan durasi
      if (convertedShiftData.containsKey('data') &&
          convertedShiftData['data'] is Map &&
          convertedShiftData['data'].containsKey('shift_time')) {
        final shiftInfo = convertedShiftData['data'];
        String? endTimeStr;

        // Coba ambil waktu akhir shift
        if (shiftInfo.containsKey('shift_time') &&
            shiftInfo['shift_time'] is String) {
          // Format: "07:30 - 14:30"
          final timeParts = shiftInfo['shift_time'].toString().split(' - ');
          if (timeParts.length == 2) {
            endTimeStr = timeParts[1];
          }
        }

        if (endTimeStr != null) {
          _logDebug('⏰ Setting up auto checkout for end time: $endTimeStr');

          // Parse waktu akhir shift
          final timeParts = endTimeStr.split(':');
          if (timeParts.length >= 2) {
            final endHour = int.tryParse(timeParts[0]) ?? 0;
            final endMinute = int.tryParse(timeParts[1]) ?? 0;

            // Buat DateTime untuk waktu akhir shift hari ini
            final now = DateTime.now();
            var endTime =
                DateTime(now.year, now.month, now.day, endHour, endMinute);

            // Jika waktu akhir sudah lewat, tidak perlu setup timer
            if (endTime.isBefore(now)) {
              _logDebug(
                  '⏰ Shift end time already passed, no auto checkout needed');
              return;
            }

            // Hitung durasi sampai waktu akhir shift
            final duration = endTime.difference(now);
            _logDebug(
                '⏰ Auto checkout will trigger in ${duration.inMinutes} minutes');

            // Setup timer untuk auto checkout
            _autoCheckoutTimer = Timer(duration, () async {
              _logDebug('⏰ Auto checkout timer triggered!');
              try {
                await checkOut();
                _logDebug('✅ Auto checkout successful');
              } catch (e) {
                _logDebug('❌ Auto checkout failed: $e');
              }
            });
          }
        }
      }
    } catch (e) {
      _logDebug('❌ Error setting up auto checkout: $e');
    }
  }

  // Method to check the attendance status (whether the user has checked in today)
  Future<AttendanceModel> checkAttendanceStatus() async {
    try {
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token available');
      }

      _logDebug(
          '🔍 Mencoba mendapatkan status kehadiran dengan token: ${token.substring(0, math.min(10, token.length))}...');

      // Coba endpoint pertama: /api/attendance/history
      try {
        _logDebug('🔄 Mencoba endpoint /api/attendance/history');
        final response = await http
            .get(
          Uri.parse('$baseUrl/api/attendance/history'),
          headers: await _getHeaders(token),
        )
            .timeout(const Duration(seconds: 15), onTimeout: () {
          throw TimeoutException('Request timed out');
        });

        _logDebug('📊 Attendance history response: ${response.statusCode}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return _processAttendanceResponse(response);
        } else {
          _logDebug(
              '⚠️ Endpoint pertama gagal. Status: ${response.statusCode}, Body: ${response.body}');
          // Jika endpoint pertama gagal, lanjut ke endpoint alternatif
        }
      } catch (e) {
        _logDebug('⚠️ Error pada endpoint pertama: $e');
        // Lanjut ke endpoint alternatif
      }

      // Coba endpoint alternatif: /api/attendance/status
      try {
        _logDebug('🔄 Mencoba endpoint alternatif /api/attendance/status');
        final today = DateTime.now();
        final todayStr = DateFormat('yyyy-MM-dd').format(today);

        final response = await http
            .get(
          Uri.parse('$baseUrl/api/attendance/status?date=$todayStr'),
          headers: await _getHeaders(token),
        )
            .timeout(const Duration(seconds: 15), onTimeout: () {
          throw TimeoutException('Request timed out');
        });

        _logDebug('📊 Attendance status response: ${response.statusCode}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return _processAttendanceStatusResponse(response);
        } else {
          _logDebug(
              '⚠️ Endpoint alternatif gagal. Status: ${response.statusCode}, Body: ${response.body}');
        }
      } catch (e) {
        _logDebug('⚠️ Error pada endpoint alternatif: $e');
      }

      // Jika semua endpoint gagal, kembalikan model kosong
      _logDebug('ℹ️ Semua endpoint gagal, mengembalikan model kosong');
      return AttendanceModel.empty();
    } catch (e) {
      _logDebug('❌ Error checking attendance status: $e');
      return AttendanceModel.empty(); // Return empty model in case of error
    }
  }

  // Helper untuk memproses respons dari endpoint /api/attendance/history
  AttendanceModel _processAttendanceResponse(http.Response response) {
    try {
      final jsonData = json.decode(response.body);
      List<dynamic> historyData = [];

      // If the response data is a list of history
      if (jsonData is List) {
        historyData = jsonData;
      } else if (jsonData is Map &&
          jsonData.containsKey('data') &&
          jsonData['data'] is List) {
        historyData = jsonData['data'];
      }

      // Loop through the history data to check for today's attendance
      for (var entry in historyData) {
        bool isToday = false;
        String entryDate = entry['date'] ?? entry['created_at'] ?? '';
        if (entryDate.isNotEmpty) {
          entryDate = entryDate.split('T')[0];

          // Compare with today's date
          String todayStr = DateTime.now().toIso8601String().split('T')[0];
          isToday = entryDate == todayStr;

          if (isToday) {
            _logDebug('✅ Found today\'s attendance record: $entry');
            // Pastikan entry adalah Map<String, dynamic>
            return AttendanceModel.fromJson(_convertToStringDynamicMap(entry));
          }
        }
      }

      _logDebug('ℹ️ No attendance record found for today');
      return AttendanceModel
          .empty(); // Return empty model if no attendance today
    } catch (e) {
      _logDebug('❌ Error processing attendance response: $e');
      return AttendanceModel.empty();
    }
  }

  // Helper untuk memproses respons dari endpoint /api/attendance/status
  AttendanceModel _processAttendanceStatusResponse(http.Response response) {
    try {
      final jsonData = json.decode(response.body);
      _logDebug('📋 Attendance status data: $jsonData');

      if (jsonData is Map) {
        Map<String, dynamic> attendanceData;

        if (jsonData.containsKey('data') && jsonData['data'] is Map) {
          attendanceData = _convertToStringDynamicMap(jsonData['data']);
        } else {
          attendanceData = _convertToStringDynamicMap(jsonData);
        }

        // Cek apakah user sudah check-in hari ini
        bool isCheckedIn = attendanceData['is_checked_in'] == true ||
            attendanceData['check_in_time'] != null;

        if (isCheckedIn) {
          _logDebug('✅ User sudah check-in hari ini');
          return AttendanceModel.fromJson(attendanceData);
        }
      }

      _logDebug('ℹ️ User belum check-in hari ini');
      return AttendanceModel.empty();
    } catch (e) {
      _logDebug('❌ Error processing attendance status response: $e');
      return AttendanceModel.empty();
    }
  }

  // Method untuk check in dengan foto
  Future<AttendanceModel> checkInWithPhoto(
      String shiftId, File photoFile) async {
    int retryCount = 0;
    const maxRetries = 2;
    const retryDelay = Duration(seconds: 2);

    while (true) {
      try {
        final token = await _storageService.getToken();
        if (token == null || token.isEmpty) {
          _logDebug('❌ Tidak ada token autentikasi tersedia untuk check-in');
          throw Exception('No authentication token available');
        }

        // Log waktu saat ini untuk debugging
        final now = DateTime.now();
        _logDebug('⏰ Waktu check-in: ${now.hour}:${now.minute}:${now.second}');
        _logDebug(
            '📥 Mengirim permintaan check-in dengan shift_id: $shiftId dan foto');
        _logDebug(
            '📝 Token prefix: ${token.length > 10 ? "${token.substring(0, 10)}..." : token}');

        // PERBAIKAN: Mengonversi shiftId menjadi integer sebelum dikirim
        int shiftIdInt;
        try {
          shiftIdInt = int.parse(shiftId);
          _logDebug('✅ Berhasil mengonversi shift_id ke integer: $shiftIdInt');
        } catch (e) {
          // Default ke 1 jika parsing gagal
          shiftIdInt = 1;
          _logDebug(
              '⚠️ Peringatan: Gagal mengurai shift_id, menggunakan default: 1');
        }

        // Buat request multipart untuk mengirim foto
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/api/attendance/check-in'),
        );

        // Tambahkan headers
        final headers = await _getHeaders(token);
        headers.forEach((key, value) {
          request.headers[key] = value;
        });

        // Tambahkan field shift_id
        request.fields['shift_id'] = shiftIdInt.toString();

        // Tambahkan file foto
        var photoStream = http.ByteStream(photoFile.openRead());
        var photoLength = await photoFile.length();
        var photoFileName = photoFile.path.split('/').last;

        var multipartFile = http.MultipartFile(
          'photo',
          photoStream,
          photoLength,
          filename: photoFileName,
        );

        request.files.add(multipartFile);
        _logDebug('📦 Request prepared with photo: $photoFileName');

        // Kirim request
        var streamedResponse = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );

        // Konversi ke http.Response
        final response = await http.Response.fromStream(streamedResponse);

        _logDebug('🔄 Check-in API response status: ${response.statusCode}');
        _logDebug('📄 Check-in API response body: ${response.body}');

        // PERBAIKAN: Handling response code dengan lebih spesifik
        if (response.statusCode >= 200 && response.statusCode < 300) {
          try {
            final jsonData = json.decode(response.body);
            _logDebug('✅ Successfully decoded JSON response');

            // PERBAIKAN: Tambahkan log untuk tipe data
            _logDebug('📋 Response data type: ${jsonData.runtimeType}');

            if (jsonData is Map) {
              if (jsonData.containsKey('data') && jsonData['data'] is Map) {
                Map<String, dynamic> data =
                    _convertToStringDynamicMap(jsonData['data']);

                // Cek apakah ada data attendance
                if (data.containsKey('attendance') &&
                    data['attendance'] is Map) {
                  _logDebug(
                      '📋 Parsing check-in response from "attendance" field');
                  return AttendanceModel.fromJson(
                      _convertToStringDynamicMap(data['attendance']));
                } else {
                  _logDebug('📋 Parsing check-in response from "data" field');
                  return AttendanceModel.fromJson(data);
                }
              } else {
                _logDebug('📋 Parsing check-in response from entire response');
                return AttendanceModel.fromJson(
                    _convertToStringDynamicMap(jsonData));
              }
            } else if (jsonData is List &&
                jsonData.isNotEmpty &&
                jsonData[0] is Map) {
              // PERBAIKAN: Handle jika respons berupa array
              _logDebug('📋 Parsing check-in response from first array item');
              return AttendanceModel.fromJson(
                  _convertToStringDynamicMap(jsonData[0]));
            } else {
              _logDebug(
                  '🔨 Creating basic success model as response is not a map or list');
              // PERBAIKAN: Gunakan informasi dari respons jika available
              return AttendanceModel(
                isCheckedIn: true,
                date: DateTime.now().toString().split(' ')[0],
                shiftId: shiftId,
                checkInTime: DateFormat('HH:mm:ss').format(DateTime.now()),
              );
            }
          } catch (e) {
            _logDebug('⚠️ Error parsing check-in response: $e');
            _logDebug('📄 Raw response body: ${response.body}');

            // Even if parsing fails but status code is successful,
            // create a basic success model
            return AttendanceModel(
              isCheckedIn: true,
              date: DateTime.now().toString().split(' ')[0],
              shiftId: shiftId,
              checkInTime: DateFormat('HH:mm:ss').format(DateTime.now()),
            );
          }
        } else if (response.statusCode == 500 && retryCount < maxRetries) {
          // Retry for server errors
          retryCount++;
          _logDebug(
              '⚠️ Server error (500), mencoba lagi (percobaan $retryCount dari $maxRetries)');
          await Future.delayed(retryDelay);
          continue; // Retry the request
        } else {
          _logDebug('❌ Check-in failed with status: ${response.statusCode}');
          _logDebug('❌ Response body: ${response.body}');

          // PERBAIKAN: Error message yang lebih informatif
          String errorMessage =
              'Failed to check in. Status code: ${response.statusCode}';
          try {
            final errorJson = json.decode(response.body);
            if (errorJson is Map && errorJson.containsKey('message')) {
              errorMessage += ', Error: ${errorJson['message']}';
            }
          } catch (_) {}

          throw Exception(errorMessage);
        }
      } catch (e) {
        if (e is TimeoutException && retryCount < maxRetries) {
          retryCount++;
          _logDebug(
              '⏱️ Request timeout, mencoba lagi (percobaan $retryCount dari $maxRetries)');
          await Future.delayed(retryDelay);
          continue; // Retry the request
        }

        _logDebug('❌ Error during check-in: $e');
        rethrow; // Rethrow the error to handle it in the controller
      }

      // If we reach here, we've either succeeded or exhausted all retries
      break;
    }

    // Fallback if all attempts fail but don't throw an exception
    _logDebug('⚠️ Semua upaya check-in gagal, mengembalikan model kosong');
    return AttendanceModel.empty();
  }

  // Method untuk check in tanpa foto
  Future<AttendanceModel> checkIn({String shiftId = '1'}) async {
    int retryCount = 0;
    const maxRetries = 2;
    const retryDelay = Duration(seconds: 2);

    while (true) {
      try {
        final token = await _storageService.getToken();
        if (token == null || token.isEmpty) {
          _logDebug('❌ Tidak ada token autentikasi tersedia untuk check-in');
          throw Exception('No authentication token available');
        }

        // Log waktu saat ini untuk debugging
        final now = DateTime.now();
        _logDebug('⏰ Waktu check-in: ${now.hour}:${now.minute}:${now.second}');
        _logDebug('📥 Mengirim permintaan check-in dengan shift_id: $shiftId');
        _logDebug(
            '📝 Token prefix: ${token.length > 10 ? "${token.substring(0, 10)}..." : token}');

        // PERBAIKAN: Mengonversi shiftId menjadi integer sebelum dikirim
        int shiftIdInt;
        try {
          shiftIdInt = int.parse(shiftId);
          _logDebug('✅ Berhasil mengonversi shift_id ke integer: $shiftIdInt');
        } catch (e) {
          // Default ke 1 jika parsing gagal
          shiftIdInt = 1;
          _logDebug(
              '⚠️ Peringatan: Gagal mengurai shift_id, menggunakan default: 1');
        }

        // Buat request body
        final requestBody = json.encode({
          'shift_id': shiftIdInt,
        });

        // Kirim request
        final response = await http
            .post(
          Uri.parse('$baseUrl/api/attendance/check-in'),
          headers: await _getHeaders(token),
          body: requestBody,
        )
            .timeout(const Duration(seconds: 20), onTimeout: () {
          throw TimeoutException('Request timed out');
        });

        _logDebug('🔄 Check-in API response status: ${response.statusCode}');
        _logDebug('📄 Check-in API response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          try {
            final jsonData = json.decode(response.body);
            _logDebug('✅ Successfully decoded JSON response');

            // Handle different API response structures
            if (jsonData is Map) {
              if (jsonData.containsKey('data') && jsonData['data'] is Map) {
                Map<String, dynamic> data =
                    _convertToStringDynamicMap(jsonData['data']);

                // Cek apakah ada data attendance
                if (data.containsKey('attendance') &&
                    data['attendance'] is Map) {
                  _logDebug(
                      '📋 Parsing check-in response from "attendance" field');
                  return AttendanceModel.fromJson(
                      _convertToStringDynamicMap(data['attendance']));
                } else {
                  _logDebug('📋 Parsing check-in response from "data" field');
                  return AttendanceModel.fromJson(data);
                }
              } else {
                _logDebug('📋 Parsing check-in response from entire response');
                return AttendanceModel.fromJson(
                    _convertToStringDynamicMap(jsonData));
              }
            } else if (jsonData is List &&
                jsonData.isNotEmpty &&
                jsonData[0] is Map) {
              // PERBAIKAN: Handle jika respons berupa array
              _logDebug('📋 Parsing check-in response from first array item');
              return AttendanceModel.fromJson(
                  _convertToStringDynamicMap(jsonData[0]));
            } else {
              _logDebug(
                  '🔨 Creating basic success model as response is not a map');
              // If the response is not a map, create a basic success model
              final now = DateTime.now();
              return AttendanceModel(
                isCheckedIn: true,
                date: now.toString().split(' ')[0],
                shiftId: shiftId,
                checkInTime: DateFormat('HH:mm:ss').format(now),
                checkOutTime: null,
              );
            }
          } catch (e) {
            _logDebug('⚠️ Error parsing check-in response: $e');
            _logDebug('📄 Raw response body: ${response.body}');

            // Even if parsing fails but status code is successful,
            // create a basic success model
            final now = DateTime.now();
            return AttendanceModel(
              isCheckedIn: true,
              date: now.toString().split(' ')[0],
              shiftId: shiftId,
              checkInTime: DateFormat('HH:mm:ss').format(now),
              checkOutTime: null,
            );
          }
        } else if (response.statusCode == 500 && retryCount < maxRetries) {
          // Retry for server errors
          retryCount++;
          _logDebug(
              '⚠️ Server error (500), mencoba lagi (percobaan $retryCount dari $maxRetries)');
          await Future.delayed(retryDelay);
          continue; // Retry the request
        } else {
          _logDebug('❌ Check-in failed with status: ${response.statusCode}');
          _logDebug('❌ Response body: ${response.body}');

          // PERBAIKAN: Error message yang lebih informatif
          String errorMessage =
              'Failed to check in. Status code: ${response.statusCode}';
          try {
            final errorJson = json.decode(response.body);
            if (errorJson is Map && errorJson.containsKey('message')) {
              errorMessage += ', Error: ${errorJson['message']}';
            }
          } catch (_) {}

          throw Exception(errorMessage);
        }
      } catch (e) {
        if (e is TimeoutException && retryCount < maxRetries) {
          retryCount++;
          _logDebug(
              '⏱️ Request timeout, mencoba lagi (percobaan $retryCount dari $maxRetries)');
          await Future.delayed(retryDelay);
          continue; // Retry the request
        }

        _logDebug('❌ Error during check-out with photo: $e');
        rethrow; // Rethrow the error to handle it in the controller
      }

      // If we reach here, we've either succeeded or exhausted all retries
      break;
    }

    // Fallback if all attempts fail but don't throw an exception
    _logDebug('⚠️ Semua upaya check-in gagal, mengembalikan model kosong');
    return AttendanceModel.empty();
  }

  // Method untuk check out tanpa foto
  Future<AttendanceModel> checkOut() async {
    int retryCount = 0;
    const maxRetries = 2;
    const retryDelay = Duration(seconds: 2);

    while (true) {
      try {
        final token = await _storageService.getToken();
        if (token == null || token.isEmpty) {
          _logDebug('❌ Tidak ada token autentikasi tersedia untuk check-out');
          throw Exception('No authentication token available');
        }

        // Log waktu saat ini untuk debugging
        final now = DateTime.now();
        _logDebug('⏰ Waktu check-out: ${now.hour}:${now.minute}:${now.second}');
        _logDebug('📥 Mengirim permintaan check-out');
        _logDebug(
            '📝 Token prefix: ${token.length > 10 ? "${token.substring(0, 10)}..." : token}');

        // Buat request body (kosong untuk checkout)
        final requestBody = json.encode({});

        // Kirim request
        final response = await http
            .post(
          Uri.parse('$baseUrl/api/attendance/check-out'),
          headers: await _getHeaders(token),
          body: requestBody,
        )
            .timeout(const Duration(seconds: 20), onTimeout: () {
          throw TimeoutException('Request timed out');
        });

        _logDebug('🔄 Check-out API response status: ${response.statusCode}');
        _logDebug('📄 Check-out API response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          try {
            final jsonData = json.decode(response.body);
            _logDebug('✅ Successfully decoded JSON response');

            // Handle different API response structures
            if (jsonData is Map) {
              if (jsonData.containsKey('data') && jsonData['data'] is Map) {
                Map<String, dynamic> data =
                    _convertToStringDynamicMap(jsonData['data']);

                // Cek apakah ada data attendance
                if (data.containsKey('attendance') &&
                    data['attendance'] is Map) {
                  _logDebug(
                      '📋 Parsing check-out response from "attendance" field');
                  return AttendanceModel.fromJson(
                      _convertToStringDynamicMap(data['attendance']));
                } else {
                  _logDebug('📋 Parsing check-out response from "data" field');
                  return AttendanceModel.fromJson(data);
                }
              } else {
                _logDebug('📋 Parsing check-out response from entire response');
                return AttendanceModel.fromJson(
                    _convertToStringDynamicMap(jsonData));
              }
            } else if (jsonData is List &&
                jsonData.isNotEmpty &&
                jsonData[0] is Map) {
              // PERBAIKAN: Handle jika respons berupa array
              _logDebug('📋 Parsing check-out response from first array item');
              return AttendanceModel.fromJson(
                  _convertToStringDynamicMap(jsonData[0]));
            } else {
              _logDebug(
                  '🔨 Creating basic success model as response is not a map');
              // If the response is not a map, create a basic success model
              final now = DateTime.now();
              return AttendanceModel(
                isCheckedIn: true,
                date: now.toString().split(' ')[0],
                shiftId: '1', // Default shift if not available
                checkInTime: DateFormat('HH:mm:ss').format(now.subtract(
                    Duration(hours: 1))), // Assume checked in an hour ago
                checkOutTime: DateFormat('HH:mm:ss').format(now),
              );
            }
          } catch (e) {
            _logDebug('⚠️ Error parsing check-out response: $e');
            _logDebug('📄 Raw response body: ${response.body}');

            // Even if parsing fails but status code is successful,
            // create a basic success model
            final now = DateTime.now();
            return AttendanceModel(
              isCheckedIn: true,
              date: now.toString().split(' ')[0],
              shiftId: '1', // Default shift if not available
              checkInTime: DateFormat('HH:mm:ss').format(now.subtract(
                  Duration(hours: 1))), // Assume checked in an hour ago
              checkOutTime: DateFormat('HH:mm:ss').format(now),
            );
          }
        } else if (response.statusCode == 500 && retryCount < maxRetries) {
          // Retry for server errors
          retryCount++;
          _logDebug(
              '⚠️ Server error (500), mencoba lagi (percobaan $retryCount dari $maxRetries)');
          await Future.delayed(retryDelay);
          continue; // Retry the request
        } else {
          _logDebug('❌ Check-out failed with status: ${response.statusCode}');
          _logDebug('❌ Response body: ${response.body}');

          // PERBAIKAN: Error message yang lebih informatif
          String errorMessage =
              'Failed to check out. Status code: ${response.statusCode}';
          try {
            final errorJson = json.decode(response.body);
            if (errorJson is Map && errorJson.containsKey('message')) {
              errorMessage += ', Error: ${errorJson['message']}';
            }
          } catch (_) {}

          throw Exception(errorMessage);
        }
      } catch (e) {
        if (e is TimeoutException && retryCount < maxRetries) {
          retryCount++;
          _logDebug(
              '⏱️ Request timeout, mencoba lagi (percobaan $retryCount dari $maxRetries)');
          await Future.delayed(retryDelay);
          continue; // Retry the request
        }

        _logDebug('❌ Error during check-out: $e');
        rethrow; // Rethrow the error to handle it in the controller
      }

      // If we reach here, we've either succeeded or exhausted all retries
      break;
    }

    // Fallback if all attempts fail but don't throw an exception
    _logDebug('⚠️ Semua upaya check-out gagal, mengembalikan model kosong');
    return AttendanceModel.empty();
  }

  // Method untuk check out dengan foto
  Future<AttendanceModel> checkOutWithPhoto(File photoFile) async {
    int retryCount = 0;
    const maxRetries = 2;
    const retryDelay = Duration(seconds: 2);

    while (true) {
      try {
        final token = await _storageService.getToken();
        if (token == null || token.isEmpty) {
          _logDebug('❌ Tidak ada token autentikasi tersedia untuk check-out');
          throw Exception('No authentication token available');
        }

        _logDebug('📥 Mengirim permintaan check-out dengan foto');
        _logDebug(
            '📝 Token prefix: ${token.length > 10 ? "${token.substring(0, math.min(10, token.length))}..." : token}');

        // Buat request multipart untuk mengirim foto
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/api/attendance/check-out'),
        );

        // Tambahkan headers
        final headers = await _getHeaders(token);
        headers.forEach((key, value) {
          request.headers[key] = value;
        });

        // Tambahkan file foto
        var photoStream = http.ByteStream(photoFile.openRead());
        var photoLength = await photoFile.length();
        var photoFileName = photoFile.path.split('/').last;

        var multipartFile = http.MultipartFile(
          'photo',
          photoStream,
          photoLength,
          filename: photoFileName,
        );

        request.files.add(multipartFile);
        _logDebug('📦 Request prepared with photo: $photoFileName');

        // Kirim request
        var streamedResponse = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );

        // Konversi ke http.Response
        final response = await http.Response.fromStream(streamedResponse);

        _logDebug('🔄 Check-out API response status: ${response.statusCode}');
        _logDebug('📄 Check-out API response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          try {
            final jsonData = json.decode(response.body);
            _logDebug('✅ Successfully decoded JSON response');

            // Handle different API response structures
            if (jsonData is Map) {
              if (jsonData.containsKey('data') && jsonData['data'] is Map) {
                Map<String, dynamic> data =
                    _convertToStringDynamicMap(jsonData['data']);

                // Cek apakah ada data attendance
                if (data.containsKey('attendance') &&
                    data['attendance'] is Map) {
                  _logDebug(
                      '📋 Parsing check-out response from "attendance" field');
                  return AttendanceModel.fromJson(
                      _convertToStringDynamicMap(data['attendance']));
                } else {
                  _logDebug('📋 Parsing check-out response from "data" field');
                  return AttendanceModel.fromJson(data);
                }
              } else {
                _logDebug('📋 Parsing check-out response from entire response');
                return AttendanceModel.fromJson(
                    _convertToStringDynamicMap(jsonData));
              }
            } else if (jsonData is List &&
                jsonData.isNotEmpty &&
                jsonData[0] is Map) {
              // PERBAIKAN: Handle jika respons berupa array
              _logDebug('📋 Parsing check-out response from first array item');
              return AttendanceModel.fromJson(
                  _convertToStringDynamicMap(jsonData[0]));
            } else {
              _logDebug(
                  '🔨 Creating basic success model as response is not a map');
              // If the response is not a map, create a basic success model
              final now = DateTime.now();
              return AttendanceModel(
                isCheckedIn: true,
                date: now.toString().split(' ')[0],
                shiftId: '1', // Default shift if not available
                checkInTime: DateFormat('HH:mm:ss').format(now.subtract(
                    Duration(hours: 1))), // Assume checked in an hour ago
                checkOutTime: DateFormat('HH:mm:ss').format(now),
              );
            }
          } catch (e) {
            _logDebug('⚠️ Error parsing check-out response: $e');
            _logDebug('📄 Raw response body: ${response.body}');

            // Even if parsing fails but status code is successful,
            // create a basic success model
            final now = DateTime.now();
            return AttendanceModel(
              isCheckedIn: true,
              date: now.toString().split(' ')[0],
              shiftId: '1', // Default shift if not available
              checkInTime: DateFormat('HH:mm:ss').format(now.subtract(
                  Duration(hours: 1))), // Assume checked in an hour ago
              checkOutTime: DateFormat('HH:mm:ss').format(now),
            );
          }
        } else if (response.statusCode == 500 && retryCount < maxRetries) {
          // Retry for server errors
          retryCount++;
          _logDebug(
              '⚠️ Server error (500), mencoba lagi (percobaan $retryCount dari $maxRetries)');
          await Future.delayed(retryDelay);
          continue; // Retry the request
        } else {
          _logDebug('❌ Check-out failed with status: ${response.statusCode}');
          _logDebug('❌ Response body: ${response.body}');

          // PERBAIKAN: Error message yang lebih informatif
          String errorMessage =
              'Failed to check out. Status code: ${response.statusCode}';
          try {
            final errorJson = json.decode(response.body);
            if (errorJson is Map && errorJson.containsKey('message')) {
              errorMessage += ', Error: ${errorJson['message']}';
            }
          } catch (_) {}

          throw Exception(errorMessage);
        }
      } catch (e) {
        if (e is TimeoutException && retryCount < maxRetries) {
          retryCount++;
          _logDebug(
              '⏱️ Request timeout, mencoba lagi (percobaan $retryCount dari $maxRetries)');
          await Future.delayed(retryDelay);
          continue; // Retry the request
        }

        _logDebug('❌ Error during check-out: $e');
        rethrow; // Rethrow the error to handle it in the controller
      }

      // If we reach here, we've either succeeded or exhausted all retries
      break;
    }

    // Fallback if all attempts fail but don't throw an exception
    _logDebug('⚠️ Semua upaya check-out gagal, mengembalikan model kosong');
    return AttendanceModel.empty();
  }

  // Improved helper method to generate request headers with authentication token
  Future<Map<String, String>> _getHeaders([String? token]) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      String? finalToken = token;

      if (finalToken == null || finalToken.isEmpty) {
        // Try to get token from storage if not provided
        finalToken = await _storageService.getToken();
      }

      if (finalToken != null && finalToken.isNotEmpty) {
        // Pastikan token tidak memiliki whitespace atau karakter tidak valid
        finalToken = finalToken.trim();

        // Log token prefix untuk debugging
        _logDebug(
            '🔑 Using token: ${finalToken.substring(0, math.min(10, finalToken.length))}...');

        // Pastikan format Authorization header benar
        if (finalToken.startsWith('Bearer ')) {
          headers['Authorization'] = finalToken;
          _logDebug('Token sudah memiliki prefix Bearer');
        } else {
          headers['Authorization'] = 'Bearer $finalToken';
          _logDebug('Menambahkan prefix Bearer ke token');
        }

        // Tambahkan header tambahan yang mungkin diperlukan oleh API
        headers['X-Requested-With'] = 'XMLHttpRequest';
      } else {
        _logDebug('⚠️ Peringatan: Tidak ada token tersedia untuk request');
      }
    } catch (e) {
      _logDebug('⚠️ Error setting auth headers: $e');
    }

    _logDebug('📤 Headers yang dikirim: $headers');
    return headers;
  }

  // Helper untuk mengonversi Map<dynamic, dynamic> menjadi Map<String, dynamic>
  // Diperbarui untuk menangani nilai shift dengan lebih baik
  Map<String, dynamic> _convertToStringDynamicMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data; // Sudah dalam format yang benar
    } else if (data is Map) {
      // Konversi ke Map<String, dynamic>
      Map<String, dynamic> result = {};
      data.forEach((key, value) {
        // Tambahkan logging untuk debugging nilai shift
        if (key.toString() == 'shift_id' || key.toString() == 'shift') {
          _logDebug(
              '🔍 Ditemukan data shift dalam respons API: $key = $value (${value.runtimeType})');
        }

        // Tambahkan logging untuk waktu check-in/check-out
        if (key.toString().contains('time') ||
            key.toString().contains('date')) {
          _logDebug('⏰ Ditemukan data waktu dalam respons API: $key = $value');
        }

        result[key.toString()] = value;
      });
      return result;
    }
    // Fallback jika bukan Map
    return {'error': 'Invalid data format'};
  }

  // Method untuk mendapatkan riwayat kehadiran
  Future<AttendanceHistoryModel> getAttendanceHistory() async {
    try {
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token available');
      }

      _logDebug(
          '🔍 Mengambil riwayat kehadiran dengan token: ${token.substring(0, math.min(10, token.length))}...');

      final response = await http
          .get(
        Uri.parse('$baseUrl/api/shifts/history'),
        headers: await _getHeaders(token),
      )
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      _logDebug('📊 Attendance history response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);
        _logDebug('📋 Attendance history data: $jsonData');

        if (jsonData is Map && jsonData.containsKey('data')) {
          return AttendanceHistoryModel.fromJson(jsonData['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        _logDebug(
            '❌ Failed to get attendance history: ${response.statusCode}, ${response.body}');
        throw Exception(
            'Failed to get attendance history. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _logDebug('❌ Error getting attendance history: $e');
      throw Exception('Failed to get attendance history: $e');
    }
  }

  // Helper untuk logging
  void _logDebug(String message) {
    // TODO: Ganti dengan framework logging yang sebenarnya
    // Contoh: Logger.d(message) atau log.debug(message)
    if (isDebugMode) {
      // Hanya log di mode debug
      // ignore: avoid_print
      print(message);
    }
  }

  // Dispose method untuk membersihkan resources
  void dispose() {
    _autoCheckoutTimer?.cancel();
  }
}
