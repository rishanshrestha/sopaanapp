import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Local admin backend sync URL (supports Android emulator 10.0.2.2 & physical device IP / localhost)
  static const String adminSyncUrl = 'http://10.0.2.2:8000/api/sync-profile';
  static const String adminLocalUrl = 'http://127.0.0.1:8000/api/sync-profile';

  UserRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;
  User? get currentUser => _auth.currentUser;

  DocumentReference<Map<String, dynamic>>? get userDocRef {
    final uid = currentUid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  /// Real-time stream of the current user profile as a typed UserModel
  Stream<UserModel?> streamCurrentUser() {
    final uid = currentUid;
    if (uid == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) => snap.exists && snap.data() != null
            ? UserModel.fromSnapshot(snap)
            : null)
        .handleError((e) {
      debugPrint('UserRepository.streamCurrentUser error: $e');
      return null;
    });
  }

  /// Get current user profile once
  Future<UserModel?> getCurrentUser() async {
    final ref = userDocRef;
    if (ref == null) return null;

    try {
      final snap = await ref.get();
      if (snap.exists && snap.data() != null) {
        return UserModel.fromSnapshot(snap);
      }
    } catch (e) {
      debugPrint('UserRepository.getCurrentUser error: $e');
    }
    return null;
  }

  /// Syncs newly authenticated user with Firebase
  Future<void> syncCurrentUser({String? displayName}) async {
    final user = currentUser;
    if (user == null) return;

    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final snap = await docRef.get();
      final isNew = !snap.exists;

      final data = <String, dynamic>{
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': (displayName != null && displayName.isNotEmpty)
            ? displayName
            : (user.displayName ?? ''),
        'photoURL': user.photoURL ?? '',
        'lastSeen': FieldValue.serverTimestamp(),
      };

      if (isNew) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await docRef.set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('UserRepository.syncCurrentUser error: $e');
    }
  }

  /// Sync profile with the Python Admin backend
  Future<void> syncToAdminPanel(Map<String, dynamic> data) async {
    final uid = currentUid;
    if (uid == null) return;
    final payload = Map<String, dynamic>.from(data);
    payload['uid'] = uid;

    for (final url in [adminSyncUrl, adminLocalUrl]) {
      try {
        await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 2));
        break;
      } catch (_) {}
    }
  }

  /// Updates profile fields
  Future<void> updateProfile(Map<String, dynamic> fields) async {
    final ref = userDocRef;
    if (ref == null) return;
    await ref.set(fields, SetOptions(merge: true));
    
    // Sync to admin panel
    try {
      final snap = await ref.get();
      if (snap.data() != null) {
        await syncToAdminPanel(snap.data()!);
      }
    } catch (_) {}
  }

  /// Add single entry to an array field (e.g. educationItems, experience, certifications, projects)
  Future<void> addArrayEntry(String key, String entry) async {
    final ref = userDocRef;
    if (ref == null) return;
    await ref.set({
      key: FieldValue.arrayUnion([entry]),
    }, SetOptions(merge: true));

    // Sync to admin panel
    try {
      final snap = await ref.get();
      if (snap.data() != null) {
        await syncToAdminPanel(snap.data()!);
      }
    } catch (_) {}
  }

  /// Remove single entry from an array field
  Future<void> removeArrayEntry(String key, String entry) async {
    final ref = userDocRef;
    if (ref == null) return;
    await ref.set({
      key: FieldValue.arrayRemove([entry]),
    }, SetOptions(merge: true));

    // Sync to admin panel
    try {
      final snap = await ref.get();
      if (snap.data() != null) {
        await syncToAdminPanel(snap.data()!);
      }
    } catch (_) {}
  }

  /// Replaces entire list for a given field (e.g. skills)
  Future<void> setListField(String key, List<String> items) async {
    final ref = userDocRef;
    if (ref == null) return;
    await ref.set({
      key: items,
    }, SetOptions(merge: true));

    // Sync to admin panel
    try {
      final snap = await ref.get();
      if (snap.data() != null) {
        await syncToAdminPanel(snap.data()!);
      }
    } catch (_) {}
  }
}
