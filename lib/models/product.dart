class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  final int id;
  final String name;
  final double price;
  final int stock;

  Product copyWith({
    String? name,
    double? price,
    int? stock,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }
}
