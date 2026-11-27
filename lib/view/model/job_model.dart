class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type;
  final int matchScore;
  final List<String> requirements;
  final String description;

  const JobModel({
    required this.id,
    required this.title,
    this.company = '',
    this.location = 'Nepal',
    this.type = 'Full-time',
    this.matchScore = 90,
    this.requirements = const [],
    this.description = '',
  });

  factory JobModel.fromMap(Map<String, dynamic> map, {String? id}) {
    List<String> toList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      }
      return const [];
    }

    return JobModel(
      id: id ?? (map['id'] ?? '').toString(),
      title: (map['title'] ?? 'Opportunity').toString(),
      company: (map['company'] ?? 'Company').toString(),
      location: (map['location'] ?? 'Nepal').toString(),
      type: (map['type'] ?? 'Full-time').toString(),
      matchScore: (map['matchScore'] is num) ? (map['matchScore'] as num).toInt() : 90,
      requirements: toList(map['requirements'] ?? map['skills']),
      description: (map['description'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'type': type,
      'matchScore': matchScore,
      'requirements': requirements,
      'description': description,
    };
  }
}

class InternshipModel {
  final String id;
  final String title;
  final String company;
  final String duration;
  final String location;
  final String stipend;

  const InternshipModel({
    required this.id,
    required this.title,
    this.company = '',
    this.duration = '3 Months',
    this.location = 'Nepal',
    this.stipend = '',
  });

  factory InternshipModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return InternshipModel(
      id: id ?? (map['id'] ?? '').toString(),
      title: (map['title'] ?? 'Internship').toString(),
      company: (map['company'] ?? 'Organization').toString(),
      duration: (map['duration'] ?? '3 Months').toString(),
      location: (map['location'] ?? 'Nepal').toString(),
      stipend: (map['stipend'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'duration': duration,
      'location': location,
      'stipend': stipend,
    };
  }
}
