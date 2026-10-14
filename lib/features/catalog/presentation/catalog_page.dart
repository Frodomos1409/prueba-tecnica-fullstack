import 'package:flutter/material.dart';
import '../../../core/presentation/product_tile.dart';
import '../../../core/presentation/status_message.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../../favorites/presentation/favorites_page.dart';
import 'catalog_controller.dart';

class CatalogPage extends StatelessWidget {
  final CatalogController catalog;
  final FavoritesController favorites;
  const CatalogPage({
    super.key,
    required this.catalog,
    required this.favorites,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('TiendaApp'),
      actions: [
        IconButton(
          tooltip: 'Favoritos',
          icon: const Icon(Icons.favorite),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => FavoritesPage(controller: favorites),
            ),
          ),
        ),
      ],
    ),
    body: AnimatedBuilder(
      animation: Listenable.merge([catalog, favorites]),
      builder: (context, _) {
        final Widget content;
        switch (catalog.status) {
          case CatalogStatus.loading:
            content = const Center(child: CircularProgressIndicator());
          case CatalogStatus.offline:
            content = StatusMessage(
              message:
                  'Sin conexión. Revisa tu red e intenta de nuevo. Tus favoritos siguen disponibles.',
              icon: Icons.wifi_off,
              retry: catalog.load,
            );
          case CatalogStatus.error:
            content = StatusMessage(
              message:
                  'No pudimos cargar los productos del servidor. Intenta de nuevo.',
              icon: Icons.error_outline,
              retry: catalog.load,
            );
          case CatalogStatus.empty:
            content = const StatusMessage(
              message: 'No hay productos disponibles.',
              icon: Icons.inventory_2_outlined,
            );
          case CatalogStatus.ready:
            final products = catalog.visibleProducts;
            content = Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: catalog.popularTags
                        .map(
                          (tag) => FilterChip(
                            label: Text(tag),
                            selected: catalog.selectedTag == tag,
                            onSelected: (_) => catalog.selectTag(tag),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(
                  child: products.isEmpty
                      ? const StatusMessage(
                          message: 'No hay productos con esta etiqueta.',
                          icon: Icons.filter_alt_off,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: products.length,
                          itemBuilder: (_, i) => ProductTile(
                            product: products[i],
                            favorites: favorites,
                          ),
                        ),
                ),
              ],
            );
        }
        return Column(
          children: [
            if (favorites.error != null)
              MaterialBanner(
                content: Text(favorites.error!),
                actions: [
                  TextButton(
                    onPressed: favorites.load,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            Expanded(child: content),
          ],
        );
      },
    ),
  );
}
