import 'package:flutter/material.dart';
import '../../../core/presentation/product_tile.dart';
import '../../../core/presentation/status_message.dart';
import 'favorites_controller.dart';

class FavoritesPage extends StatelessWidget {
  final FavoritesController controller;
  const FavoritesPage({super.key, required this.controller});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Favoritos')),
    body: AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error != null) {
          return StatusMessage(
            message: controller.error!,
            icon: Icons.storage,
            retry: controller.load,
          );
        }
        if (controller.items.isEmpty) {
          return const StatusMessage(
            message:
                'Todavía no tienes favoritos. Agrégalos desde el catálogo.',
            icon: Icons.favorite_border,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.items.length,
          itemBuilder: (_, index) => ProductTile(
            product: controller.items[index].product,
            favorites: controller,
            showTags: true,
          ),
        );
      },
    ),
  );
}
