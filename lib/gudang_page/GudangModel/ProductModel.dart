class Product {
  final String name;
  final String size;
  final int stock;
  final bool isNew;
  final double price;

  Product({
    required this.name,
    required this.size,
    required this.stock,
    required this.isNew,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] as String,
      size: json['size'] as String,
      stock: json['stock'] as int,
      isNew: json['isNew'] as bool,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'size': size,
        'stock': stock,
        'isNew': isNew,
        'price': price,
      };
}
