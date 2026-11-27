import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../cv_builder_screens/add_my_project.dart';

class ProjectCareerAnalysisScreen extends StatefulWidget {
  const ProjectCareerAnalysisScreen({super.key});

  @override
  State<ProjectCareerAnalysisScreen> createState() =>
      _ProjectCareerAnalysisScreenState();
}

class _ProjectCareerAnalysisScreenState
    extends State<ProjectCareerAnalysisScreen> {
  static const _bg = Color(0xFFF7F9FC);
  static const _ink = Color(0xFF0B1220);
  static const _muted = Color(0xFF667085);
  static const _teal = Color(0xFF16B8A6);
  static const _indigo = Color(0xFF5B6CFF);
  static const _amber = Color(0xFFF79009);
  static const _white = Colors.white;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  // AI Rule-based analyzer mapping keywords to domains, strengths and roadmap
  Map<String, dynamic> _analyzeProjects(
    List<String> projects,
    List<String> skills,
    String targetRole,
  ) {
    final combined = '${projects.join(' ')} ${skills.join(' ')} $targetRole'
        .toLowerCase();

    final detectedRoles = <String, int>{};
    final detectedSkills = <String>{};

    void score(String role, List<String> keywords) {
      int s = 0;
      for (final kw in keywords) {
        if (combined.contains(kw.toLowerCase())) {
          s += 1;
          detectedSkills.add(kw);
        }
      }
      if (s > 0) detectedRoles[role] = s;
    }

    score('Full Stack / Web Developer', [
      'react',
      'flutter',
      'node',
      'html',
      'css',
      'javascript',
      'web',
      'rest',
      'api',
      'frontend',
      'backend'
    ]);
    score('Backend Engineer', [
      'python',
      'django',
      'flask',
      'sql',
      'mysql',
      'postgresql',
      'database',
      'api',
      'backend',
      'server',
      'docker'
    ]);
    score('AI / Data Scientist', [
      'machine learning',
      'ai',
      'nlp',
      'deep learning',
      'pandas',
      'numpy',
      'tensorflow',
      'data',
      'analytics',
      'python'
    ]);
    score('Mobile App Developer', [
      'flutter',
      'dart',
      'android',
      'ios',
      'mobile',
      'firebase',
      'app'
    ]);
    score('Cloud & DevOps Engineer', [
      'docker',
      'kubernetes',
      'aws',
      'cloud',
      'ci/cd',
      'git',
      'linux',
      'serverless'
    ]);

    // Fallbacks if no projects or sparse data
    String topRole = targetRole.isNotEmpty ? targetRole : 'Software Engineer';
    if (detectedRoles.isNotEmpty) {
      final sorted = detectedRoles.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topRole = sorted.first.key;
    }

    final int readinessScore = projects.isEmpty
        ? 35
        : (50 + (projects.length * 12) + (detectedSkills.length * 4))
            .clamp(45, 96);

    final recommendations = <String>[];
    if (projects.isEmpty) {
      recommendations.add(
        'Add at least 2 real-world projects showing end-to-end functionality.',
      );
      recommendations.add(
        'Include a project repository or live demo link to boost credibility.',
      );
    } else {
      recommendations.add(
        'Highlight measurable metrics (e.g., "Reduced response time by 30%", "Handled 100+ daily requests").',
      );
      recommendations.add(
        'Deploy your projects to free hosting (Render, Vercel, Firebase) and include live URLs.',
      );
      recommendations.add(
        'Write clear README docs detailing architectural decisions, tech stack, and API schema.',
      );
    }

    final skillGaps = <String>[];
    if (!combined.contains('docker')) skillGaps.add('Docker & Containerization');
    if (!combined.contains('ci/cd') && !combined.contains('test')) {
      skillGaps.add('Automated Testing & CI/CD Pipelines');
    }
    if (!combined.contains('cloud') && !combined.contains('aws')) {
      skillGaps.add('Cloud Deployment (GCP / AWS / Firebase)');
    }
    if (!combined.contains('system design')) {
      skillGaps.add('System Design & Microservice Principles');
    }

    return {
      'topRole': topRole,
      'readinessScore': readinessScore,
      'extractedSkills': detectedSkills.toList(),
      'recommendations': recommendations,
      'skillGaps': skillGaps.take(3).toList(),
      'projectCount': projects.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _ink),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'AI Project-to-Career Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      ),
      body: _doc == null
          ? const Center(child: Text('Please log in first.'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _doc!.snapshots(),
              builder: (context, snap) {
                final data = snap.data?.data() ?? {};
                final rawProjects = data['projects'];
                final projects = rawProjects is List
                    ? rawProjects.map((e) => e.toString()).toList()
                    : <String>[];

                final rawSkills = data['skills'];
                final skills = rawSkills is List
                    ? rawSkills.map((e) => e.toString()).toList()
                    : <String>[];

                final targetRole = (data['targetRole'] ??
                        data['careerRole'] ??
                        data['role'] ??
                        '')
                    .toString();

                final analysis =
                    _analyzeProjects(projects, skills, targetRole);

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0B1220), Color(0xFF1E293B)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _teal.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    color: _teal,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'PROJECT-TO-CAREER AI INSIGHT',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: _teal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Target Career Match:\n${analysis['topRole']}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Market Alignment Score',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  '${analysis['readinessScore']}%',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _teal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                value: (analysis['readinessScore'] as int) /
                                    100.0,
                                minHeight: 8,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.15),
                                valueColor:
                                    const AlwaysStoppedAnimation(_teal),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Quick Project Summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFF0F2F5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.folder_special_rounded,
                                color: _indigo,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${analysis['projectCount']} Projects Recorded',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: _ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    projects.isEmpty
                                        ? 'Add your projects to unlock deeper analysis.'
                                        : 'Analyzed against tech requirements in Nepal.',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: _muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProjectsScreen(),
                                  ),
                                );
                              },
                              child: const Text('Manage'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Skills Validated by Projects
                      const Text(
                        'Skills Validated by Your Projects',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 10),
                      (analysis['extractedSkills'] as List).isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFF0F2F5),
                                ),
                              ),
                              child: const Text(
                                'No specific tech skills detected from your project descriptions yet.',
                                style:
                                    TextStyle(fontSize: 13, color: _muted),
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (analysis['extractedSkills'] as List)
                                  .map(
                                    (s) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0FDF9),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFA7F3D0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check_circle_outline,
                                            size: 14,
                                            color: _teal,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            s.toString().toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0F766E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                      const SizedBox(height: 22),

                      // High-Value Missing Skills (Gap Analysis)
                      const Text(
                        'Recommended Skill Additions for this Role',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final gap in (analysis['skillGaps'] as List))
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFFFEDD5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: _amber,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  gap.toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF9A3412),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 22),

                      // Actionable Recommendations
                      const Text(
                        'AI Career Improvement Plan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFF0F2F5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final rec
                                in (analysis['recommendations'] as List))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: _teal)),
                                    Expanded(
                                      child: Text(
                                        rec.toString(),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          height: 1.4,
                                          color: _ink,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // CTA
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProjectsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text(
                            'Add More Projects',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
