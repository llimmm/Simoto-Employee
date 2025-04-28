import 'package:kliktoko/APIService/ApiService.dart';


class Product {
  final int? id;
  final String name;
  final String size;
  final int stock;
  final bool isNew;
  final double price;
  final String? imagePath;
  final String? description;
  final String? code;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? categoryId;
  final int? sizeId;
  
  Product({
    this.id,
    required this.name,
    required this.size,
    required this.stock,
    required this.isNew,
    required this.price,
    this.imagePath,
    this.description,
    this.code,
    this.createdAt,
    this.updatedAt,
    this.categoryId,
    this.sizeId,
  });

  // Getter for full image URL
  String? get image {
    return imagePath != null ? ApiService.getFullImageUrl(imagePath) : null;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      name: json['name'] as String? ?? 'Unknown Product',
      size: json['size'] as String? ?? _getSizeFromId(json),
      stock: json['stock_quantity'] != null 
          ? int.parse(json['stock_quantity'].toString()) 
          : (json['stock'] != null ? int.parse(json['stock'].toString()) : 0),
      isNew: json['is_new'] == true || 
             json['is_new'] == 1 || 
             json['isNew'] == true,
      price: _extractPrice(json),
      imagePath: json['image_path'] as String?,
      description: json['description'] as String?,
      code: json['code'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      categoryId: json['category_id'] != null 
          ? int.parse(json['category_id'].toString()) 
          : null,
      sizeId: json['size_id'] != null 
          ? int.parse(json['size_id'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'size': size,
        'stock_quantity': stock,
        'is_new': isNew ? 1 : 0,
        'price': price,
        if (imagePath != null) 'image_path': imagePath,
        if (description != null) 'description': description,
        if (code != null) 'code': code,
        if (categoryId != null) 'category_id': categoryId,
        if (sizeId != null) 'size_id': sizeId,
      };
      
  // Helper method to extract price from different JSON formats
  static double _extractPrice(Map<String, dynamic> json) {
    if (json['price'] == null) return 0.0;
    
    if (json['price'] is double) {
      return json['price'];
    } else if (json['price'] is int) {
      return json['price'].toDouble();
    } else {
      // Try to parse string to double
      try {
        return double.parse(json['price'].toString());
      } catch (e) {
        print('Error parsing price: $e');
        return 0.0;
      }
    }
  }
  
  // Helper method to determine size from size_id if size is not provided
  static String _getSizeFromId(Map<String, dynamic> json) {
    if (json['size_id'] == null) return 'One Size';
    
    // Map size_id to actual size string based on the data in your app
    switch(int.parse(json['size_id'].toString())) {
      case 1: return 'S';
      case 2: return 'M';
      case 3: return 'L';
      case 4: return 'XL';
      case 5: return 'XXL';
      case 6: return 'XXXL';
      case 7: return '3L';
      default: return 'One Size';
    }
  }
}