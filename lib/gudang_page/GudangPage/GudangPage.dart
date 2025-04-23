import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/home_page/HomeController/HomeController.dart';
import '../GudangControllers/GudangController.dart';

class GudangPage extends StatefulWidget {
  const GudangPage({Key? key}) : super(key: key);

  @override
  State<GudangPage> createState() => _GudangPageState();
}

class _GudangPageState extends State<GudangPage> {
  final GudangController controller = Get.put(GudangController());
  late HomeController homeController;

  @override
  void initState() {
    super.initState();

    // Initialize HomeController if not already initialized
    if (!Get.isRegistered<HomeController>()) {
      homeController = Get.put(HomeController(), permanent: true);
    } else {
      homeController = Get.find<HomeController>();
    }

    // Subscribe to the controller's dropdown close signal
    ever(controller.shouldCloseDropdown, (shouldClose) {
      if (shouldClose && isDropdownVisible) {
        _removeOverlay();
        controller.resetDropdownFlag();
      }
    });
  }

  // Local state for the filter options
  final List<String> filterOptions = [
    'All',
    'New Arrival',
    'S Size',
    'M Size',
    'L Size',
    'XL Size',
    'XXL Size',
    'XXXL Size',
    '3L Size',
  ];

  // Green color constant
  final Color primaryGreen = Color(0xFFA9CD47);

  // Track if the dropdown menu is open
  OverlayEntry? _overlayEntry;
  bool isDropdownVisible = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      try {
        _overlayEntry?.remove();
      } catch (e) {
        // Handle any errors during removal
        print('Error removing overlay: $e');
      }
      _overlayEntry = null;
      isDropdownVisible = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _closeDropdownMenu() {
    _removeOverlay();
  }

  void _showDropdownMenu(BuildContext context, GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdownMenu,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            top: position.dy + renderBox.size.height + 5,
            left: 16, // Changed from 'right' to 'left' to match the UI
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 250,
                ),
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  // Add scrolling
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: filterOptions.map((option) {
                      return InkWell(
                        onTap: () {
                          controller.updateFilter(option);
                          _removeOverlay();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              color: controller.selectedFilter.value == option
                                  ? primaryGreen
                                  : Colors.black87,
                              fontSize: 14,
                              fontWeight:
                                  controller.selectedFilter.value == option
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    isDropdownVisible = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filterButtonKey = GlobalKey();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) => controller.updateSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: 'search',
                      hintStyle:
                          TextStyle(color: Colors.grey[400], fontSize: 16),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                        child: Icon(Icons.search,
                            color: Colors.grey[400], size: 22),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF282828),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Out Of Stock',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 140,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildProductItem('Koko Abu / M', '3'),
                            SizedBox(width: 12),
                            _buildProductItem('Hem / L', '0'),
                            SizedBox(width: 12),
                            _buildProductItem('Koko Abu / S', '2'),
                            SizedBox(width: 12),
                            _buildMoreButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryItem('T-Shirt', Icons.checkroom),
                      _buildCategoryItem('Pants', Icons.accessibility_new),
                      _buildCategoryItem('Kids', Icons.child_care),
                      _buildCategoryItem('Adults', Icons.person),
                      _buildCategoryItem('Uniform', Icons.school),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: GestureDetector(
                    key: filterButtonKey,
                    onTap: () {
                      _showDropdownMenu(context, filterButtonKey);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.tune,
                          size: 22,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Gudang',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GetBuilder<GudangController>(
                      builder: (controller) => Text(
                        'Total : ${controller.filteredItems.length} barang',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: GetBuilder<GudangController>(
                    builder: (controller) {
                      if (controller.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: primaryGreen,
                          ),
                        );
                      }

                      if (controller.filteredItems.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No items found',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: controller.filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.filteredItems[index];
                          return _buildProductItemFromData(item);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton() {
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

  Widget _buildProductItem(String title, String badge) {
    bool isOutOfStock = badge == '0';

    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: 100,
            margin: EdgeInsets.only(top: 10),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: primaryGreen,
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

  Widget _buildCategoryItem(String title, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFF181C1D),
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
            color: Colors.black,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProductItemFromData(dynamic item) {
    final bool isOutOfStock = item['stock'] == 0;
    final bool isNew = item['isNew'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/clothes.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: primaryGreen.withOpacity(0.7),
                        child: Center(
                          child: Icon(
                            Icons.checkroom,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (isOutOfStock)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withOpacity(0.7),
                    ),
                    child: Center(
                      child: Text(
                        'SOLD OUT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              if (!isOutOfStock && item['stock'] > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${item['stock']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              if (isNew)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF181C1D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${item['name']} / ${item['size']}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          'Rp.${item['price'].toString()}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
