import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String phone;
  final String location;
  final String targetRole;
  final String bio;
  final String website;
  final String linkedin;
  final List<String> educationItems;
  final List<String> experience;
  final List<String> certifications;
  final List<String> skills;
  final List<String> projects;
  final DateTime? createdAt;
  final DateTime? lastSeen;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.photoUrl = '',
    this.phone = '',
    this.location = '',
    this.targetRole = '',
    this.bio = '',
    this.website = '',
    this.linkedin = '',
    this.educationItems = const [],
    this.experience = const [],
    this.certifications = const [],
    this.skills = const [],
    this.projects = const [],
    this.createdAt,
    this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    List<String> toList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      } else if (val is String && val.trim().isNotEmpty) {
        return val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return const [];
    }

    DateTime? toDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      return null;
    }

    return UserModel(
      uid: (uid ?? map['uid'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      displayName: (map['displayName'] ?? map['fullName'] ?? map['name'] ?? '').toString(),
      photoUrl: (map['photoURL'] ?? map['photoUrl'] ?? map['profilePicture'] ?? '').toString(),
      phone: (map['phone'] ?? map['phoneNumber'] ?? '').toString(),
      location: (map['location'] ?? map['city'] ?? '').toString(),
      targetRole: (map['targetRole'] ?? map['careerRole'] ?? map['role'] ?? '').toString(),
      bio: (map['bio'] ?? map['about'] ?? map['summary'] ?? '').toString(),
      website: (map['website'] ?? map['portfolioUrl'] ?? '').toString(),
      linkedin: (map['linkedin'] ?? map['linkedinUrl'] ?? '').toString(),
      educationItems: toList(map['educationItems'] ?? map['education']),
      experience: toList(map['experience']),
      certifications: toList(map['certifications']),
      skills: toList(map['skills']),
      projects: toList(map['projects']),
      createdAt: toDate(map['createdAt']),
      lastSeen: toDate(map['lastSeen']),
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    return UserModel.fromMap(snap.data() ?? {}, uid: snap.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoUrl,
      'phone': phone,
      'location': location,
      'targetRole': targetRole,
      'bio': bio,
      'website': website,
      'linkedin': linkedin,
      'educationItems': educationItems,
      'experience': experience,
      'certifications': certifications,
      'skills': skills,
      'projects': projects,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phone,
    String? location,
    String? targetRole,
    String? bio,
    String? website,
    String? linkedin,
    List<String>? educationItems,
    List<String>? experience,
    List<String>? certifications,
    List<String>? skills,
    List<String>? projects,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      targetRole: targetRole ?? this.targetRole,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      linkedin: linkedin ?? this.linkedin,
      educationItems: educationItems ?? this.educationItems,
      experience: experience ?? this.experience,
      certifications: certifications ?? this.certifications,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
