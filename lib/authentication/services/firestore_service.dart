import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────────────────────────────────────
  // USER SYNC
  // ──────────────────────────────────────────────

  /// Creates or updates the current user's document in the 'users' collection.
  /// Uses merge so existing profile data (skills, role, etc.) is never overwritten.
  static Future<void> syncCurrentUser({String? displayName}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('FirestoreService.syncCurrentUser: no authenticated user');
      return;
    }

    try {
      final docRef = _db.collection('users').doc(user.uid);

      // Check if the doc already exists so we set createdAt only once.
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

      // SetOptions(merge: true) keeps existing fields like skills, targetRole, etc.
      await docRef.set(data, SetOptions(merge: true));
      debugPrint('FirestoreService.syncCurrentUser: synced uid=${user.uid} isNew=$isNew');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        debugPrint(
          'FirestoreService.syncCurrentUser: PERMISSION DENIED.\n'
          'Fix your Firestore Security Rules in Firebase Console:\n'
          '  rules_version = \'2\';\n'
          '  service cloud.firestore {\n'
          '    match /databases/{database}/documents {\n'
          '      match /users/{userId} {\n'
          '        allow read, write: if request.auth != null && request.auth.uid == userId;\n'
          '      }\n'
          '    }\n'
          '  }',
        );
      } else {
        debugPrint('FirestoreService.syncCurrentUser error [${e.code}]: ${e.message}');
      }
    } catch (e) {
      debugPrint('FirestoreService.syncCurrentUser unexpected error: $e');
    }
  }

  // ──────────────────────────────────────────────
  // PROFILE STREAM
  // ──────────────────────────────────────────────

  /// Real-time stream of the current user's profile document.
  /// Returns null silently on permission errors (rules not set yet).
  static Stream<Map<String, dynamic>?> profileStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(null);
    return _db
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null)
        .handleError((e) {
      debugPrint('FirestoreService.profileStream error: $e');
      return null;
    });
  }

  // ──────────────────────────────────────────────
  // JOBS STREAM
  // ──────────────────────────────────────────────

  /// Real-time stream of all documents in the 'jobs' collection.
  static Stream<List<Map<String, dynamic>>> jobsStream() {
    return _db
        .collection('jobs')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList())
        .handleError((e) {
      debugPrint('FirestoreService.jobsStream error: $e');
      return <Map<String, dynamic>>[];
    });
  }

  // ──────────────────────────────────────────────
  // INTERNSHIPS STREAM
  // ──────────────────────────────────────────────

  /// Real-time stream of all documents in the 'internships' collection.
  static Stream<List<Map<String, dynamic>>> internshipsStream() {
    return _db
        .collection('internships')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList())
        .handleError((e) {
      debugPrint('FirestoreService.internshipsStream error: $e');
      return <Map<String, dynamic>>[];
    });
  }

  // ──────────────────────────────────────────────
  // UPDATE PROFILE FIELDS
  // ──────────────────────────────────────────────

  /// Merge-updates arbitrary fields into the user's Firestore profile.
  static Future<void> updateProfile(Map<String, dynamic> fields) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .set(fields, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      debugPrint('FirestoreService.updateProfile error [${e.code}]: ${e.message}');
      rethrow;
    }
  }
}
