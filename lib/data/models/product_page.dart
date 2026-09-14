import 'product.dart';

class ProductPage {
  const ProductPage({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  factory ProductPage.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];

    return ProductPage(
      products: rawProducts is List
          ? rawProducts
              .whereType<Map>()
              .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false)
          : const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
    );
  }
}
