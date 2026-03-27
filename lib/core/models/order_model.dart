import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final double unitPrice;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
  });

  double get subtotal => unitPrice * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
    productId:   m['productId']   ?? '',
    productName: m['productName'] ?? '',
    imageUrl:    m['imageUrl']    ?? '',
    unitPrice:   (m['unitPrice']  ?? 0).toDouble(),
    quantity:    (m['quantity']   ?? 1).toInt(),
  );

  Map<String, dynamic> toMap() => {
    'productId':   productId,
    'productName': productName,
    'imageUrl':    imageUrl,
    'unitPrice':   unitPrice,
    'quantity':    quantity,
  };
}

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get label => name[0].toUpperCase() + name.substring(1);
}

class AppOrder {
  final String id;
  final String userId;
  final String userEmail;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;

  const AppOrder({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory AppOrder.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppOrder(
      id:        doc.id,
      userId:    d['userId']    ?? '',
      userEmail: d['userEmail'] ?? '',
      items: (d['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      total:  (d['total'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
            (s) => s.name == (d['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId':    userId,
    'userEmail': userEmail,
    'items':     items.map((i) => i.toMap()).toList(),
    'total':     total,
    'status':    status.name,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}