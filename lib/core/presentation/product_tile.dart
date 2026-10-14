import 'package:flutter/material.dart';
import '../../features/catalog/domain/product.dart';
import '../../features/favorites/presentation/favorites_controller.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final FavoritesController favorites;
  final bool showTags;
  const ProductTile({
    super.key,
    required this.product,
    required this.favorites,
    this.showTags = false,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Image.network(
              product.thumbnail,
              fit: BoxFit.contain,
              errorBuilder: (_, error, stack) =>
                  const Icon(Icons.image_not_supported_outlined),
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text('USD ${product.price.toStringAsFixed(2)}'),
                if (showTags)
                  Wrap(
                    spacing: 6,
                    children: product.tags
                        .map((tag) => Chip(label: Text(tag)))
                        .toList(),
                  ),
              ],
            ),
          ),
          IconButton(
            key: ValueKey('favorite-${product.id}'),
            tooltip: favorites.contains(product.id)
                ? 'Quitar de favoritos'
                : 'Agregar a favoritos',
            onPressed:
                favorites.loading ||
                    favorites.error != null ||
                    favorites.pending.contains(product.id)
                ? null
                : () async {
                    final success = await favorites.toggle(product);
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No se pudo actualizar el favorito. Intenta de nuevo.',
                          ),
                        ),
                      );
                    }
                  },
            icon: Icon(
              favorites.contains(product.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: favorites.contains(product.id) ? Colors.red : null,
            ),
          ),
        ],
      ),
    ),
  );
}
