import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/data/models/product.dart';
import 'package:product_catalog/data/models/product_page.dart';

void main() {
  group('Product', () {
    test('parses numeric values and images from JSON', () {
      final product = Product.fromJson({
        'id': 7,
        'title': 'Test Phone',
        'description': 'A useful phone',
        'price': 499,
        'rating': 4.35,
        'thumbnail': 'https://example.com/thumb.png',
        'images': [
          'https://example.com/1.png',
          'https://example.com/2.png',
        ],
      });

      expect(product.id, 7);
      expect(product.title, 'Test Phone');
      expect(product.price, 499.0);
      expect(product.rating, 4.35);
      expect(product.images, hasLength(2));
    });

    test('uses safe defaults for optional malformed fields', () {
      final product = Product.fromJson({
        'id': 1,
        'title': 'Minimal',
        'price': 'not-a-number',
        'images': 'invalid',
      });

      expect(product.description, '');
      expect(product.price, 0.0);
      expect(product.rating, 0.0);
      expect(product.thumbnail, '');
      expect(product.images, isEmpty);
    });
  });

  test('ProductPage parses pagination metadata', () {
    final page = ProductPage.fromJson({
      'products': [
        {
          'id': 1,
          'title': 'One',
          'price': 10,
        },
      ],
      'total': 194,
      'skip': 20,
      'limit': 20,
    });

    expect(page.products.single.id, 1);
    expect(page.total, 194);
    expect(page.skip, 20);
    expect(page.limit, 20);
  });
}
