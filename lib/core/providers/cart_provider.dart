import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.effectivePrice * quantity;

  Map<String, dynamic> toJson() => {
    'quantity': quantity,
    'product': {
      'id':              product.id,
      'name':            product.name,
      'sku':             product.sku,
      'category':        product.category,
      'basePrice':       product.basePrice,
      'discountedPrice': product.discountedPrice,
      'stockQuantity':   product.stockQuantity,
      'description':     product.description,
      'supplier':        product.supplier,
      'dateAdded':       product.dateAdded.toIso8601String(),
      'imageUrl':        product.imageUrl,
    },
  };
}

class CartProvider extends ChangeNotifier {
  static const _kCartKey = 'retailhub_cart';

  final Map<String, CartItem> _items = {};
  bool _loaded = false;

  CartProvider() { _loadFromPrefs(); }

  List<CartItem> get items    => _items.values.toList();
  bool           get isEmpty  => _items.isEmpty;
  int            get itemCount => _items.values.fold(0, (s, i) => s + i.quantity);
  double         get total    => _items.values.fold(0.0, (s, i) => s + i.subtotal);
  bool           get isLoaded => _loaded;

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      final current = _items[product.id]!.quantity;
      if (current < product.stockQuantity) {
        _items[product.id]!.quantity++;
      }
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
    _saveToPrefs();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
    _saveToPrefs();
  }

  void updateQuantity(String productId, int quantity) {
    if (!_items.containsKey(productId)) return;
    if (quantity <= 0) {
      removeItem(productId);
    } else {
      final maxStock = _items[productId]!.product.stockQuantity;
      _items[productId]!.quantity = quantity.clamp(1, maxStock);
      notifyListeners();
      _saveToPrefs();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _saveToPrefs();
  }

  List<OrderItem> toOrderItems() => _items.values
      .map((ci) => OrderItem(
    productId:   ci.product.id,
    productName: ci.product.name,
    imageUrl:    ci.product.imageUrl,
    unitPrice:   ci.product.effectivePrice,
    quantity:    ci.quantity,
  ))
      .toList();


  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list  = _items.values.map((ci) => jsonEncode(ci.toJson())).toList();
      await prefs.setStringList(_kCartKey, list);
    } catch (_) {}
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list  = prefs.getStringList(_kCartKey) ?? [];
      for (final raw in list) {
        final map     = jsonDecode(raw) as Map<String, dynamic>;
        final qty     = (map['quantity'] as int?) ?? 1;
        final pMap    = map['product'] as Map<String, dynamic>;
        final product = _productFromMap(pMap);
        if (product != null) {
          _items[product.id] = CartItem(product: product, quantity: qty);
        }
      }
    } catch (_) {}
    _loaded = true;
    notifyListeners();
  }

  Product? _productFromMap(Map<String, dynamic> d) {
    try {
      return Product(
        id:              d['id']             ?? '',
        name:            d['name']           ?? '',
        sku:             d['sku']            ?? '',
        category:        d['category']       ?? '',
        basePrice:       (d['basePrice']      ?? 0).toDouble(),
        discountedPrice: (d['discountedPrice'] ?? 0).toDouble(),
        stockQuantity:   (d['stockQuantity']  ?? 0).toInt(),
        description:     d['description']    ?? '',
        supplier:        d['supplier']       ?? '',
        dateAdded:       d['dateAdded'] != null
            ? DateTime.tryParse(d['dateAdded'].toString()) ?? DateTime.now()
            : DateTime.now(),
        imageUrl:        d['imageUrl']       ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}