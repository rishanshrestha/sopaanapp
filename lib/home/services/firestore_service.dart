import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Syncs current authenticated user details into the 'users' collection.
  static Future<void> syncCurrentUser({String? displayName}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      await docRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': (displayName != null && displayName.isNotEmpty)
            ? displayName
            : (user.displayName ?? ''),
        'photoURL': user.photoURL ?? '',
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreService.syncCurrentUser error: $e');
    }
  }

  /// Real-time stream of the current user's profile document.
  static Stream<Map<String, dynamic>?> profileStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(null);
    }
    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      return doc.data();
    });
  }

  /// Real-time stream of jobs collection.
  static Stream<List<Map<String, dynamic>>> jobsStream() {
    return _firestore.collection('jobs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Real-time stream of internships collection.
  static Stream<List<Map<String, dynamic>>> internshipsStream() {
    return _firestore.collection('internships').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
