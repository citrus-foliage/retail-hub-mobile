import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double basePrice;
  final double discountedPrice;
  final int stockQuantity;
  final String description;
  final String supplier;
  final DateTime dateAdded;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.basePrice,
    required this.discountedPrice,
    required this.stockQuantity,
    required this.description,
    required this.supplier,
    required this.dateAdded,
    required this.imageUrl,
  });

  bool get isOnSale => discountedPrice < basePrice && discountedPrice > 0;
  bool get inStock   => stockQuantity > 0;
  double get effectivePrice => isOnSale ? discountedPrice : basePrice;

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Product(
      id:               doc.id,
      name:             d['name']             ?? '',
      sku:              d['sku']              ?? '',
      category:         d['category']         ?? '',
      basePrice:        (d['basePrice']        ?? 0).toDouble(),
      discountedPrice:  (d['discountedPrice']  ?? 0).toDouble(),
      stockQuantity:    (d['stockQuantity']    ?? 0).toInt(),
      description:      d['description']      ?? '',
      supplier:         d['supplier']         ?? '',
      dateAdded: (d['dateAdded'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl:         d['imageUrl']         ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name':             name,
    'sku':              sku,
    'category':         category,
    'basePrice':        basePrice,
    'discountedPrice':  discountedPrice,
    'stockQuantity':    stockQuantity,
    'description':      description,
    'supplier':         supplier,
    'dateAdded':        Timestamp.fromDate(dateAdded),
    'imageUrl':         imageUrl,
  };

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    double? basePrice,
    double? discountedPrice,
    int? stockQuantity,
    String? description,
    String? supplier,
    DateTime? dateAdded,
    String? imageUrl,
  }) {
    return Product(
      id:              id              ?? this.id,
      name:            name            ?? this.name,
      sku:             sku             ?? this.sku,
      category:        category        ?? this.category,
      basePrice:       basePrice       ?? this.basePrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      stockQuantity:   stockQuantity   ?? this.stockQuantity,
      description:     description     ?? this.description,
      supplier:        supplier        ?? this.supplier,
      dateAdded:       dateAdded       ?? this.dateAdded,
      imageUrl:        imageUrl        ?? this.imageUrl,
    );
  }
}