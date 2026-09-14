import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = url.isEmpty
        ? _fallback(context)
        : Image.network(
            url,
            width: width,
            height: height,
            fit: fit,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              final expected = progress.expectedTotalBytes;
              final value = expected == null
                  ? null
                  : progress.cumulativeBytesLoaded / expected;
              return SizedBox(
                width: width,
                height: height,
                child: Center(child: CircularProgressIndicator(value: value)),
              );
            },
            errorBuilder: (_, __, ___) => _fallback(context),
          );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }

  Widget _fallback(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
