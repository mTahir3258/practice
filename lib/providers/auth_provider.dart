// lib/providers/auth_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inward_outward_management/core/models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  bool loading = false;
  String? error;

  // Cache current user's role (normalized to lowercase)
  String? _currentUserRole;
  String? get currentUserRole => _currentUserRole;

  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }

  void _setError(String? err) {
    error = err;
    notifyListeners();
  }

  // Register user and create Firestore doc (unchanged behavior, but set companyId for companies)
  Future<bool> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _setError(null);
    _setLoading(true);

    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCred.user;
      if (user == null)
        throw FirebaseAuthException(
          code: 'USER_NULL',
          message: 'User is null after registration',
        );

      final appUser = AppUser(
        uid: user.uid,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );

      // Save map and ensure companyId for company users
      final map = appUser.toMap();
      if ((role).toLowerCase() == 'company') {
        // Keep companyId same as uid (you can change if you have another id)
        map['companyId'] = user.uid;
      }

      await _fire.collection('users').doc(user.uid).set(map);
      await user.updateDisplayName(name);

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(e.message ?? 'Auth error: ${e.code}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  /// Sign in and return the normalized role string (lowercase) on success,
  /// or null on failure. Also caches role in `_currentUserRole`.
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setError(null);
    _setLoading(true);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        _setError('User not found after sign-in');
        _setLoading(false);
        return null;
      }

      // Fetch Firestore user document
      final userDoc = await _fire.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        _setError('User document not found in Firestore');
        _setLoading(false);
        return null;
      }

      final data = userDoc.data()!;
      final roleRaw = (data['role'] ?? '').toString();

      if (roleRaw.isEmpty) {
        _setError('Role field missing for user');
        _setLoading(false);
        return null;
      }

      // Normalize role to lowercase for consistent comparisons
      final roleNormalized = roleRaw.trim().toLowerCase();
      _currentUserRole = roleNormalized;
      _setLoading(false);
      return roleNormalized; // returns e.g. 'company', 'supplier', 'customer'
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(e.message ?? 'Login failed');
      return null;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return null;
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUserRole = null;
    notifyListeners();
  }

  Future<String?> fetchUserRole() async {
    try {
      // If we already cached it, return quickly
      if (_currentUserRole != null) return _currentUserRole;

      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;
      final doc = await _fire.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final roleRaw = (doc['role'] ?? '').toString();
      _currentUserRole = roleRaw.trim().toLowerCase();
      return _currentUserRole;
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      return null;
    }
  }
}
