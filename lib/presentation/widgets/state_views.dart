import 'package:flutter/material.dart';

class LoadingStateView extends StatelessWidget {
  const LoadingStateView({super.key, this.label = 'Loading products…'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(label),
        ],
      ),
    );
  }
}

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key, this.query = ''});

  final String query;

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasQuery ? Icons.search_off : Icons.inventory_2_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery ? 'No products found' : 'No products available',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasQuery
                  ? 'Try a different search term.'
                  : 'Pull down to refresh and try again.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
