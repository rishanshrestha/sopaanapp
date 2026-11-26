import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/custom_bottom_nav_bar.dart';
import '../components/skill_section.dart';
import '../cv_builder_screens/certifications_screen.dart';
import '../cv_builder_screens/education_screen.dart';
import '../cv_builder_screens/experience_screen.dart';
import '../settings/settings.dart';

class CareerProfileScreen extends StatelessWidget {
  const CareerProfileScreen({super.key});

  // ── Design tokens ──────────────────────────────────────────
  static const _bg    = Color(0xFFF7F9FC);
  static const _ink   = Color(0xFF0B1220);
  static const _muted = Color(0xFF667085);
  static const _teal  = Color(0xFF16B8A6);
  static const _white = Colors.white;

  // ── Firestore doc ref ───────────────────────────────────────
  static DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  // ── Section config ──────────────────────────────────────────
  static const _sections = [
    _Section(
      icon: Icons.school_outlined,
      activeIcon: Icons.school_rounded,
      label: 'Education',
      subtitle: 'Degrees, courses & institutions',
      firestoreKey: 'educationItems',
      color: Color(0xFF5B6CFF),
      bgColor: Color(0xFFEEF0FF),
    ),
    _Section(
      icon: Icons.work_outline_rounded,
      activeIcon: Icons.work_rounded,
      label: 'Experience',
      subtitle: 'Jobs, internships & roles',
      firestoreKey: 'experience',
      color: Color(0xFF16B8A6),
      bgColor: Color(0xFFE6F9F7),
    ),
    _Section(
      icon: Icons.verified_outlined,
      activeIcon: Icons.verified_rounded,
      label: 'Certifications',
      subtitle: 'Courses & certificates earned',
      firestoreKey: 'certifications',
      color: Color(0xFFF79009),
      bgColor: Color(0xFFFFF7ED),
    ),
    _Section(
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology_rounded,
      label: 'Skills',
      subtitle: 'Technical skills & competencies',
      firestoreKey: 'skills',
      color: Color(0xFF8B5CF6),
      bgColor: Color(0xFFF5F3FF),
    ),
  ];

  List<String> _extractChips(_Section section, Map<String, dynamic>? profile) {
    final raw = profile?[section.firestoreKey];
    if (raw is! List || raw.isEmpty) return const [];

    final chips = <String>[];
    for (final item in raw) {
      if (item is String) {
        final trimmed = item.trim();
        if (trimmed.isNotEmpty) chips.add(trimmed);
      } else if (item is Map) {
        switch (section.firestoreKey) {
          case 'educationItems':
            final deg = (item['degree'] ?? item['title'] ?? '').toString().trim();
            final ins = (item['institution'] ?? item['school'] ?? '').toString().trim();
            if (deg.isNotEmpty) chips.add(deg);
            if (ins.isNotEmpty) chips.add(ins);
            break;
          case 'experience':
            final role = (item['role'] ?? item['title'] ?? item['position'] ?? '').toString().trim();
            final company = (item['company'] ?? item['organization'] ?? '').toString().trim();
            if (role.isNotEmpty) chips.add(role);
            if (company.isNotEmpty) chips.add(company);
            break;
          case 'certifications':
            final title = (item['name'] ?? item['title'] ?? item['certificate'] ?? '').toString().trim();
            final issuer = (item['issuer'] ?? item['organization'] ?? '').toString().trim();
            final text = [title, issuer].where((s) => s.isNotEmpty).join(' — ');
            if (text.isNotEmpty) chips.add(text);
            break;
          case 'skills':
            final skill = (item['name'] ?? item['skill'] ?? item['title'] ?? '').toString().trim();
            if (skill.isNotEmpty) chips.add(skill);
            break;
        }
      }
    }
    return chips;
  }

  Widget _buildSectionCard(
    BuildContext context,
    _Section section,
    Map<String, dynamic>? profile,
  ) {
    final chips = _extractChips(section, profile);

    return GestureDetector(
      onTap: () {
        Widget screen;
        switch (section.firestoreKey) {
          case 'educationItems':
            screen = const EducationScreen();
            break;
          case 'experience':
            screen = const ExperienceScreen();
            break;
          case 'certifications':
            screen = const CertificationsScreen();
            break;
          case 'skills':
            screen = const SkillsSectionDemoScreen();
            break;
          default:
            return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF0F2F5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  section.label,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const Icon(Icons.chevron_right, size: 20, color: _muted),
              ],
            ),
            const SizedBox(height: 10),
            if (chips.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips
                    .map(
                      (label) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            else
              Text(
                section.subtitle,
                style: const TextStyle(fontSize: 12.5, color: _muted),
              ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Widget _buildUserProfileCard(Map<String, dynamic>? profile, double completionPct) {
    final user = FirebaseAuth.instance.currentUser;

    // Resolve name from profile, auth displayName, or email prefix
    String name = '';
    final savedName = profile?['displayName'] ?? profile?['fullName'] ?? profile?['name'];
    if (savedName != null && savedName.toString().trim().isNotEmpty) {
      name = savedName.toString().trim();
    } else if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      name = user.displayName!.trim();
    } else if (user?.email != null && user!.email!.isNotEmpty) {
      final emailPrefix = user.email!.split('@').first.trim();
      name = emailPrefix.isNotEmpty
          ? emailPrefix[0].toUpperCase() + emailPrefix.substring(1)
          : 'User';
    } else {
      name = 'User';
    }

    // Location: only display when user has filled it in
    final rawLoc = profile?['location'] ?? profile?['city'];
    final String location = (rawLoc != null && rawLoc.toString().trim().isNotEmpty)
        ? rawLoc.toString().trim()
        : '';

    // Degree · Institution: only display when user has added education
    final educationList = profile?['educationItems'];
    String subtitle = '';
    if (educationList is List && educationList.isNotEmpty) {
      final first = educationList.first;
      if (first is Map) {
        final deg = (first['degree'] ?? first['title'] ?? '').toString().trim();
        final ins = (first['institution'] ?? first['school'] ?? '').toString().trim();
        if (deg.isNotEmpty && ins.isNotEmpty) {
          subtitle = '$deg · $ins';
        } else if (deg.isNotEmpty) {
          subtitle = deg;
        } else if (ins.isNotEmpty) {
          subtitle = ins;
        }
      } else if (first is String && first.trim().isNotEmpty) {
        subtitle = first.trim();
      }
    } else if (profile?['degree'] != null || profile?['university'] != null) {
      final deg = (profile?['degree'] ?? '').toString().trim();
      final uni = (profile?['university'] ?? '').toString().trim();
      if (deg.isNotEmpty && uni.isNotEmpty) {
        subtitle = '$deg · $uni';
      } else if (deg.isNotEmpty) {
        subtitle = deg;
      } else if (uni.isNotEmpty) {
        subtitle = uni;
      }
    }

    final photoUrl = profile?['photoUrl'] ??
        profile?['photoURL'] ??
        profile?['profilePicture'] ??
        user?.photoURL;
    final int pct = (completionPct * 100).round();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F2F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar with verified green badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2DD4BF), // teal
                      Color(0xFF4F7BF7), // blue
                    ],
                  ),
                ),
                child: photoUrl != null && photoUrl.toString().trim().isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          photoUrl.toString(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              _initials(name),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          _initials(name),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E), // vibrant green
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // User Name
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _ink,
              letterSpacing: -0.3,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: _muted,
              ),
            ),
          ],
          if (location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: _muted,
                ),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          // Profile Completion banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile Completion',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D9488), // teal
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: completionPct.clamp(0.05, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2DD4BF),
                              Color(0xFF4F7BF7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
          'Career Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: _ink),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _doc == null
          ? const Center(child: Text('Please log in first.'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _doc!.snapshots(),
              builder: (context, snap) {
                final profile = snap.data?.data();

                // Count total items across all sections
                int totalItems = 0;
                for (final s in _sections) {
                  final raw = profile?[s.firestoreKey];
                  if (raw is List) totalItems += raw.length;
                }
                final double completionPct =
                    (totalItems / 9.0).clamp(0.0, 1.0);

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── User Photo / Info Profile Card ──────────
                      _buildUserProfileCard(profile, completionPct > 0 ? completionPct : 0.78),

                      // ── Profile completion card ──────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0B1220), Color(0xFF1A2640)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.auto_awesome, size: 14, color: _teal),
                              const SizedBox(width: 6),
                              Text(
                                'PROFILE COMPLETENESS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: _teal.withValues(alpha: 0.95),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$totalItems entries added',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${(completionPct * 100).round()}%',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _teal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                value: completionPct,
                                minHeight: 7,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                valueColor:
                                    const AlwaysStoppedAnimation(_teal),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              totalItems == 0
                                  ? 'Start adding your education, experience, and certifications.'
                                  : 'Great progress! Keep adding details to improve your CV match score.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Section heading ──────────────────────────
                      const Text(
                        'Your Profile Sections',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Section cards ────────────────────────────
                      for (final s in _sections)
                        _buildSectionCard(context, s, profile),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 4,
      ),
    );
  }
}

// ── Data class for section config ───────────────────────────────────────────
class _Section {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String subtitle;
  final String firestoreKey;
  final Color color;
  final Color bgColor;

  const _Section({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.subtitle,
    required this.firestoreKey,
    required this.color,
    required this.bgColor,
  });
}
