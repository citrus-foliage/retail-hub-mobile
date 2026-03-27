import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, consumer }

extension UserRoleLabel on UserRole {
  String get displayLabel => switch (this) {
    UserRole.admin    => 'Admin',
    UserRole.consumer => 'Member',
  };
}

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final DateTime createdAt;
  final List<String> wishlist;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
    this.wishlist = const [],
  });

  bool get isAdmin => role == UserRole.admin;

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid:         doc.id,
      email:       d['email']       ?? '',
      displayName: d['displayName'] ?? '',
      role:        d['role'] == 'admin' ? UserRole.admin : UserRole.consumer,
      createdAt:   (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      wishlist:    List<String>.from(d['wishlist'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'email':       email,
    'displayName': displayName,
    'role':        role.name,
    'createdAt':   Timestamp.fromDate(createdAt),
    'wishlist':    wishlist,
  };

  AppUser copyWith({
    String? displayName,
    String? email,
    List<String>? wishlist,
  }) => AppUser(
    uid:         uid,
    email:       email       ?? this.email,
    displayName: displayName ?? this.displayName,
    role:        role,
    createdAt:   createdAt,
    wishlist:    wishlist    ?? this.wishlist,
  );
}