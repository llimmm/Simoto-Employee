import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/ReusablePage/categoryPage.dart';
import 'package:kliktoko/home_page/HomeController/HomeController.dart';
import 'package:kliktoko/ReusablePage/detailpage.dart';
import '../GudangControllers/GudangController.dart';
import '../GudangModel/ProductModel.dart';
import 'package:intl/intl.dart';

class GudangPage extends StatefulWidget {
  const GudangPage({Key? key}) : super(key: key);

  @override
  State<GudangPage> createState() => _GudangPageState();
}

class _GudangPageState extends State<GudangPage>
    with SingleTickerProviderStateMixin {
  final GudangController controller = Get.put(GudangController());
  late HomeController homeController;

  // Add a FocusNode to manage the search field focus
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

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

    // Set up listener for route changes to manage search field focus
    Get.rootDelegate.addListener(_handleRouteChange);

    // Initialize search controller with current search query
    _searchController.text = controller.searchQuery.value;

    // Listen to the controller's search query changes
    ever(controller.searchQuery, (query) {
      if (_searchController.text != query) {
        _searchController.text = query;
      }
    });

    // Add focus listener
    _searchFocusNode.addListener(_handleFocusChange);
  }

  // Handle focus changes
  void _handleFocusChange() {
    // Update controller when focus changes
    if (_searchFocusNode.hasFocus) {
      controller.onSearchFieldFocused();
    } else {
      controller.onSearchFieldUnfocused();
    }
  }

  // Handle route changes
  void _handleRouteChange() {
    _unfocusSearchField();
  }

  // Method to unfocus the search field
  void _unfocusSearchField() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
  }

  // Local state for the filter options
  final List<String> filterOptions = [
    'Semua',
    'Baru Datang',
    'Ukuran S',
    'Ukuran M',
    'Ukuran L',
    'Ukuran XL',
    'Ukuran XXL',
    'Ukuran XXXL',
  ];

  // Green color constant
  final Color primaryGreen = Color(0xFFA9CD47);

  // Track if the dropdown menu is open
  OverlayEntry? _overlayEntry;
  bool isDropdownVisible = false;

  @override
  void dispose() {
    _removeOverlay();
    // Remove listener for route changes
    Get.rootDelegate.removeListener(_handleRouteChange);
    // Remove focus listener
    _searchFocusNode.removeListener(_handleFocusChange);
    // Dispose of the FocusNode and TextEditingController when the widget is disposed
    _searchFocusNode.dispose();
    _searchController.dispose();
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
    // First ensure any existing overlay is removed
    _removeOverlay();

    // Check if the key has a valid context
    if (key.currentContext == null) {
      print('Error: Filter button context is null');
      return;
    }

    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

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
            left: 16, // Left aligned dropdown
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: screenSize.height * 0.4, // Responsive height
                  maxWidth: screenSize.width * 0.45, // Responsive width
                ),
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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

    // Check if we have a valid overlay before inserting
    final overlay = Overlay.of(context);
    if (overlay != null) {
      overlay.insert(_overlayEntry!);
      isDropdownVisible = true;
      setState(() {});
    } else {
      print('Error: Overlay is null');
    }
  }

  // Method to navigate to product detail page
  void _navigateToProductDetail(Product product) {
    // Unfocus the search field before navigating
    _unfocusSearchField();
    Get.to(() => ProductDetailPage(product: product));
  }

  // Method to navigate to category page
  void _navigateToCategoryPage(String categoryName) {
    // Unfocus the search field before navigating
    _unfocusSearchField();
    Get.to(() => CategoryPage(categoryName: categoryName));
  }

  // Simple refresh function to reload all data
  Future<void> _refreshData() async {
    try {
      // Load categories and inventory data in parallel
      await Future.wait([
        controller.loadCategories(),
        controller.loadInventoryData(),
      ]);
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterButtonKey = GlobalKey();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive paddings and sizes
    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenHeight * 0.02;
    final cardBorderRadius = 16.0;

    // Calculate responsive grid items for different screen sizes
    final crossAxisCount = screenWidth < 360 ? 1 : 2;
    final childAspectRatio = screenWidth < 360 ? 0.8 : 0.7;

    return GestureDetector(
      // Add a GestureDetector to the entire scaffold to unfocus when tapping outside
      onTap: () {
        _unfocusSearchField();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F9E9),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: primaryGreen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar - Updated with FocusNode
                    Container(
                      margin: EdgeInsets.only(
                        top: verticalPadding,
                        bottom: verticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(30),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController, // Assign text controller
                        focusNode: _searchFocusNode, // Assign the focus node
                        onChanged: (value) =>
                            controller.updateSearchQuery(value),
                        textInputAction: TextInputAction
                            .search, // Change to search to make keyboard more appropriate
                        decoration: InputDecoration(
                          hintText: 'cari',
                          hintStyle:
                              TextStyle(color: Colors.grey[400], fontSize: 16),
                          prefixIcon: Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 5.0),
                            child: Icon(Icons.search,
                                color: Colors.grey[400], size: 22),
                          ),
                          // Add a clear button when there's text
                          suffixIcon:
                              Obx(() => controller.searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear,
                                          color: Colors.grey[400]),
                                      onPressed: () {
                                        // Clear the search query and unfocus
                                        controller.updateSearchQuery('');
                                        _unfocusSearchField();
                                      },
                                    )
                                  : SizedBox.shrink()),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    // Stok habis section
                    GetBuilder<GudangController>(builder: (controller) {
                      final outOfStockItems =
                          controller.getOutOfStockItemsForDisplay(3);
                      return Container(
                        padding: EdgeInsets.all(horizontalPadding),
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Color(0xFF282828),
                          borderRadius: BorderRadius.circular(cardBorderRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Stok Habis',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: verticalPadding * 0.5),
                            SizedBox(
                              height: 100, // Fixed height since no text below
                              child: outOfStockItems.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Tidak ada item stok habis',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  : ListView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      children: [
                                        ...outOfStockItems.map((item) =>
                                            _buildProductItemFromOutOfStock(
                                                item)),
                                        SizedBox(
                                            width: horizontalPadding * 0.5),
                                        if (controller.outOfStockItems.length >
                                            3)
                                          _buildMoreButton(),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Kategori header
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: verticalPadding),
                      child: const Text(
                        'Kategori',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Categories - Now navigates to dedicated category page
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: verticalPadding),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(cardBorderRadius),
                        ),
                        child: GetBuilder<GudangController>(
                          builder: (controller) {
                            if (controller.isCategoriesLoading) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: primaryGreen,
                                ),
                              );
                            }

                            if (controller.categories.isEmpty) {
                              return _buildDefaultCategories(screenWidth);
                            }

                            return Container(
                              height: 90,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: controller.categories.length,
                                itemBuilder: (context, index) {
                                  final category = controller.categories[index];
                                  return Container(
                                    margin: EdgeInsets.only(
                                      right: index ==
                                              controller.categories.length - 1
                                          ? 0
                                          : horizontalPadding,
                                    ),
                                    child: _buildCategoryItem(
                                        category.name, category.getIcon()),
                                  );
                                },
                              ),
                            );
                          },
                        )),

                    // Filter button and gudang header - KEPT ORIGINAL DESIGN
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: verticalPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Filter button
                          GestureDetector(
                            key: filterButtonKey,
                            onTap: () {
                              _unfocusSearchField(); // Unfocus search when opening filter
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

                          // Gudang title
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                'Gudang',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          // Total items counter
                          GetBuilder<GudangController>(
                            builder: (controller) => Text(
                              'Total: ${controller.filteredItems.length} barang',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Products grid
                    Padding(
                      padding: EdgeInsets.only(top: verticalPadding * 0.5),
                      child: GetBuilder<GudangController>(
                        builder: (controller) {
                          if (controller.isLoading) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: verticalPadding * 2),
                                child: CircularProgressIndicator(
                                  color: primaryGreen,
                                ),
                              ),
                            );
                          }

                          if (controller.hasError) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: verticalPadding * 2),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red[400],
                                    ),
                                    SizedBox(height: verticalPadding),
                                    Text(
                                      controller.errorMessage,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: verticalPadding),
                                    ElevatedButton(
                                      onPressed: _refreshData,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryGreen,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Retry',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (controller.filteredItems.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: verticalPadding * 2),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: verticalPadding),
                                    Text(
                                      'Tidak ada item ditemukan',
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: childAspectRatio,
                              crossAxisSpacing: horizontalPadding,
                              mainAxisSpacing: verticalPadding,
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

                    // Bottom padding to avoid navigation bar overlap
                    SizedBox(height: screenHeight * 0.1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fallback categories if API fails
  Widget _buildDefaultCategories(double screenWidth) {
    final defaultCategories = [
      {'name': 'T-Shirt', 'icon': Icons.checkroom},
      {'name': 'Pants', 'icon': Icons.accessibility_new},
      {'name': 'Kids', 'icon': Icons.child_care},
      {'name': 'Adults', 'icon': Icons.person},
      {'name': 'Uniform', 'icon': Icons.school},
    ];

    return Container(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: defaultCategories.length,
        itemBuilder: (context, index) {
          final category = defaultCategories[index];
          return Container(
            margin: EdgeInsets.only(
              right: index == defaultCategories.length - 1
                  ? 0
                  : screenWidth * 0.04,
            ),
            child: _buildCategoryItem(
                category['name'] as String, category['icon'] as IconData),
          );
        },
      ),
    );
  }

  Widget _buildMoreButton() {
    return Container(
      width: 35,
      height: 100, // Match the height of product cards
      child: Center(
        child: Container(
          height: 30,
          width: 30,
          child: Container(
            decoration: BoxDecoration(
              color: primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.chevron_right,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductItemFromOutOfStock(Product item) {
    return GestureDetector(
      onTap: () => _navigateToProductDetail(item),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryGreen.withOpacity(0.8),
                      primaryGreen.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Product image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: item.image != null && item.image!.isNotEmpty
                          ? Image.network(
                              item.image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image: $error');
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        primaryGreen.withOpacity(0.8),
                                        primaryGreen.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.checkroom,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                Icons.checkroom,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                    ),

                    // Overlay stok habis
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.block,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'HABIS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Size badge
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          item.size ?? 'N/A',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Code badge
                    if (item.code != null)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            item.code!,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 7,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Info section
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        color: const Color(0xFF282828),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(item.price)}',
                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated category item that now navigates to a dedicated page
  Widget _buildCategoryItem(String title, IconData icon) {
    return InkWell(
      onTap: () {
        // Navigate to category page instead of filtering directly
        _navigateToCategoryPage(title);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF181C1D),
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
              color: Colors.black,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProductItemFromData(Product item) {
    final bool isOutOfStock = item.stock == 0;
    final bool isNew = item.isNew;

    return GestureDetector(
      onTap: () => _navigateToProductDetail(item),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.shade100,
                          Colors.grey.shade200,
                        ],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: item.image != null && item.image!.isNotEmpty
                          ? Image.network(
                              item.image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: primaryGreen,
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image: $error');
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        primaryGreen.withOpacity(0.8),
                                        primaryGreen.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.checkroom,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    primaryGreen.withOpacity(0.8),
                                    primaryGreen.withOpacity(0.6),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.checkroom,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                  ),

                  // Overlay untuk stok habis
                  if (isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.block,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'STOK HABIS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Badge stok rendah
                  if (!isOutOfStock && item.stock > 0 && item.stock <= 5)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade600,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${item.stock}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Badge baru
                  if (isNew)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF181C1D),
                              const Color(0xFF2C3E50),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'BARU',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Code badge
                  if (item.code != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          item.code!,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content section
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name and size
                    Text(
                      item.name,
                      style: TextStyle(
                        color: const Color(0xFF282828),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Size badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: primaryGreen.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Size: ${item.size}',
                        style: TextStyle(
                          color: primaryGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Price
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: primaryGreen,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(item.price)}',
                          style: TextStyle(
                            color: primaryGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
