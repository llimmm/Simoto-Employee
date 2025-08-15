import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../navigation/NavController.dart';
import '../HomeController/HomeController.dart';
import 'package:intl/intl.dart';
import '../../../gudang_page/GudangModel/ProductModel.dart';
import 'package:kliktoko/ReusablePage/categoryPage.dart'; // Added import for CategoryPage
import 'package:kliktoko/gudang_page/GudangModel/CategoryModel.dart'; // Added import for Category model
import 'package:kliktoko/gudang_page/GudangServices/CategoryService.dart'; // Added import for CategoryService

// Create a separate controller just for the clock
class ClockController extends GetxController {
  var timeString = ''.obs;
  var dateString = ''.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    // Initialize time immediately
    _updateTime();
    // Start timer to update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _updateTime() {
    final now = DateTime.now();
    timeString.value = DateFormat('HH:mm:ss').format(now);
    dateString.value = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
  }
}

// Simple clock widget
class ClockWidget extends StatelessWidget {
  const ClockWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use Get.put to ensure controller is registered before use
    final controller = Get.put(ClockController());

    return Center(
      child: Column(
        children: [
          // Current time
          Obx(() => Text(
                controller.timeString.value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  color: Color(0xFF282828),
                ),
              )),
          const SizedBox(height: 4),
          // Current date
          Obx(() => Text(
                controller.dateString.value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              )),
        ],
      ),
    );
  }
}

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Make sure controller is initialized and registered with Get
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Call loadUserData explicitly to ensure username is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkAuthAndLoadData();
    });
    return Scaffold(
        backgroundColor:
            const Color(0xFFF1F9E9), // Light green background color
        body: SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.loadProducts();
                // Also refresh attendance status when pulling to refresh
                try {
                  await controller.attendanceController.checkAttendanceStatus();
                } catch (e) {
                  print('Error refreshing attendance status: $e');
                }
                return;
              },
              color: const Color(0xFFA9CD47),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      screenWidth *
                          0.04, // Horizontal padding (4% of screen width)
                      screenHeight * 0.04, // Top padding (4% of screen height)
                      screenWidth *
                          0.04, // Horizontal padding (4% of screen width)
                      screenWidth *
                          0.04), // Bottom padding (4% of screen width)
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Clock at the top
                      const ClockWidget(),
                      SizedBox(height: screenHeight * 0.04),
                      // Layered cards - Attendance status and Category cards
                      _buildLayeredCards(screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.025),
                      // Out of stock section
                      _buildOutOfStockSection(screenWidth, screenHeight),
                      // Add extra space at the bottom to avoid navigation bar overlap
                      SizedBox(height: screenHeight * 0.08),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildLayeredCards(double screenWidth, double screenHeight) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bottom layer - Category card
        _buildCategoryCard(screenWidth, screenHeight),
        const SizedBox(height: 80),
        // Top layer - Attendance status card
        _buildAttendanceCard(screenWidth, screenHeight),
      ],
    );
  }

  Widget _buildCategoryCard(double screenWidth, double screenHeight) {
    // Calculate responsive vertical position of category card
    final topPadding = screenHeight < 600 ? 70.0 : 80.0;

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Container(
        padding: EdgeInsets.only(
            top: screenHeight * 0.1, bottom: screenHeight * 0.02),
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: screenWidth < 360
            ? Wrap(
                spacing: screenWidth * 0.05,
                runSpacing: screenHeight * 0.01,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  _buildCategoryItem('T-Shirt', Icons.checkroom),
                  _buildCategoryItem('Kids', Icons.child_care),
                  _buildCategoryItem('Pants', Icons.accessibility_new),
                  _buildCategoryItem('Adults', Icons.person),
                  _buildCategoryItem('Uniform', Icons.school),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCategoryItem('T-Shirt', Icons.checkroom),
                  _buildCategoryItem('Kids', Icons.child_care),
                  _buildCategoryItem('Pants', Icons.accessibility_new),
                  _buildCategoryItem('Adults', Icons.person),
                  _buildCategoryItem('Uniform', Icons.school),
                ],
              ),
      ),
    );
  }

  Widget _buildAttendanceCard(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.0399),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Kehadiran',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(
                height:
                    2), // Jarak sangat dikurangi menjadi nilai fixed 2 pixel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAttendanceInfo(screenWidth, screenHeight),
                _buildAttendanceButton(screenHeight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceInfo(double screenWidth, double screenHeight) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            // Get status text and color based on attendance state
            String statusText = controller.getStatusMessage();
            Color statusColor = controller.getStatusColor();

            return Text(
              statusText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth < 360 ? 18 : 20,
                color: statusColor,
              ),
              overflow: TextOverflow.ellipsis,
            );
          }),
          SizedBox(height: screenHeight * 0.005),
          Obx(() {
            // Get shift time
            final shiftTime =
                controller.getShiftTime(controller.selectedShift.value);

            // Check if it's night time message (Selamat Tidur)
            final bool isNightMessage = shiftTime == 'Selamat Tidur!';

            return isNightMessage
                ? Text(
                    shiftTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.indigo[400],
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : Row(
                    children: [
                      Text(
                        'Shift ${controller.selectedShift.value} | ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          shiftTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
          }),
          // Add check-in time if available
          Obx(() {
            if (controller.hasCheckedIn.value &&
                controller.attendanceController.currentAttendance.value
                        .checkInTime !=
                    null &&
                controller.attendanceController.currentAttendance.value
                    .checkInTime!.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.login, size: 14, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Check-in: ${controller.attendanceController.currentAttendance.value.checkInTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          // Add check-out time if available
          Obx(() {
            if (controller.hasCheckedOut.value &&
                controller.attendanceController.currentAttendance.value
                        .checkOutTime !=
                    null &&
                controller.attendanceController.currentAttendance.value
                    .checkOutTime!.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 14, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Check-out: ${controller.attendanceController.currentAttendance.value.checkOutTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildAttendanceButton(double screenHeight) {
    // Adjust button height based on screen size
    final buttonHeight = screenHeight < 600 ? 70.0 : 90.0;

    return GestureDetector(
      onTap: () => Get.find<NavController>().changePage(3),
      child: Container(
        height: buttonHeight,
        width: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.chevron_right,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildOutOfStockSection(double screenWidth, double screenHeight) {
    // Primary green color
    final Color primaryGreen = Color(0xFFA9CD47);

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOutOfStockHeader(screenWidth),
          SizedBox(height: screenHeight * 0.005),
          const Text(
            'Ayo segera tambah barang!',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          SizedBox(height: screenHeight * 0.02),
          SizedBox(
            height: 100, // Fixed height since no text below
            child: Obx(() {
              // Show error message if there's an error
              if (controller.hasError.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red[300], size: 30),
                      SizedBox(height: 8),
                      Text(
                        controller.errorMessage.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (controller.errorMessage.value
                          .contains('session')) ...[
                        SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Get.offAllNamed('/login'),
                          style: TextButton.styleFrom(
                            backgroundColor: primaryGreen,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              // Show loading indicator
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: primaryGreen,
                  ),
                );
              }

              final outOfStockItems =
                  controller.getOutOfStockItemsForDisplay(3);

              // Show message if no items
              if (outOfStockItems.isEmpty) {
                return const Center(
                  child: Text(
                    'Tidak ada item stok habis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                );
              }

              // Display the items
              return ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  ...outOfStockItems.map((item) => _buildProductItem(item)),
                  SizedBox(width: screenWidth * 0.03),
                  if (controller.outOfStockProducts.length > 3)
                    _buildMoreButton(primaryGreen),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfStockHeader(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Stok Habis',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFA9CD47)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextButton(
            onPressed: () => Get.find<NavController>().changePage(1),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: const [
                Text(
                  'Lihat gudang',
                  style: TextStyle(color: Color(0xFFA9CD47), fontSize: 12),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: Color(0xFFA9CD47), size: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreButton(Color primaryGreen) {
    return SizedBox(
      width: 35,
      height: 100, // Match the height of product cards
      child: Center(
        child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: primaryGreen,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  // Updated to navigate to CategoryPage when clicked, just like in GudangPage
  Widget _buildCategoryItem(String title, IconData icon) {
    return InkWell(
      onTap: () => _navigateToCategoryPage(title),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF3A3A3A),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // New method to navigate to CategoryPage, similar to GudangPage
  void _navigateToCategoryPage(String categoryName) {
    // Navigate to CategoryPage
    Get.to(() => CategoryPage(categoryName: categoryName));
  }

  Widget _buildProductItem(Product item) {
    // Primary green color
    final Color primaryGreen = Color(0xFFA9CD47);

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      child: Container(
        height: 80, // Fixed height for image only
        width: 100,
        margin: const EdgeInsets.only(top: 5),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: item.image != null && item.image!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          return const Center(
                            child: Icon(
                              Icons.checkroom,
                              size: 30, // Reduced icon size
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.checkroom,
                        size: 30, // Reduced icon size
                        color: Colors.white,
                      ),
                    ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withOpacity(0.7),
                ),
                child: const Center(
                  child: Text(
                    'STOK HABIS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10, // Reduced font size
                    ),
                  ),
                ),
              ),
            ),
            // Badge ukuran di pojok kanan atas
            Positioned(
              top: 3,
              right: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.size ?? 'N/A',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Code badge di pojok kiri atas (jika ada)
            if (item.code != null)
              Positioned(
                top: 3,
                left: 3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    item.code!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 7,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
