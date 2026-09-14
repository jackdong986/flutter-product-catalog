import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/data/models/product.dart';
import 'package:product_catalog/data/models/product_page.dart';
import 'package:product_catalog/data/product_repository.dart';
import 'package:product_catalog/presentation/controllers/product_catalog_controller.dart';
import 'package:product_catalog/presentation/controllers/view_status.dart';

void main() {
  test('initial load exposes success with first page', () async {
    final repository = FakeProductRepository([
      _page(startId: 1, count: 2, total: 3, skip: 0),
    ]);
    final controller = ProductCatalogController(repository);

    await controller.loadInitial();

    expect(controller.status, ViewStatus.success);
    expect(controller.products.map((item) => item.id), [1, 2]);
    expect(controller.hasMore, isTrue);
  });

  test('loadMore appends products and advances skip by current length', () async {
    final repository = FakeProductRepository([
      _page(startId: 1, count: 2, total: 3, skip: 0),
      _page(startId: 3, count: 1, total: 3, skip: 2),
    ]);
    final controller = ProductCatalogController(repository);

    await controller.loadInitial();
    await controller.loadMore();

    expect(controller.products.map((item) => item.id), [1, 2, 3]);
    expect(controller.hasMore, isFalse);
    expect(repository.requestedSkips, [0, 2]);
  });

  test('search can expose an empty state', () async {
    final repository = FakeProductRepository([
      const ProductPage(products: [], total: 0, skip: 0, limit: 20),
    ]);
    final controller = ProductCatalogController(repository);

    await controller.search('does-not-exist');

    expect(controller.query, 'does-not-exist');
    expect(controller.status, ViewStatus.empty);
    expect(controller.products, isEmpty);
    expect(repository.requestedQueries, ['does-not-exist']);
  });
}

ProductPage _page({
  required int startId,
  required int count,
  required int total,
  required int skip,
}) {
  return ProductPage(
    products: List.generate(
      count,
      (index) => Product(
        id: startId + index,
        title: 'Product ${startId + index}',
        description: 'Description',
        price: 10,
        rating: 4,
        thumbnail: '',
        images: const [],
      ),
    ),
    total: total,
    skip: skip,
    limit: 20,
  );
}

class FakeProductRepository implements ProductRepository {
  FakeProductRepository(this.pages);

  final List<ProductPage> pages;
  final List<int> requestedSkips = [];
  final List<String> requestedQueries = [];
  int _index = 0;

  @override
  Future<Product> fetchProduct(int id) async {
    throw UnimplementedError('Not needed in catalog controller tests');
  }

  @override
  Future<ProductPage> fetchProducts({
    int limit = 20,
    int skip = 0,
    String query = '',
  }) async {
    requestedSkips.add(skip);
    requestedQueries.add(query);
    return pages[_index++];
  }
}
