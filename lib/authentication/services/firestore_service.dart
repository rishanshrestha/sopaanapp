import '../../view/model/job_model.dart';
import '../../view/model/user_model.dart';
import '../../view/repo/job_repository.dart';
import '../../view/repo/user_repository.dart';

/// Legacy facade: keeps existing calls working seamlessly
/// while directing everything through the clean repositories.
class FirestoreService {
  static final UserRepository _userRepo = UserRepository();
  static final JobRepository _jobRepo = JobRepository();

  static Future<void> syncCurrentUser({String? displayName}) {
    return _userRepo.syncCurrentUser(displayName: displayName);
  }

  static Stream<Map<String, dynamic>?> profileStream() {
    return _userRepo.streamCurrentUser().map((user) => user?.toMap());
  }

  static Stream<UserModel?> userStream() {
    return _userRepo.streamCurrentUser();
  }

  static Stream<List<Map<String, dynamic>>> jobsStream() {
    return _jobRepo.streamJobs().map((list) => list.map((j) => j.toMap()).toList());
  }

  static Stream<List<JobModel>> typedJobsStream() {
    return _jobRepo.streamJobs();
  }

  static Stream<List<Map<String, dynamic>>> internshipsStream() {
    return _jobRepo.streamInternships().map((list) => list.map((i) => i.toMap()).toList());
  }

  static Stream<List<InternshipModel>> typedInternshipsStream() {
    return _jobRepo.streamInternships();
  }

  static Future<void> updateProfile(Map<String, dynamic> fields) {
    return _userRepo.updateProfile(fields);
  }
}
