import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../navigation/NavController.dart';
import '../HomeController/HomeController.dart';
import 'package:intl/intl.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F9E9), // Light green background color
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
                _buildHeader(),
                const SizedBox(height: 32),
                // Layered cards - Attendance status and Category cards
                _buildLayeredCards(),
                const SizedBox(height: 20),
                // Out of stock section
                _buildOutOfStockSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Profile picture
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              backgroundImage: AssetImage('assets/profile_pic.jpg'),
            ),
            const SizedBox(width: 12),
            // Welcome text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Arka Narendra',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: const [
                    Text(
                      'Selamat Datang Kembali',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.waving_hand, color: Colors.amber, size: 18)
                  ],
                ),
              ],
            ),
          ],
        ),
        // Notification icon
        const Icon(Icons.notifications_outlined, color: Colors.red),
      ],
    );
  }

  Widget _buildLayeredCards() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bottom layer - Category card
        _buildCategoryCard(),
        const SizedBox(height: 80),
        // Top layer - Attendance status card
        _buildAttendanceCard(),
      ],
    );
  }

  Widget _buildCategoryCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: Container(
        padding: const EdgeInsets.only(top: 80, bottom: 16),
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
        child: Row(
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

  Widget _buildAttendanceCard() {
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
            const SizedBox(height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAttendanceInfo(),
                _buildAttendanceButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
              controller.hasCheckedIn.value
                  ? "Anda Sudah Absen"
                  : 'Anda Belum Absen',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            )),
        const SizedBox(height: 4),
        Obx(() => Row(
              children: [
                Text(
                  'Shift ${controller.selectedShift.value} | ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  controller.getShiftTime(controller.selectedShift.value),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            )),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceButton() {
    return Container(
      height: 90,
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

  Widget _buildOutOfStockSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOutOfStockHeader(),
          const SizedBox(height: 4),
          const Text(
            'Ayo segera tambah barang!',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
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
    );
  }

  Widget _buildOutOfStockHeader() {
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

  Widget _buildCategoryItem(String title, IconData icon) {
    return Column(
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
        ),
      ],
    );
  }

  Widget _buildProductItem(String title, String badge) {
    bool isOutOfStock = badge == '0';

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: 100,
            margin: const EdgeInsets.only(top: 10),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFA9CD47),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                if (isOutOfStock)
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
                if (!isOutOfStock && badge != '0')
                  Positioned(
                    top: -10,
                    right: -7,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          badge,
                          style: const TextStyle(
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
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
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
