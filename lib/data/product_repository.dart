import 'models/product.dart';
import 'models/product_page.dart';
import 'product_api_service.dart';

abstract interface class ProductRepository {
  Future<ProductPage> fetchProducts({
    int limit = 20,
    int skip = 0,
    String query = '',
  });

  Future<Product> fetchProduct(int id);
}

class ApiProductRepository implements ProductRepository {
  const ApiProductRepository(this._apiService);

  final ProductApiService _apiService;

  @override
  Future<ProductPage> fetchProducts({
    int limit = 20,
    int skip = 0,
    String query = '',
  }) async {
    final json = await _apiService.fetchProducts(
      limit: limit,
      skip: skip,
      query: query,
    );
    return ProductPage.fromJson(json);
  }

  @override
  Future<Product> fetchProduct(int id) async {
    final json = await _apiService.fetchProduct(id);
    return Product.fromJson(json);
  }
}
