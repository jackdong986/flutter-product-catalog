import 'package:flutter/foundation.dart';

import '../../data/models/product.dart';
import '../../data/product_repository.dart';
import 'view_status.dart';

class ProductDetailController extends ChangeNotifier {
  ProductDetailController(this._repository, this.productId);

  final ProductRepository _repository;
  final int productId;

  ViewStatus _status = ViewStatus.initial;
  Product? _product;
  String? _errorMessage;

  ViewStatus get status => _status;
  Product? get product => _product;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _product = await _repository.fetchProduct(productId);
      _status = ViewStatus.success;
    } catch (error) {
      _errorMessage = error
          .toString()
          .replaceFirst(RegExp(r'^(ApiException|Exception):\s*'), '');
      _status = ViewStatus.error;
    }

    notifyListeners();
  }
}
