import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_app/app.dart';
import 'package:tienda_app/features/catalog/domain/get_products.dart';
import 'package:tienda_app/features/catalog/domain/product.dart';
import 'package:tienda_app/features/catalog/domain/product_repository.dart';
import 'package:tienda_app/features/catalog/presentation/catalog_controller.dart';
import 'package:tienda_app/features/favorites/domain/favorite.dart';
import 'package:tienda_app/features/favorites/domain/favorites_repository.dart';
import 'package:tienda_app/features/favorites/domain/manage_favorites.dart';
import 'package:tienda_app/features/favorites/presentation/favorites_controller.dart';

class FakeProducts implements ProductRepository {
  Future<List<Product>> Function() handler;
  FakeProducts(this.handler);
  @override
  Future<List<Product>> getProducts() => handler();
}

class MemoryFavorites implements FavoritesRepository {
  final items = <Favorite>[];
  bool failWrite = false;
  @override
  Future<List<Favorite>> getFavorites() async => List.of(items);
  @override
  Future<void> add(Product product, DateTime addedAt) async {
    if (failWrite) throw StateError('disk full');
    items.insert(0, Favorite(product: product, addedAt: addedAt));
  }

  @override
  Future<void> remove(int productId) async {
    if (failWrite) throw StateError('disk full');
    items.removeWhere((f) => f.product.id == productId);
  }
}

void main() {
  late FakeProducts repository;
  late CatalogController catalog;
  late FavoritesController favorites;
  late MemoryFavorites store;
  final products = [
    Product(
      id: 1,
      title: 'Mascara',
      price: 9.99,
      thumbnail: 'https://example.com/1',
      tags: ['Beauty'],
    ),
    Product(
      id: 2,
      title: 'Carne',
      price: 5,
      thumbnail: 'https://example.com/2',
      tags: ['meat'],
    ),
  ];
  setUp(() {
    repository = FakeProducts(() async => products);
    catalog = CatalogController(GetProducts(repository));
    store = MemoryFavorites();
    favorites = FavoritesController(ManageFavorites(store));
  });
  tearDown(() {
    catalog.dispose();
    favorites.dispose();
  });
  Future<void> render(WidgetTester tester) async {
    await favorites.load();
    await tester.pumpWidget(TiendaApp(catalog: catalog, favorites: favorites));
  }

  testWidgets('loading, products, tags and filter toggle', (tester) async {
    final gate = Completer<List<Product>>();
    repository.handler = () => gate.future;
    await render(tester);
    final load = catalog.load();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    gate.complete(products);
    await load;
    await tester.pumpAndSettle();
    expect(find.text('Mascara'), findsOneWidget);
    expect(find.text('USD 9.99'), findsOneWidget);
    await tester.tap(find.text('beauty'));
    await tester.pumpAndSettle();
    expect(find.text('Carne'), findsNothing);
    await tester.tap(find.text('beauty'));
    await tester.pumpAndSettle();
    expect(find.text('Carne'), findsOneWidget);
  });
  testWidgets('server error can retry and show empty state', (tester) async {
    repository.handler = () async =>
        throw const CatalogException(CatalogFailure.server);
    await render(tester);
    await catalog.load();
    await tester.pumpAndSettle();
    expect(find.textContaining('servidor'), findsOneWidget);
    repository.handler = () async => [];
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('No hay productos disponibles.'), findsOneWidget);
  });
  testWidgets('offline favorites, navigation, removal and empty state', (
    tester,
  ) async {
    await store.add(products.first, DateTime.utc(2026));
    repository.handler = () async =>
        throw const CatalogException(CatalogFailure.offline);
    await render(tester);
    await catalog.load();
    await tester.pumpAndSettle();
    expect(find.textContaining('Sin conexión'), findsOneWidget);
    await tester.tap(find.byTooltip('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('Mascara'), findsOneWidget);
    expect(find.text('Beauty'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('favorite-1')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Todavía no tienes favoritos'), findsOneWidget);
  });
  testWidgets('favorite add and failed removal keep UI consistent', (
    tester,
  ) async {
    await render(tester);
    await catalog.load();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('favorite-1')));
    await tester.pumpAndSettle();
    expect(favorites.contains(1), isTrue);
    store.failWrite = true;
    await tester.tap(find.byKey(const ValueKey('favorite-1')));
    await tester.pumpAndSettle();
    expect(favorites.contains(1), isTrue);
    expect(find.textContaining('No se pudo actualizar'), findsOneWidget);
  });
}
