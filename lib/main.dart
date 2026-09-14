import 'package:flutter/material.dart';

import 'data/product_api_service.dart';
import 'data/product_repository.dart';
import 'presentation/screens/product_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = ApiProductRepository(ProductApiService());
  runApp(ProductCatalogApp(repository: repository));
}

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({
    super.key,
    required this.repository,
  });

  final ProductRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Catalog',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: const Color(0xFFF8F9FC),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
        ),
      ),
      home: ProductListScreen(repository: repository),
    );
  }
}
