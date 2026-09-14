import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/product_repository.dart';
import '../controllers/product_catalog_controller.dart';
import '../controllers/view_status.dart';
import '../widgets/product_card.dart';
import '../widgets/state_views.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({
    super.key,
    required this.repository,
  });

  final ProductRepository repository;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final ProductCatalogController _controller;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = ProductCatalogController(widget.repository);
    _scrollController.addListener(_onScroll);
    unawaited(_controller.loadInitial());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels <= 320) {
      unawaited(_controller.loadMore());
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 450),
      () => _controller.search(value),
    );
  }

  void _submitSearch(String value) {
    _debounce?.cancel();
    unawaited(_controller.search(value));
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    unawaited(_controller.search(''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onSubmitted: _submitSearch,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search products…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: ListenableBuilder(
                    listenable: _searchController,
                    builder: (context, _) {
                      if (_searchController.text.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return IconButton(
                        tooltip: 'Clear search',
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.close),
                      );
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_controller.status) {
      case ViewStatus.initial:
      case ViewStatus.loading:
        return const LoadingStateView();
      case ViewStatus.error:
        return ErrorStateView(
          message: _controller.errorMessage ?? 'Unable to load products.',
          onRetry: () => unawaited(_controller.retry()),
        );
      case ViewStatus.empty:
        return RefreshIndicator(
          onRefresh: _controller.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.55,
                child: EmptyStateView(query: _controller.query),
              ),
            ],
          ),
        );
      case ViewStatus.success:
        return RefreshIndicator(
          onRefresh: _controller.refresh,
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
            itemCount: _controller.products.length + 1,
            itemBuilder: (context, index) {
              if (index == _controller.products.length) {
                return _PaginationFooter(
                  isLoading: _controller.isLoadingMore,
                  errorMessage: _controller.loadMoreError,
                  hasMore: _controller.hasMore,
                  onRetry: () => unawaited(_controller.loadMore()),
                );
              }

              final product = _controller.products[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProductDetailScreen(
                          repository: widget.repository,
                          productId: product.id,
                          previewThumbnail: product.thumbnail,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
    }
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.isLoading,
    required this.errorMessage,
    required this.hasMore,
    required this.onRetry,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool hasMore;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry loading more'),
            ),
          ],
        ),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'You’ve reached the end.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    return const SizedBox(height: 24);
  }
}
