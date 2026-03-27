import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth       _auth = FirebaseAuth.instance;
  final FirebaseFirestore  _db   = FirebaseFirestore.instance;

  AuthStatus _status  = AuthStatus.initial;
  AppUser?   _appUser;
  String?    _errorMessage;

  AuthStatus get status       => _status;
  AppUser?   get appUser      => _appUser;
  String?    get errorMessage => _errorMessage;
  bool       get isLoggedIn   => _appUser != null;
  bool       get isAdmin      => _appUser?.isAdmin ?? false;

  AuthProvider() { _init(); }

  void _init() {
    _status = AuthStatus.loading;
    _auth.authStateChanges().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _appUser = null;
      _status  = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (!doc.exists) {
        final newUser = AppUser(
          uid:         firebaseUser.uid,
          email:       firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ??
              firebaseUser.email?.split('@').first ?? 'User',
          role:      UserRole.consumer,
          createdAt: DateTime.now(),
        );
        await _db.collection('users').doc(firebaseUser.uid)
            .set(newUser.toFirestore());
        _appUser = newUser;
      } else {
        _appUser = AppUser.fromFirestore(doc);
      }
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status       = AuthStatus.error;
      _errorMessage = 'Failed to load profile.';
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _status       = AuthStatus.error;
      _errorMessage = _friendlyError(e.code);
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String displayName) async {
    _status       = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      await cred.user?.updateDisplayName(displayName.trim());
      final newUser = AppUser(
        uid:         cred.user!.uid,
        email:       email.trim(),
        displayName: displayName.trim(),
        role:        UserRole.consumer,
        createdAt:   DateTime.now(),
      );
      await _db.collection('users').doc(cred.user!.uid)
          .set(newUser.toFirestore());
      _appUser = newUser;
      _status  = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status       = AuthStatus.error;
      _errorMessage = _friendlyError(e.code);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDisplayName(String name) async {
    if (_appUser == null) return false;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    try {
      await _auth.currentUser?.updateDisplayName(trimmed);
      await _db.collection('users').doc(_appUser!.uid)
          .update({'displayName': trimmed});
      _appUser = _appUser!.copyWith(displayName: trimmed);
      notifyListeners();
      return true;
    } catch (_) { return false; }
  }

  Future<bool> updateEmail(String newEmail, String currentPassword) async {
    if (_appUser == null) return false;
    final trimmed = newEmail.trim();
    try {
      final credential = EmailAuthProvider.credential(
        email:    _appUser!.email,
        password: currentPassword,
      );
      await _auth.currentUser?.reauthenticateWithCredential(credential);
      await _auth.currentUser?.verifyBeforeUpdateEmail(trimmed);
      await _db.collection('users').doc(_appUser!.uid)
          .update({'email': trimmed});
      _appUser = _appUser!.copyWith(email: trimmed);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      notifyListeners();
      return false;
    } catch (_) { return false; }
  }

  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    if (_appUser == null) return false;
    try {
      final credential = EmailAuthProvider.credential(
        email:    _appUser!.email,
        password: currentPassword,
      );
      await _auth.currentUser?.reauthenticateWithCredential(credential);
      await _auth.currentUser?.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      notifyListeners();
      return false;
    } catch (_) { return false; }
  }

  Future<bool> toggleWishlist(String productId) async {
    if (_appUser == null) return false;
    final current = List<String>.from(_appUser!.wishlist);
    final added   = !current.contains(productId);
    if (added) {
      current.add(productId);
    } else {
      current.remove(productId);
    }
    try {
      await _db.collection('users').doc(_appUser!.uid)
          .update({'wishlist': current});
      _appUser = _appUser!.copyWith(wishlist: current);
      notifyListeners();
      return added;
    } catch (_) { return !added; }
  }

  bool isWishlisted(String productId) =>
      _appUser?.wishlist.contains(productId) ?? false;

  Future<bool> deleteAccount(String currentPassword) async {
    if (_appUser == null) return false;
    try {
      final credential = EmailAuthProvider.credential(
        email:    _appUser!.email,
        password: currentPassword,
      );
      await _auth.currentUser?.reauthenticateWithCredential(credential);
      await _db.collection('users').doc(_appUser!.uid).delete();
      await _auth.currentUser?.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      notifyListeners();
      return false;
    } catch (_) { return false; }
  }

  Future<void> signOut() async { await _auth.signOut(); }

  String _friendlyError(String code) => switch (code) {
    'user-not-found'         => 'No account found for that email.',
    'wrong-password'         => 'Incorrect password. Please try again.',
    'invalid-credential'     => 'Invalid email or password.',
    'email-already-in-use'   => 'An account already exists for that email.',
    'invalid-email'          => 'Please enter a valid email address.',
    'weak-password'          => 'Password must be at least 6 characters.',
    'too-many-requests'      => 'Too many attempts. Please try again later.',
    'network-request-failed' => 'Network error. Check your connection.',
    'requires-recent-login'  => 'Please sign in again before making this change.',
    _                        => 'Authentication failed. Please try again.',
  };
}