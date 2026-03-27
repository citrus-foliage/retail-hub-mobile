import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

enum ProductLoadState { initial, loading, loaded, error }

const kFilterAll        = 'All';
const kFilterInStock    = 'In Stock';
const kFilterDiscounted = 'Discounted';
const kFilterOutOfStock = 'Out of Stock';

const kCatalogFilters = [
  kFilterAll,
  kFilterInStock,
  kFilterDiscounted,
  kFilterOutOfStock,
];

class ProductProvider extends ChangeNotifier {
  final FirestoreService _service;

  ProductLoadState _state    = ProductLoadState.initial;
  List<Product>    _products = [];
  String?          _error;
  StreamSubscription<List<Product>>? _sub;

  ProductProvider(this._service) { _subscribe(); }

  ProductLoadState get state     => _state;
  List<Product>    get products  => List.unmodifiable(_products);
  String?          get error     => _error;
  bool             get isLoading => _state == ProductLoadState.loading;

  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  List<Product> filtered({String query = '', String filter = kFilterAll}) {
    return _products.where((p) {
      final matchFilter = switch (filter) {
        kFilterInStock    => p.inStock,
        kFilterDiscounted => p.isOnSale,
        kFilterOutOfStock => !p.inStock,
        _                 => true, // 'All'
      };
      final q      = query.toLowerCase();
      final matchQ = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.sku.toLowerCase().contains(q);
      return matchFilter && matchQ;
    }).toList();
  }

  List<Product> get lowStock =>
      _products.where((p) => p.inStock && p.stockQuantity <= 5).toList();

  List<Product> get outOfStock =>
      _products.where((p) => !p.inStock).toList();

  void _subscribe() {
    _state = ProductLoadState.loading;
    notifyListeners();

    _sub = _service.productsStream().listen(
          (products) {
        _products = products;
        _state    = ProductLoadState.loaded;
        _error    = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _state = ProductLoadState.error;
        notifyListeners();
      },
    );
  }

  void resubscribe() {
    _sub?.cancel();
    _subscribe();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}