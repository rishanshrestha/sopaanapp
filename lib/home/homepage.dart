import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../career_profile/career_profile_screen.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../components/skill_section.dart';
import '../cv_builder_screens/convert_to_cv.dart';
import '../settings/settings.dart';

//import 'screens/cv_analyzer_screen.dart';
//import 'screens/freelance_screen.dart';
//import 'screens/internships_screen.dart';
//import 'screens/interview_screen.dart';
//import 'screens/job_detail_screen.dart';
//import 'screens/jobs_screen.dart';
//import 'screens/notifications_screen.dart';
//import 'screens/roadmap_screen.dart';
//import 'screens/settings_screen.dart';
import 'services/firestore_service.dart';

// Backward compatibility alias
typedef HomeScreen = Homepage;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final user = FirebaseAuth.instance.currentUser;
  int _currentNavIndex = 0;

  // Palette from the React design
  static const bg = Color(0xFFF7F9FC);
  static const ink = Color(0xFF0B1220);
  static const muted = Color(0xFF667085);
  static const teal = Color(0xFF16B8A6);
  static const indigo = Color(0xFF5B6CFF);
  static const amber = Color(0xFFF79009);
  static const border = Color(0xFFF0F2F5);

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  String _displayName(Map<String, dynamic>? profile) {
    final saved = profile?['displayName'] ?? profile?['fullName'] ?? profile?['name'];
    if (saved != null && saved.toString().trim().isNotEmpty) {
      return saved.toString().trim();
    }
    final name = user?.displayName;
    if (name != null && name.trim().isNotEmpty) return name;
    final email = user?.email ?? '';
    return email.contains('@') ? email.split('@').first : 'there';
  }

  void _navigate(String screen, {Map<String, dynamic>? job}) {
    switch (screen) {
      case 'career':
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CareerProfileScreen()),
        );
        return;
      case 'skills':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SkillsSectionDemoScreen()),
        );
        return;
      case 'cv':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CVFromProfileScreen()),
        );
        return;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        return;
      default:
        Get.snackbar(
          screen.capitalizeFirst ?? screen,
          'Opening $screen...',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: FirestoreService.profileStream(),
          builder: (context, profileSnap) {
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService.jobsStream(),
              builder: (context, jobsSnap) {
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FirestoreService.internshipsStream(),
                  builder: (context, internSnap) {
                    final profile = profileSnap.data;
                    final jobs = jobsSnap.data ?? [];
                    final internships = internSnap.data ?? [];

                    return ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        _header(profile),
                        _careerProfileCard(profile),
                        _insights(jobs, internships),
                        _topMatch(jobs),
                        _skillProgress(profile),
                        _careerProgress(profile),
                        _aiInsightCard(profile),
                        _quickActions(),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          const labels = ['home', 'jobs', 'career', 'cv', 'profile'];
          _navigate(labels[index]);
        },
      ),
    );
  }

  // ---------- Shared helpers ----------

  Widget _section({required Widget child, double bottom = 16}) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottom),
        child: child,
      );

  Widget _sectionTitle(String title, {String? actionLabel, VoidCallback? onAction, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Row(children: [
                Text(actionLabel,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: teal)),
                const Icon(Icons.chevron_right, size: 16, color: teal),
              ]),
            ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration({double radius = 16}) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      );

  // ---------- Sections ----------

  Widget _header(Map<String, dynamic>? profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Good morning,', style: TextStyle(fontSize: 13, color: muted)),
                const SizedBox(height: 2),
                Text('${_displayName(profile)} 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ink)),
                const SizedBox(height: 2),
                const Text("Let's move your career forward.",
                    style: TextStyle(fontSize: 13, color: muted)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _navigate('notifications'),
            child: Container(
              width: 40,
              height: 40,
              decoration: _cardDecoration(radius: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.notifications_none, size: 20, color: Color(0xFF111827)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF04438),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _navigate('settings'),
            child: Container(
              width: 40,
              height: 40,
              decoration: _cardDecoration(radius: 12),
              child: const Icon(Icons.settings_outlined, size: 20, color: Color(0xFF111827)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _careerProfileCard(Map<String, dynamic>? profile) {
    final role = profile?['targetRole'] ?? profile?['careerRole'] ?? profile?['role'] ?? 'Career Explorer';
    final rawSkills = profile?['skills'];
    final int skillCount = rawSkills is List
        ? rawSkills.length
        : (rawSkills != null && rawSkills.toString().isNotEmpty
            ? rawSkills.toString().split(',').length
            : 0);

    final double progress = skillCount > 0 ? (skillCount / 8.0).clamp(0.2, 1.0) : 0.45;
    final int pct = (progress * 100).round();

    return _section(
      child: GestureDetector(
        onTap: () => _navigate('profile'),
        child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1220), Color(0xFF1A2640)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(shape: BoxShape.circle, color: teal.withValues(alpha: 0.12)),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.auto_awesome, size: 14, color: teal),
                      const SizedBox(width: 6),
                      Text('AI CAREER PROFILE',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: teal.withValues(alpha: 0.95))),
                    ]),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 12),
                Text(role.toString(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation(teal),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$pct%',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: teal)),
                ]),
                const SizedBox(height: 12),
                Text(
                  skillCount > 0
                      ? '$skillCount skills configured in your profile.'
                      : 'Add skills and career goals to get personalized AI matching.',
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.65)),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _insights(List<Map<String, dynamic>> jobs, List<Map<String, dynamic>> internships) {
    final items = [
      (
        Icons.work_outline,
        jobs.isNotEmpty
            ? '${jobs.length} jobs currently open on platform'
            : 'Explore latest job opportunities',
        teal,
        'jobs'
      ),
      (
        Icons.auto_awesome,
        internships.isNotEmpty
            ? '${internships.length} internships published by admin'
            : 'Find entry-level internships',
        amber,
        'internships'
      ),
      (
        Icons.trending_up,
        'Personalized career roadmaps and skill guides',
        indigo,
        'roadmap'
      ),
    ];
    return _section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('AI Insights',
              trailing: const Icon(Icons.auto_awesome, size: 16, color: teal)),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _navigate(it.$4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: _cardDecoration(radius: 14),
                  child: Row(children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: it.$3, borderRadius: BorderRadius.circular(10)),
                      child: Icon(it.$1, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(it.$2,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
                    ),
                    const Icon(Icons.chevron_right, size: 16, color: Color(0xFF9CA3AF)),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _topMatch(List<Map<String, dynamic>> jobs) {
    final topJob = jobs.isNotEmpty ? jobs.first : null;

    return _section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Top Match', actionLabel: 'See all', onAction: () => _navigate('jobs')),
          if (topJob != null)
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _navigate('job-detail', job: topJob),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE6F9F7), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.business_center_outlined, color: teal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(topJob['title'] ?? 'Opportunity',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ink)),
                        const SizedBox(height: 2),
                        Text('${topJob['company'] ?? 'Company'} • ${topJob['location'] ?? 'Nepal'}',
                            style: const TextStyle(fontSize: 12, color: muted)),
                      ],
                    ),
                  ),
                  Text('${topJob['matchScore'] ?? 92}%',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: teal)),
                ]),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.business_center_outlined, color: muted),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No Active Jobs Yet',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ink)),
                      SizedBox(height: 2),
                      Text('Admin has not posted job listings yet.', style: TextStyle(fontSize: 12, color: muted)),
                    ],
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _skillBar(String name, double level) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ink)),
          Text('${(level * 100).round()}%',
              style: const TextStyle(fontSize: 12, color: muted)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: level,
            minHeight: 6,
            backgroundColor: border,
            valueColor: const AlwaysStoppedAnimation(teal),
          ),
        ),
      ]),
    );
  }

  Widget _skillProgress(Map<String, dynamic>? profile) {
    final rawSkills = profile?['skills'];
    List<String> userSkills = [];
    if (rawSkills is List) {
      userSkills = rawSkills.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    } else if (rawSkills != null && rawSkills.toString().isNotEmpty) {
      userSkills = rawSkills.toString().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }

    return _section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Skill Progress',
              actionLabel: 'Full analysis', onAction: () => _navigate('skills')),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            decoration: _cardDecoration(),
            child: userSkills.isNotEmpty
                ? Column(
                    children: [
                      for (int i = 0; i < userSkills.take(5).length; i++)
                        _skillBar(userSkills[i], (0.85 - (i * 0.10)).clamp(0.40, 0.95)),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Column(
                        children: [
                          const Text(
                            'No skills recorded yet.',
                            style: TextStyle(fontSize: 13, color: muted),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => _navigate('settings'),
                            child: const Text(
                              'Add skills in Settings or CV Builder →',
                              style: TextStyle(fontSize: 12, color: teal, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _careerProgress(Map<String, dynamic>? profile) {
    int filled = 0;
    const fields = ['displayName', 'location', 'targetRole', 'skills', 'education', 'projects', 'experience'];
    for (final f in fields) {
      final v = profile?[f];
      if (v != null && v.toString().isNotEmpty) filled++;
    }
    final double completion = profile != null ? (filled / fields.length).clamp(0.15, 1.0) : 0.25;
    final int compPct = (completion * 100).round();
    final int readinessPct = ((completion * 0.9) * 100).round();

    return _section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Career Progress'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Profile Completion', style: TextStyle(fontSize: 13, color: muted)),
                  const SizedBox(height: 2),
                  Text('$compPct%',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ink)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('Career Readiness', style: TextStyle(fontSize: 13, color: muted)),
                  const SizedBox(height: 2),
                  Text('$readinessPct%',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: teal)),
                ]),
              ]),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: completion,
                  minHeight: 8,
                  backgroundColor: border,
                  valueColor: const AlwaysStoppedAnimation(teal),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Next Action',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                      Text(
                        compPct < 80
                            ? 'Complete your profile details in Settings to boost matching'
                            : 'Generate a tailored cover letter and apply for roles!',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                      ),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _aiInsightCard(Map<String, dynamic>? profile) {
    final role = profile?['targetRole'] ?? 'your selected career';
    return _section(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F9F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: teal.withValues(alpha: 0.25)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.auto_awesome, size: 18, color: teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your profile is synchronized with real-time $role demand in Nepal. Keep skills updated for accurate AI matching.',
              style: const TextStyle(fontSize: 13, height: 1.4, color: ink),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _quickActions() {
    final actions = [
      ('Practice Interview', '🎤', const Color(0xFFEEF0FF), 'interview-setup'),
      ('Analyze CV', '📄', const Color(0xFFE6F9F7), 'cv-analysis'),
      ('Career Roadmap', '🗺️', const Color(0xFFFFF7ED), 'roadmap'),
      ('Find Freelance', '💻', const Color(0xFFFEF3F2), 'freelance'),
    ];
    return _section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Quick Actions'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.1,
            children: [
              for (final a in actions)
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _navigate(a.$4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: a.$3,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(a.$2, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(a.$1,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
