class CVModel {
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final String linkedin;
  final String github;
  final String targetRole;
  final List<String> skillList;
  final List<String> educationItems;
  final List<String> projectItems;
  final List<String> experienceItems;
  final List<String> certificationItems;
  final DateTime? savedAt;

  const CVModel({
    required this.fullName,
    required this.email,
    this.phone = '',
    this.location = '',
    this.linkedin = '',
    this.github = '',
    this.targetRole = '',
    this.skillList = const [],
    this.educationItems = const [],
    this.projectItems = const [],
    this.experienceItems = const [],
    this.certificationItems = const [],
    this.savedAt,
  });

  factory CVModel.fromMap(Map<String, dynamic> map) {
    List<String> toList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      } else if (val is String && val.trim().isNotEmpty) {
        return val.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return const [];
    }

    return CVModel(
      fullName: (map['fullName'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      linkedin: (map['linkedin'] ?? '').toString(),
      github: (map['github'] ?? '').toString(),
      targetRole: (map['targetRole'] ?? '').toString(),
      skillList: toList(map['skillList'] ?? map['skills']),
      educationItems: toList(map['educationItems'] ?? map['education']),
      projectItems: toList(map['projectItems'] ?? map['projects']),
      experienceItems: toList(map['experienceItems'] ?? map['experience']),
      certificationItems: toList(map['certificationItems'] ?? map['certifications']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'linkedin': linkedin,
      'github': github,
      'targetRole': targetRole,
      'skillList': skillList,
      'educationItems': educationItems,
      'projectItems': projectItems,
      'experienceItems': experienceItems,
      'certificationItems': certificationItems,
    };
  }
}
