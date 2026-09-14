import 'package:flutter/foundation.dart';

import '../../data/models/product.dart';
import '../../data/product_repository.dart';
import 'view_status.dart';

class ProductCatalogController extends ChangeNotifier {
  ProductCatalogController(this._repository);

  static const pageSize = 20;

  final ProductRepository _repository;
  final List<Product> _products = [];

  ViewStatus _status = ViewStatus.initial;
  String _query = '';
  String? _errorMessage;
  String? _loadMoreError;
  int _total = 0;
  bool _isLoadingMore = false;
  int _requestSerial = 0;

  List<Product> get products => List.unmodifiable(_products);
  ViewStatus get status => _status;
  String get query => _query;
  String? get errorMessage => _errorMessage;
  String? get loadMoreError => _loadMoreError;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _products.length < _total;

  Future<void> loadInitial() => _loadFirstPage(_query);

  Future<void> retry() => _loadFirstPage(_query);

  Future<void> refresh() => _loadFirstPage(_query);

  Future<void> search(String value) async {
    final normalized = value.trim();
    if (normalized == _query && _status != ViewStatus.error) {
      return;
    }

    _query = normalized;
    await _loadFirstPage(_query);
  }

  Future<void> _loadFirstPage(String query) async {
    final requestId = ++_requestSerial;
    _status = ViewStatus.loading;
    _errorMessage = null;
    _loadMoreError = null;
    _isLoadingMore = false;
    notifyListeners();

    try {
      final page = await _repository.fetchProducts(
        limit: pageSize,
        skip: 0,
        query: query,
      );
      if (requestId != _requestSerial) return;

      _products
        ..clear()
        ..addAll(page.products);
      _total = page.total;
      _status = _products.isEmpty ? ViewStatus.empty : ViewStatus.success;
    } catch (error) {
      if (requestId != _requestSerial) return;
      _products.clear();
      _total = 0;
      _errorMessage = _friendlyError(error);
      _status = ViewStatus.error;
    }

    if (requestId == _requestSerial) {
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || _status != ViewStatus.success) {
      return;
    }

    final requestId = _requestSerial;
    final activeQuery = _query;
    _isLoadingMore = true;
    _loadMoreError = null;
    notifyListeners();

    try {
      final page = await _repository.fetchProducts(
        limit: pageSize,
        skip: _products.length,
        query: activeQuery,
      );
      if (requestId != _requestSerial || activeQuery != _query) return;

      final existingIds = _products.map((product) => product.id).toSet();
      _products.addAll(
        page.products.where((product) => existingIds.add(product.id)),
      );
      _total = page.total;
    } catch (error) {
      if (requestId != _requestSerial || activeQuery != _query) return;
      _loadMoreError = _friendlyError(error);
    } finally {
      if (requestId == _requestSerial && activeQuery == _query) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  String _friendlyError(Object error) {
    return error
        .toString()
        .replaceFirst(RegExp(r'^(ApiException|Exception):\s*'), '');
  }
}
