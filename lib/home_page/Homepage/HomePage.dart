import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../navigation/NavController.dart';
import '../../../attendance_page/AttendanceController.dart';

class HomePage extends GetView<AttendanceController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F9E9), // Light green background color
      body: SafeArea(
        child: SingleChildScrollView(
          // Added SingleChildScrollView for safety
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                16.0, 36.0, 16.0, 16.0), // Increased top padding from 32 to 50
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header with profile and notification
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Profile picture
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey,
                          backgroundImage: AssetImage('assets/profile_pic.jpg'),
                        ),
                        SizedBox(width: 12),
                        // Welcome text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arka Narendra',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Selamat Datang Kembali',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.waving_hand,
                                    color: Colors.amber, size: 18)
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Notification icon
                    Icon(Icons.notifications_outlined, color: Colors.red),
                  ],
                ),
                SizedBox(height: 32),
                // Layered cards - Attendance status and Category cards
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Bottom layer - Category card
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 80.0), // Push down to create layered effect
                      child: Container(
                        padding: EdgeInsets.only(
                            top: 80,
                            bottom: 16), // Extra padding on top for overlap
                        decoration: BoxDecoration(
                          color: Color(0xFF282828),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCategoryItem('T-Shirt', Icons.checkroom),
                            _buildCategoryItem('Kids', Icons.child_care),
                            _buildCategoryItem(
                                'Pants', Icons.accessibility_new),
                            _buildCategoryItem('Adults', Icons.person),
                            _buildCategoryItem('Uniform', Icons.school),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 80),
                    // Top layer - Attendance status card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
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
                            SizedBox(height: 0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(() => Text(
                                          controller.hasCheckedIn
                                              ? 'Anda Sudah Absen'
                                              : 'Anda Belum Absen',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        )),
                                    SizedBox(height: 4),
                                    Obx(() => Row(
                                          children: [
                                            Text(
                                              'Shift ${controller.selectedShift} | ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              controller.getShiftTime(
                                                  controller.selectedShift),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        )),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 14, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(
                                          controller.getCurrentDateFormatted(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Vertically stretched arrow button
                                Container(
                                  height: 90,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF282828),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.find<NavController>().changePage(
                                          3); // Index 3 is for AttendancePage
                                    },
                                    child: Center(
                                      child: Icon(
                                        Icons.chevron_right,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                    height:
                        20), // Increased spacing to account for the layered effect

                // Out of stock section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF282828),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Out Of Stock',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFFA9CD47)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextButton(
                              onPressed: () {
                                Get.find<NavController>()
                                    .changePage(1); // Index 2 for GudangPage
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Lihat gudang',
                                    style: TextStyle(
                                        color: Color(0xFFA9CD47), fontSize: 12),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward,
                                      color: Color(0xFFA9CD47), size: 12),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ayo segera tambah barang!',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 140,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildProductItem('Koko Abu / M', '3'),
                            _buildProductItem('Hem / L', '0'),
                            _buildProductItem('Koko Abu / S', '2'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFF3A3A3A),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(String title, String badge) {
    bool isOutOfStock = badge == '0';

    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: 100,
            margin: EdgeInsets.only(
                top: 10), // Added top margin to make space for the badge
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Product image container
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFA9CD47), // Green background color
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                // SOLD OUT overlay
                if (isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black.withOpacity(0.7),
                      ),
                      child: Center(
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

                // Stock badge
                if (!isOutOfStock && badge != '0')
                  Positioned(
                    top: -10,
                    right: -7,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6),
          Text(
            title,
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
}
