import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/custom_bottom_nav_bar.dart';
import '../cv_builder_screens/certifications_screen.dart';
import '../cv_builder_screens/education_screen.dart';
import '../cv_builder_screens/experience_screen.dart';

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
  ];

  Widget _buildSectionCard(
    BuildContext context,
    _Section section,
    Map<String, dynamic>? profile,
  ) {
    final raw = profile?[section.firestoreKey];
    final int count = raw is List ? raw.length : 0;

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
          default:
            return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F2F5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: section.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(section.activeIcon, size: 22, color: section.color),
            ),
            const SizedBox(width: 14),
            // Label + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    section.subtitle,
                    style: const TextStyle(fontSize: 12, color: _muted),
                  ),
                ],
              ),
            ),
            // Count badge + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: section.bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count added',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: section.color,
                      ),
                    ),
                  )
                else
                  Text(
                    'Add now',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: section.color,
                    ),
                  ),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right, size: 18, color: _muted),
              ],
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

    final location = (profile?['location'] ?? profile?['city'] ?? 'Kathmandu').toString();
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
                          errorBuilder: (_, __, ___) => Center(
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
          const SizedBox(height: 6),
          // Degree · Institution
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: _muted,
            ),
          ),
          const SizedBox(height: 6),
          // Location pin
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

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Settings & Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.person_outline, color: _ink),
                  title: const Text('Account Details'),
                  subtitle: Text(FirebaseAuth.instance.currentUser?.email ?? 'Logged in'),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: _ink),
                  title: const Text('Privacy & Terms'),
                  onTap: () => Navigator.pop(ctx),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
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
            onPressed: () => _showSettingsSheet(context),
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
