import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../model/cv_model.dart';

class CVRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CVRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Save or update user CV
  Future<void> saveCV(CVModel cv) async {
    final uid = currentUid;
    if (uid == null) return;

    try {
      final data = cv.toMap();
      data['userId'] = uid;
      data['savedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('user_cvs').doc(uid).set(
            data,
            SetOptions(merge: true),
          );
    } catch (e) {
      debugPrint('CVRepository.saveCV error: $e');
      rethrow;
    }
  }

  /// Get current user CV
  Future<CVModel?> getCV() async {
    final uid = currentUid;
    if (uid == null) return null;

    try {
      final doc = await _firestore.collection('user_cvs').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return CVModel.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('CVRepository.getCV error: $e');
    }
    return null;
  }
}
