import 'package:flutter/material.dart';
import 'features/catalog/presentation/catalog_controller.dart';
import 'features/catalog/presentation/catalog_page.dart';
import 'features/favorites/presentation/favorites_controller.dart';

class TiendaApp extends StatelessWidget {
  final CatalogController catalog;
  final FavoritesController favorites;
  const TiendaApp({super.key, required this.catalog, required this.favorites});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TiendaApp',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      useMaterial3: true,
    ),
    home: CatalogPage(catalog: catalog, favorites: favorites),
  );
}
