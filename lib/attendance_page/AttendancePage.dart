import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/attendance_page/AttendanceController.dart';
import 'package:kliktoko/camera_page/AttendanceCameraPage.dart';
import 'package:kliktoko/profile_page/ProfilePage/HistoryKerjaPage.dart';
import 'package:intl/intl.dart';
import 'package:kliktoko/attendance_page/ShiftModel.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    if (!Get.isRegistered<AttendanceController>()) {
      Get.put(AttendanceController());
    }
    final controller = Get.find<AttendanceController>();

    // Load user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.attendanceController.loadUserData();
    });

    // Responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F9E9),
      body: SafeArea(
        child: GetX<AttendanceController>(
          builder: (ctrl) => ctrl.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFAED15C)),
                  ),
                )
              : _buildContent(context, screenWidth, screenHeight, ctrl),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, double screenWidth,
      double screenHeight, AttendanceController controller) {
    return RefreshIndicator(
        onRefresh: () async {
          // Refresh radius location check first
          await controller.refreshLocation();

          // Then refresh other data
          await controller.checkAttendanceStatus();
          controller.attendanceController.loadUserData();
          controller.attendanceController.determineShift();
          await controller.attendanceController.loadAttendanceHistory();
        },
        color: const Color(0xFFAED15C),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            child: Padding(
              padding: EdgeInsets.fromLTRB(screenWidth * 0.04,
                  screenHeight * 0.04, screenWidth * 0.04, screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAttendanceStatusCard(
                      screenWidth, screenHeight, controller),
                  SizedBox(height: screenHeight * 0.025),
                  _buildShiftInfoCard(screenWidth, screenHeight, controller),
                  SizedBox(height: screenHeight * 0.025),
                  SizedBox(height: screenHeight * 0.04),
                  _buildCheckInOutButton(controller),
                  SizedBox(height: screenHeight * 0.010),
                ],
              ),
            ),
          ),
        ));
  }

  // Header with profile info
  // Widget _buildHeader(double screenWidth, AttendanceController controller) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Expanded(
  //         child: Row(
  //           children: [
  //             CircleAvatar(
  //               radius: 20,
  //               backgroundColor: Colors.grey[300],
  //               backgroundImage: const AssetImage('assets/profile_pic.jpg'),
  //             ),
  //             SizedBox(width: screenWidth * 0.03),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Obx(() => Text(
  //                         controller.username.value.isNotEmpty
  //                             ? controller.username.value
  //                             : 'User',
  //                         style: const TextStyle(
  //                             fontWeight: FontWeight.bold, fontSize: 14),
  //                         overflow: TextOverflow.ellipsis,
  //                       )),
  //                   Obx(() {
  //                     final isOutsideShiftHours = controller
  //                         .attendanceController.isOutsideShiftHours.value;
  //                     final shiftStatus =
  //                         controller.attendanceController.shiftStatus.value;
  //                     return Row(
  //                       children: [
  //                         Flexible(
  //                           child: Text(
  //                             isOutsideShiftHours || !shiftStatus.isActive
  //                                 ? 'Selamat Beristirahat'
  //                                 : 'Selamat Datang Kembali',
  //                             style: const TextStyle(
  //                                 fontSize: 16, fontWeight: FontWeight.w500),
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                         ),
  //                         const SizedBox(width: 4),
  //                         Icon(
  //                             isOutsideShiftHours || !shiftStatus.isActive
  //                                 ? Icons.nightlight_round
  //                                 : Icons.waving_hand,
  //                             color:
  //                                 isOutsideShiftHours || !shiftStatus.isActive
  //                                     ? Colors.indigo
  //                                     : Colors.amber,
  //                             size: 18)
  //                       ],
  //                     );
  //                   }),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       const Icon(Icons.notifications_outlined, color: Colors.red),
  //     ],
  //   );
  // }

  // Card showing attendance status
  Widget _buildAttendanceStatusCard(double screenWidth, double screenHeight,
      AttendanceController controller) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Kehadiran',
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 11.5),

          // Radius Status Display
          Obx(() => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: controller.isWithinRadius.value
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: controller.isWithinRadius.value
                        ? Colors.green
                        : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.isWithinRadius.value
                          ? Icons.location_on
                          : Icons.location_off,
                      color: controller.isWithinRadius.value
                          ? Colors.green
                          : Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      controller.locationStatus.value,
                      style: TextStyle(
                        color: controller.isWithinRadius.value
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              )),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      // Loading indicator
                      if (controller.isLoading.value) {
                        return Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFAED15C)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Memeriksa status...',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        );
                      }

                      // Status text and color based on shift status
                      String statusText;
                      Color? statusColor;

                      final status =
                          controller.attendanceController.shiftStatus.value;

                      if (status.isActive) {
                        if (status.data?.checkOut != null) {
                          statusText = 'Anda Sudah Check-out';
                          statusColor = Colors.blue[700];
                        } else if (status.data?.isLate ?? false) {
                          statusText = 'Anda Terlambat';
                          statusColor = Colors.orange[700];
                        } else {
                          statusText = 'Anda Sedang Aktif';
                          statusColor = Colors.green[700];
                        }
                      } else {
                        // Gunakan pesan dari API atau pesan default
                        if (status.message.isNotEmpty) {
                          statusText = status.message;
                          statusColor = Colors.grey[700];
                        } else {
                          statusText = 'Tidak Ada Shift Saat Ini';
                          statusColor = Colors.grey[700];
                        }
                      }

                      return Text(
                        statusText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: statusColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                    SizedBox(height: screenHeight * 0.005),

                    SizedBox(height: screenHeight * 0.005),

                    // Date
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                                .format(DateTime.now()),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card showing shift info
  Widget _buildShiftInfoCard(double screenWidth, double screenHeight,
      AttendanceController controller) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jadwal Shift:',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: screenHeight * 0.015),
          Obx(() {
            final shiftMap = controller.attendanceController.shiftMap.value;
            final shiftStatus =
                controller.attendanceController.shiftStatus.value;

            // Cari shift yang aktif dari API
            ShiftModel? activeShift;
            for (final shift in shiftMap.values) {
              if (shift.isCurrentTimeInShift()) {
                activeShift = shift;
                break;
              }
            }

            // Jika tidak ada shift aktif dari API, cek shiftStatus sebagai fallback
            if (activeShift == null) {
              bool hasActiveShiftFromMessage =
                  shiftStatus.message.contains('belum absen di shift') &&
                      !shiftStatus.message.contains('tidak ada shift');

              if (hasActiveShiftFromMessage) {
                // Extract shift number from message
                final shiftMatch =
                    RegExp(r'shift (\d+)').firstMatch(shiftStatus.message);
                if (shiftMatch != null) {
                  final shiftNumber = shiftMatch.group(1);
                  // Find shift from shiftMap
                  for (final shift in shiftMap.values) {
                    if (shift.id.toString() == shiftNumber) {
                      activeShift = shift;
                      break;
                    }
                  }
                }
              }
            }

            if (shiftMap.isNotEmpty) {
              final shiftList = shiftMap.values.toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tampilkan semua shift yang tersedia
                  ...shiftList.map((shift) {
                    final formattedTime = shift.getFormattedTimeRange();
                    final isActive = activeShift?.id == shift.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFE8F5E8)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFFA9CD47)
                              : Colors.grey[300]!,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFA9CD47)
                                  : Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shift.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? const Color(0xFFA9CD47)
                                        : Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isActive
                                        ? const Color(0xFFA9CD47)
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFA9CD47),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'AKTIF',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Tampilkan status dari API jika ada
                  if (shiftStatus.message.isNotEmpty && activeShift == null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[300]!),
                      ),
                      child: Text(
                        shiftStatus.message,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                ],
              );
            } else {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Text(
                  'Memuat jadwal shift...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  // Improved Check-in/Check-out button
  Widget _buildCheckInOutButton(AttendanceController controller) {
    return Obx(() {
      final bool isCheckedIn = controller.hasCheckedIn.value;
      final bool isCheckedOut = controller.hasCheckedOut.value;
      final bool isLoading = controller.isLoading.value;
      final shiftStatus = controller.attendanceController.shiftStatus.value;
      final shiftMap = controller.attendanceController.shiftMap.value;

      // Debug logging
      print('🔍 Button Debug:');
      print('   - isCheckedIn: $isCheckedIn');
      print('   - isCheckedOut: $isCheckedOut');
      print('   - isLoading: $isLoading');
      print('   - shiftStatus.isActive: ${shiftStatus.isActive}');
      print('   - shiftStatus.message: ${shiftStatus.message}');
      print('   - shiftStatus.data?.checkIn: ${shiftStatus.data?.checkIn}');
      print('   - shiftStatus.data?.checkOut: ${shiftStatus.data?.checkOut}');
      print('   - shiftMap.length: ${shiftMap.length}');

      // Loading state
      if (isLoading) {
        return _buildButton(
          color: Colors.grey[400]!,
          onPressed: null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Memproses...',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
        );
      }

      // Cek apakah ada shift yang aktif berdasarkan data dari API /api/shifts
      bool hasActiveShift = false;
      String activeShiftName = '';
      String selectedShiftId = '';

      // Loop melalui semua shift dari API untuk mencari yang aktif
      for (final shift in shiftMap.values) {
        if (shift.isCurrentTimeInShift()) {
          hasActiveShift = true;
          activeShiftName = shift.name;
          selectedShiftId = shift.id.toString();
          print('✅ Found active shift: ${shift.name} (ID: ${shift.id})');
          break;
        }
      }

      // Jika tidak ada shift aktif dari API, cek shiftStatus sebagai fallback
      if (!hasActiveShift) {
        hasActiveShift = shiftStatus.isActive;
        print('⚠️ Using shiftStatus.isActive as fallback: $hasActiveShift');
      }

      // Cek apakah ada pesan yang menunjukkan shift aktif (seperti "Anda belum absen di shift X")
      bool hasActiveShiftFromMessage =
          shiftStatus.message.contains('belum absen di shift') &&
              !shiftStatus.message.contains('tidak ada shift');

      // Jika tidak ada shift aktif dari API tapi ada pesan shift aktif, gunakan itu
      if (!hasActiveShift && hasActiveShiftFromMessage) {
        hasActiveShift = true;
        // Extract shift number from message
        final shiftMatch =
            RegExp(r'shift (\d+)').firstMatch(shiftStatus.message);
        if (shiftMatch != null) {
          final shiftNumber = shiftMatch.group(1);
          selectedShiftId = shiftNumber!;
          // Find shift name from shiftMap
          for (final shift in shiftMap.values) {
            if (shift.id.toString() == shiftNumber) {
              activeShiftName = shift.name;
              break;
            }
          }
        }
        print('✅ Using shift from message: ${shiftStatus.message}');
      }

      // Update selectedShift outside of Obx to avoid setState during build
      if (selectedShiftId.isNotEmpty &&
          selectedShiftId != controller.selectedShift.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.selectedShift.value = selectedShiftId;
        });
      }

      print('🔍 Final hasActiveShift: $hasActiveShift');
      print('🔍 Active shift name: $activeShiftName');
      print('🔍 Selected shift ID: $selectedShiftId');

      // No active shift available
      if (!hasActiveShift) {
        return _buildButton(
          color: Colors.orange[400]!,
          onPressed: null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.schedule, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  shiftStatus.message.isNotEmpty
                      ? shiftStatus.message
                      : 'Tidak Ada Shift Saat Ini',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }

      // Check if user is outside radius - button should be grey
      if (!controller.isWithinRadius.value) {
        return _buildButton(
          color: Colors.grey[400]!,
          onPressed: null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Anda berada di luar jangkauan kantor',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }

      // Check if user has already completed attendance for today (both check-in and check-out)
      if (isCheckedIn && isCheckedOut) {
        print('🔍 User has completed attendance for today');
        return _buildButton(
          color: Colors.grey[400]!,
          onPressed: null,
          child: const Text('Anda Sudah Selesai Absen Hari Ini',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        );
      }

      // Check if user has checked out (from shiftStatus data)
      if (shiftStatus.data?.checkOut != null) {
        print('🔍 User has checked out');
        return _buildButton(
          color: Colors.grey[400]!,
          onPressed: null,
          child: const Text('Anda Sudah Check-out',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        );
      }

      // Checked in but not checked out - show checkout button
      if (isCheckedIn && !isCheckedOut) {
        print(
            '🔍 User is checked in but not checked out - showing checkout button');
        return _buildButton(
          color: Colors.red,
          onPressed: () => controller.showCheckOutConfirmation(),
          child: const Text('Check-out',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        );
      }

      // Check if user has already checked in today
      if (isCheckedIn) {
        print('🔍 User has already checked in today');
        return _buildButton(
          color: Colors.grey[400]!,
          onPressed: null,
          child: const Text('Sudah Absen Hari Ini',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        );
      }

      // Not checked in - show check-in button with photo
      print('🔍 User not checked in - showing check-in button');
      return _buildButton(
        color:
            const Color(0xFF4CAF50), // Green color for successful shift check
        onPressed: () async {
          // Verify attendance status before attempting check-in
          await controller.checkAttendanceStatus();

          if (controller.hasCheckedIn.value) {
            Get.snackbar(
              'Sudah Absen',
              'Anda sudah absen hari ini',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFAED15C),
              colorText: const Color(0xFF282828),
            );
            return;
          }

          // Navigate to camera page for check-in with photo
          final result = await Get.to(
            () => AttendanceCameraPage(
                shiftId: selectedShiftId.isNotEmpty
                    ? selectedShiftId
                    : controller.selectedShift.value),
          );

          // Refresh attendance status if check-in was successful
          if (result == true) {
            await controller.checkAttendanceStatus();
            await controller.loadAttendanceHistory();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Absen ${activeShiftName.isNotEmpty ? activeShiftName : 'dengan Foto'}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ],
        ),
      );
    });
  }

  // Helper method to create consistent cards
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  // Helper method to create consistent buttons
  Widget _buildButton(
      {required Color color,
      required VoidCallback? onPressed,
      required Widget child}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
