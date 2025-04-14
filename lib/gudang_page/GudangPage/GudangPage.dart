import 'package:flutter/material.dart';

class GudangPage extends StatelessWidget {
  const GudangPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
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

                // Out of stock section - PRESERVING ORIGINAL DESIGN ENTIRELY
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

                      // Horizontal ScrollView with items and More button
                      SizedBox(
                        height: 140, // Original height from HomePage
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // Original items from HomePage
                            _buildProductItem('Koko Abu / M', '3'),
                            SizedBox(width: 12),
                            _buildProductItem('Hem / L', '0'),
                            SizedBox(width: 12),
                            _buildProductItem('Koko Abu / S', '2'),
                            // More button with same size as items
                            SizedBox(width: 12),
                            _buildMoreButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Category Title
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

                // Categories section - FROM HOMEPAGE VERSION
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFF282828),
                    borderRadius: BorderRadius.circular(16),
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

                // Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    children: [
                      // Filter icon
                      Container(
                        padding: const EdgeInsets.all(7),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:
                            Icon(Icons.tune, size: 18, color: Colors.grey[700]),
                      ),
                      // Filter chips
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('All', true),
                              const SizedBox(width: 8),
                              _buildFilterChip('New Arrival', false),
                              const SizedBox(width: 8),
                              _buildFilterChip('XL Size', false),
                              const SizedBox(width: 8),
                              _buildFilterChip('L Size', false),
                              const SizedBox(width: 8),
                              _buildFilterChip('M Size', false),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Gudang Title and Total
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
                    Text(
                      'Total : 5 barang',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Grid of Products
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: List.generate(
                      4,
                      (index) => _buildProductItem2(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // More button that matches size of products
  Widget _buildMoreButton() {
    return Container(
      width: 35, // Reduced width from 100
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 30, // Same height as product items
            width: 30,
            margin: EdgeInsets.only(
                top: 43), // Increased top margin to center the button
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFA9CD47), // Green background color
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

  // Original product item from HomePage
  Widget _buildProductItem(String title, String badge) {
    bool isOutOfStock = badge == '0';

    return Container(
      width: 100,
      margin: EdgeInsets.only(
          right: 0), // No right margin as spacing is handled by SizedBox
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

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFB4D66F) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.grey[700],
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProductItem2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/clothes.jpg',
                fit: BoxFit.cover,
                // Using a placeholder color since we can't access actual assets
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 10, height: 60, color: Colors.white),
                          Container(
                              width: 10, height: 60, color: Colors.blue[100]),
                          Container(
                              width: 10, height: 60, color: Colors.orange[300]),
                          Container(width: 10, height: 60, color: Colors.white),
                          Container(
                              width: 10, height: 60, color: Colors.blue[300]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Setelan Koko Anak',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Text(
          'Rp.60,000',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
