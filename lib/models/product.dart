class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.category,
    required this.weightCategory,
    required this.brand,
    required this.isFavorite,
  });

  final int id;
  final String name;
  final double price;
  final int stock;
  final String imageUrl;
  final String category;
  final String weightCategory;
  final String brand;
  final bool isFavorite;

  Product copyWith({
    String? name,
    double? price,
    int? stock,
    String? imageUrl,
    String? category,
    String? weightCategory,
    String? brand,
    bool? isFavorite,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      weightCategory: weightCategory ?? this.weightCategory,
      brand: brand ?? this.brand,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
