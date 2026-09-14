import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/product.dart';
import '../../data/product_repository.dart';
import '../controllers/product_detail_controller.dart';
import '../controllers/view_status.dart';
import '../widgets/product_image.dart';
import '../widgets/state_views.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.repository,
    required this.productId,
    this.previewThumbnail = '',
  });

  final ProductRepository repository;
  final int productId;
  final String previewThumbnail;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ProductDetailController _controller;
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    _controller = ProductDetailController(widget.repository, widget.productId);
    unawaited(_controller.load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            switch (_controller.status) {
              case ViewStatus.initial:
              case ViewStatus.loading:
                return _DetailLoadingPreview(
                  productId: widget.productId,
                  thumbnail: widget.previewThumbnail,
                );
              case ViewStatus.error:
                return ErrorStateView(
                  message: _controller.errorMessage ?? 'Unable to load product.',
                  onRetry: () => unawaited(_controller.load()),
                );
              case ViewStatus.empty:
                return const EmptyStateView();
              case ViewStatus.success:
                final product = _controller.product;
                if (product == null) return const EmptyStateView();
                return _ProductDetails(
                  product: product,
                  currentImage: _currentImage,
                  onImageChanged: (index) => setState(() => _currentImage = index),
                );
            }
          },
        ),
      ),
    );
  }
}


class _DetailLoadingPreview extends StatelessWidget {
  const _DetailLoadingPreview({
    required this.productId,
    required this.thumbnail,
  });

  final int productId;
  final String thumbnail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 230,
          width: double.infinity,
          child: Hero(
            tag: 'product-$productId',
            child: ProductImage(
              url: thumbnail,
              width: double.infinity,
              height: 230,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const Expanded(
          child: LoadingStateView(label: 'Loading product…'),
        ),
      ],
    );
  }
}

class _ProductDetails extends StatelessWidget {
  const _ProductDetails({
    required this.product,
    required this.currentImage,
    required this.onImageChanged,
  });

  final Product product;
  final int currentImage;
  final ValueChanged<int> onImageChanged;

  @override
  Widget build(BuildContext context) {
    final images = product.images.isNotEmpty
        ? product.images
        : product.thumbnail.isNotEmpty
            ? [product.thumbnail]
            : const <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 310,
            child: images.isEmpty
                ? const ProductImage(url: '', width: double.infinity, height: 310)
                : PageView.builder(
                    itemCount: images.length,
                    onPageChanged: onImageChanged,
                    itemBuilder: (context, index) {
                      final image = ProductImage(
                        url: images[index],
                        width: double.infinity,
                        height: 310,
                        fit: BoxFit.contain,
                      );
                      if (index == 0) {
                        return Hero(tag: 'product-${product.id}', child: image);
                      }
                      return image;
                    },
                  ),
          ),
          if (images.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: index == currentImage ? 22 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: index == currentImage
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 20),
                          const SizedBox(width: 4),
                          Text(product.rating.toStringAsFixed(1)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  product.description.isEmpty
                      ? 'No description is available for this product.'
                      : product.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.55,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
