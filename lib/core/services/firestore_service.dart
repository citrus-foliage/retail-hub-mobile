import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db   = FirebaseFirestore.instance;
  final FirebaseAuth      _auth = FirebaseAuth.instance;

  Future<void> _refreshToken() async {
    await _auth.currentUser?.getIdToken(true);
  }

  CollectionReference<Map<String, dynamic>> get _products => _db.collection('products');
  CollectionReference<Map<String, dynamic>> get _orders   => _db.collection('orders');
  CollectionReference<Map<String, dynamic>> get _users    => _db.collection('users');


  Stream<List<Product>> productsStream() {
    return _products
        .orderBy('dateAdded', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Product.fromFirestore).toList());
  }

  Future<Product?> getProduct(String id) async {
    final doc = await _products.doc(id).get();
    if (!doc.exists) return null;
    return Product.fromFirestore(doc);
  }

  Future<String> addProduct(Product product) async {
    await _refreshToken();
    final ref = await _products.add(product.toFirestore());
    return ref.id;
  }

  Future<void> updateProduct(Product product) async {
    await _refreshToken();
    await _products.doc(product.id).update(product.toFirestore());
  }

  Future<void> deleteProduct(String id) async {
    await _refreshToken();
    await _products.doc(id).delete();
  }

  Future<void> deductStock(Map<String, int> deductions) async {
    final batch = _db.batch();
    for (final entry in deductions.entries) {
      batch.update(
        _products.doc(entry.key),
        {'stockQuantity': FieldValue.increment(-entry.value)},
      );
    }
    await batch.commit();
  }


  Stream<List<AppOrder>> allOrdersStream() {
    return _orders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AppOrder.fromFirestore).toList());
  }

  Stream<List<AppOrder>> userOrdersStream(String userId) {
    return _orders
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final orders = snap.docs.map(AppOrder.fromFirestore).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  Future<String> placeOrder(AppOrder order) async {
    final ref = await _orders.add(order.toFirestore());
    return ref.id;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _refreshToken();
    await _orders.doc(orderId).update({'status': status.name});
  }

  Future<AppOrder?> getOrder(String id) async {
    final doc = await _orders.doc(id).get();
    if (!doc.exists) return null;
    return AppOrder.fromFirestore(doc);
  }


  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<void> updateDisplayName(String uid, String name) async {
    await _users.doc(uid).update({'displayName': name});
  }

  Future<void> updateEmail(String uid, String email) async {
    await _users.doc(uid).update({'email': email});
  }

  Stream<List<AppUser>> allUsersStream() {
    return _users
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AppUser.fromFirestore).toList());
  }

  Future<void> deleteUserDocument(String uid) async {
    await _users.doc(uid).delete();
  }

  Future<void> addToWishlist(String uid, String productId) async {
    await _users.doc(uid).update({
      'wishlist': FieldValue.arrayUnion([productId]),
    });
  }

  Future<void> removeFromWishlist(String uid, String productId) async {
    await _users.doc(uid).update({
      'wishlist': FieldValue.arrayRemove([productId]),
    });
  }
}