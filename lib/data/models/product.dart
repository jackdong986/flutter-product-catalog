class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.thumbnail,
    required this.images,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final double rating;
  final String thumbnail;
  final List<String> images;

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];

    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: _asDouble(json['price']),
      rating: _asDouble(json['rating']),
      thumbnail: json['thumbnail'] as String? ?? '',
      images: rawImages is List
          ? rawImages.whereType<String>().toList(growable: false)
          : const [],
    );
  }

  static double _asDouble(Object? value) {
    return value is num ? value.toDouble() : 0.0;
  }
}
