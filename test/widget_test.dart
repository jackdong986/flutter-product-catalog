import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/data/models/product.dart';
import 'package:product_catalog/data/models/product_page.dart';
import 'package:product_catalog/data/product_repository.dart';
import 'package:product_catalog/main.dart';

class _FakeProductRepository implements ProductRepository {
  @override
  Future<ProductPage> fetchProducts({
    int limit = 20,
    int skip = 0,
    String query = '',
  }) async {
    return ProductPage(
      products: const [
        Product(
          id: 1,
          title: 'Test Phone',
          description: 'A product used by the widget test.',
          price: 999,
          rating: 4.5,
          thumbnail: '',
          images: [],
        ),
      ],
      total: 1,
      skip: skip,
      limit: limit,
    );
  }

  @override
  Future<Product> fetchProduct(int id) async {
    return Product(
      id: id,
      title: 'Test Phone',
      description: 'A product used by the widget test.',
      price: 999,
      rating: 4.5,
      thumbnail: '',
      images: const [],
    );
  }
}

void main() {
  testWidgets('renders products returned by the repository', (tester) async {
    await tester.pumpWidget(
      ProductCatalogApp(repository: _FakeProductRepository()),
    );

    await tester.pump();

    expect(find.text('Product Catalog'), findsOneWidget);
    expect(find.text('Test Phone'), findsOneWidget);
    expect(find.text(r'$999.00'), findsOneWidget);
  });
}
