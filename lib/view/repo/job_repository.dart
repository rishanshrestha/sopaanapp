import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../model/job_model.dart';

class JobRepository {
  final FirebaseFirestore _firestore;

  JobRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of active jobs
  Stream<List<JobModel>> streamJobs() {
    return _firestore
        .collection('jobs')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => JobModel.fromMap(doc.data(), id: doc.id))
            .toList())
        .handleError((e) {
      debugPrint('JobRepository.streamJobs error: $e');
      return <JobModel>[];
    });
  }

  /// Stream of active internships
  Stream<List<InternshipModel>> streamInternships() {
    return _firestore
        .collection('internships')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => InternshipModel.fromMap(doc.data(), id: doc.id))
            .toList())
        .handleError((e) {
      debugPrint('JobRepository.streamInternships error: $e');
      return <InternshipModel>[];
    });
  }
}
