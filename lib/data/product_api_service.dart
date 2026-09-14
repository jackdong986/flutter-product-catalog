import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => 'ApiException: $message';
}

class ProductApiService {
  ProductApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _host = 'dummyjson.com';
  static const _requestTimeout = Duration(seconds: 12);

  final http.Client _client;

  Future<Map<String, dynamic>> fetchProducts({
    required int limit,
    required int skip,
    String query = '',
  }) {
    final trimmedQuery = query.trim();
    final path = trimmedQuery.isEmpty ? '/products' : '/products/search';
    final parameters = <String, String>{
      'limit': '$limit',
      'skip': '$skip',
      if (trimmedQuery.isNotEmpty) 'q': trimmedQuery,
    };

    return _get(Uri.https(_host, path, parameters));
  }

  Future<Map<String, dynamic>> fetchProduct(int id) {
    return _get(Uri.https(_host, '/products/$id'));
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'Request failed (${response.statusCode}). Please try again.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('The server returned an unexpected response.');
      }

      return decoded;
    } on TimeoutException {
      throw const ApiException('The request timed out. Please try again.');
    } on http.ClientException {
      throw const ApiException(
        'Unable to connect. Check your internet connection and retry.',
      );
    } on FormatException {
      throw const ApiException('The server returned invalid data.');
    }
  }
}
