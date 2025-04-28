import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../navigation/NavController.dart';
import '../HomeController/HomeController.dart';
import 'package:intl/intl.dart';
import '../../../gudang_page/GudangModel/ProductModel.dart';

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
      backgroundColor: const Color(0xFFF1F9E9), // Light green background color
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.loadProducts(),
          color: const Color(0xFFA9CD47),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.04, // Horizontal padding (4% of screen width)
                  screenHeight * 0.04, // Top padding (4% of screen height)
                  screenWidth * 0.04, // Horizontal padding (4% of screen width)
                  screenWidth * 0.04), // Bottom padding (4% of screen width)
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top header with profile and notification
                  _buildHeader(screenWidth),
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
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              // Profile picture
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage('assets/profile_pic.jpg'),
              ),
              SizedBox(width: screenWidth * 0.03),
              // Welcome text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use Obx to reactively update the username
                    Obx(() {
                      return Text(
                        controller.username.value.isNotEmpty
                            ? controller.username.value
                            : 'User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                    Row(
                      children: const [
                        Flexible(
                          child: Text(
                            'Selamat Datang Kembali',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.waving_hand, color: Colors.amber, size: 18)
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Notification icon
        const Icon(Icons.notifications_outlined, color: Colors.red),
      ],
    );
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
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.04, // Horizontal padding
          screenHeight * 0.02, // Top padding
          screenWidth * 0.04, // Horizontal padding
          screenHeight * 0.01, // Bottom padding
        ),
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
            const SizedBox(height: 0),
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
          Obx(() => Text(
                controller.hasCheckedIn.value
                    ? "Anda Sudah Absen"
                    : 'Anda Belum Absen',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth < 360 ? 18 : 20,
                ),
                overflow: TextOverflow.ellipsis,
              )),
          SizedBox(height: screenHeight * 0.005),
          Obx(() => Row(
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
                      controller.getShiftTime(controller.selectedShift.value),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                      .format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButton(double screenHeight) {
    // Adjust button height based on screen size
    final buttonHeight = screenHeight < 600 ? 70.0 : 90.0;

    return Container(
      height: buttonHeight,
      width: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: () => Get.find<NavController>().changePage(3),
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
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOutOfStockHeader(screenWidth),
          SizedBox(height: screenHeight * 0.005),
          const Text(
            'Ayo segera tambah barang!',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          SizedBox(height: screenHeight * 0.02),
          SizedBox(
            height: screenHeight * 0.17, // Responsive height
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
                        style: TextStyle(
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
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
                return Center(
                  child: Text(
                    'No out of stock items',
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
          'Out Of Stock',
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
    return Container(
      width: 35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 30,
            width: 30,
            margin: EdgeInsets.only(top: 43),
            child: Container(
              decoration: BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.black,
                  size: 25,
                ),
              ),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'More',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon) {
    return Column(
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
    );
  }

  Widget _buildProductItem(Product item) {
    // Primary green color
    final Color primaryGreen = Color(0xFFA9CD47);

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
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
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
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
                              return Center(
                                child: Icon(
                                  Icons.checkroom,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.checkroom,
                            size: 40,
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
                        'SOLD OUT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                if (item.code != null)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.code!,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6),
          Text(
            '${item.name} / ${item.size}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
