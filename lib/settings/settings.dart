import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../career_profile/career_profile_screen.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../components/skill_section.dart';
import '../cv_builder_screens/certifications_screen.dart';
import '../cv_builder_screens/education_screen.dart';
import '../cv_builder_screens/experience_screen.dart';
import '../cv_builder_screens/add_my_project.dart';
import '../career_profile/project_career_analysis_screen.dart';
import 'personal_information_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';

  // ── Design tokens ──────────────────────────────────────────
  static const _bg = Color(0xFFF7F9FC);
  static const _ink = Color(0xFF0B1220);
  static const _muted = Color(0xFF667085);
  static const _border = Color(0xFFF0F2F5);
  static const _white = Colors.white;

  static DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  static const _profileSections = [
    _ProfileSectionConfig(
      icon: Icons.school_rounded,
      label: 'Education',
      subtitle: 'Degrees, courses & institutions',
      firestoreKey: 'educationItems',
      color: Color(0xFF5B6CFF),
      bgColor: Color(0xFFEEF0FF),
    ),
    _ProfileSectionConfig(
      icon: Icons.work_rounded,
      label: 'Experience',
      subtitle: 'Jobs, internships & roles',
      firestoreKey: 'experience',
      color: Color(0xFF16B8A6),
      bgColor: Color(0xFFE6F9F7),
    ),
    _ProfileSectionConfig(
      icon: Icons.verified_rounded,
      label: 'Certifications',
      subtitle: 'Courses & certificates earned',
      firestoreKey: 'certifications',
      color: Color(0xFFF79009),
      bgColor: Color(0xFFFFF7ED),
    ),
    _ProfileSectionConfig(
      icon: Icons.psychology_rounded,
      label: 'Skills',
      subtitle: 'Technical skills & competencies',
      firestoreKey: 'skills',
      color: Color(0xFF8B5CF6),
      bgColor: Color(0xFFF5F3FF),
    ),
    _ProfileSectionConfig(
      icon: Icons.terminal_rounded,
      label: 'Projects',
      subtitle: 'Apps, research & technical projects',
      firestoreKey: 'projects',
      color: Color(0xFF0D9488),
      bgColor: Color(0xFFCCFBF1),
    ),
  ];

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _resolveName(Map<String, dynamic>? profile, User? user) {
    final saved = profile?['displayName'] ?? profile?['fullName'] ?? profile?['name'];
    if (saved != null && saved.toString().trim().isNotEmpty) {
      return saved.toString().trim();
    }
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }
    if (user?.email != null && user!.email!.isNotEmpty) {
      final prefix = user.email!.split('@').first.trim();
      if (prefix.isNotEmpty) {
        return prefix[0].toUpperCase() + prefix.substring(1);
      }
    }
    return 'User';
  }

  String _sectionPreview(
    _ProfileSectionConfig section,
    Map<String, dynamic>? profile,
  ) {
    final raw = profile?[section.firestoreKey];
    if (raw is! List || raw.isEmpty) {
      return section.subtitle;
    }

    final previews = <String>[];
    for (final item in raw.take(2)) {
      if (item is String && item.trim().isNotEmpty) {
        previews.add(item.trim());
      } else if (item is Map) {
        String? text;
        switch (section.firestoreKey) {
          case 'educationItems':
            final deg = (item['degree'] ?? item['title'] ?? '').toString().trim();
            final ins = (item['institution'] ?? item['school'] ?? '').toString().trim();
            text = [deg, ins].where((s) => s.isNotEmpty).join(' · ');
            break;
          case 'experience':
            final role = (item['role'] ?? item['title'] ?? item['position'] ?? '').toString().trim();
            final company = (item['company'] ?? item['organization'] ?? '').toString().trim();
            text = [role, company].where((s) => s.isNotEmpty).join(' @ ');
            break;
          case 'certifications':
            final title = (item['name'] ?? item['title'] ?? item['certificate'] ?? '').toString().trim();
            final issuer = (item['issuer'] ?? item['organization'] ?? '').toString().trim();
            text = [title, issuer].where((s) => s.isNotEmpty).join(' · ');
            break;
          case 'skills':
            text = (item['name'] ?? item['skill'] ?? item['title'] ?? '').toString().trim();
            break;
        }
        if (text != null && text.isNotEmpty) {
          previews.add(text);
        }
      }
    }

    if (previews.isEmpty) {
      return '${raw.length} ${raw.length == 1 ? 'entry' : 'entries'} added';
    }
    final remaining = raw.length - previews.length;
    final joined = previews.join(', ');
    return remaining > 0 ? '$joined +$remaining more' : joined;
  }

  void _openProfileSection(String firestoreKey) {
    Widget screen;
    switch (firestoreKey) {
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
      case 'projects':
        screen = const ProjectsScreen();
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _showInfoMessage(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title settings coming soon.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Color(0xFF98A2B3),
        ),
      ),
    );
  }

  Widget _cardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: _border,
              ),
          ],
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: _muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF98A2B3),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(Map<String, dynamic>? profile, User? user) {
    final name = _resolveName(profile, user);
    final email = user?.email ?? (profile?['email']?.toString() ?? 'Signed in');
    final photoUrl = profile?['photoUrl'] ??
        profile?['photoURL'] ??
        profile?['profilePicture'] ??
        user?.photoURL;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CareerProfileScreen()),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2DD4BF), Color(0xFF4F7BF7)],
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
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        _initials(name),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Color(0xFF98A2B3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePill(String language) {
    final isSelected = _selectedLanguage == language;
    return GestureDetector(
      onTap: () => setState(() => _selectedLanguage = language),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? _ink : _white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _ink : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          language,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _muted,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(Map<String, dynamic>? profile, User? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeaderCard(profile, user),
          const SizedBox(height: 22),

          // ── YOUR PROFILE SECTIONS (Education, Experience, Certifications, Skills) ──
          _sectionHeader('YOUR PROFILE SECTIONS'),
          _cardGroup([
            for (final section in _profileSections)
              Builder(
                builder: (_) {
                  final raw = profile?[section.firestoreKey];
                  final int count = raw is List ? raw.length : 0;
                  return _settingsTile(
                    icon: section.icon,
                    iconColor: section.color,
                    iconBg: section.bgColor,
                    title: section.label,
                    subtitle: _sectionPreview(section, profile),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: section.bgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            count > 0 ? '$count added' : 'Add now',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: section.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: Color(0xFF98A2B3),
                        ),
                      ],
                    ),
                    onTap: () => _openProfileSection(section.firestoreKey),
                  );
                },
              ),
          ]),
          const SizedBox(height: 22),

          // ── ACCOUNT ──
          _sectionHeader('ACCOUNT'),
          _cardGroup([
            _settingsTile(
              icon: Icons.person_outline_rounded,
              iconColor: const Color(0xFF4F7BF7),
              iconBg: const Color(0xFFEEF2FF),
              title: 'Personal Information',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PersonalInformationScreen(),
                  ),
                );
              },
            ),
            _settingsTile(
              icon: Icons.menu_book_outlined,
              iconColor: const Color(0xFF16B8A6),
              iconBg: const Color(0xFFE6F9F7),
              title: 'Education Details',
              onTap: () => _openProfileSection('educationItems'),
            ),
            _settingsTile(
              icon: Icons.track_changes_outlined,
              iconColor: const Color(0xFFF79009),
              iconBg: const Color(0xFFFFF7ED),
              title: 'Career Preferences',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CareerProfileScreen()),
                );
              },
            ),
          ]),
          const SizedBox(height: 22),

          // ── PREFERENCES ──
          _sectionHeader('PREFERENCES'),
          _cardGroup([
            _settingsTile(
              icon: Icons.notifications_none_rounded,
              iconColor: const Color(0xFF5B6CFF),
              iconBg: const Color(0xFFEEF0FF),
              title: 'Notification Settings',
              onTap: () => _showInfoMessage('Notification'),
            ),
            _settingsTile(
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFF16A34A),
              iconBg: const Color(0xFFDCFCE7),
              title: 'Privacy & Data',
              onTap: () => _showInfoMessage('Privacy & Data'),
            ),
            _settingsTile(
              icon: Icons.auto_awesome_outlined,
              iconColor: const Color(0xFF0D9488),
              iconBg: const Color(0xFFE6F9F7),
              title: 'AI Preferences',
              subtitle: 'AI Project-to-Career & recommendations',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProjectCareerAnalysisScreen(),
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 22),

          // ── APP ──
          _sectionHeader('APP'),
          _cardGroup([
            _settingsTile(
              icon: Icons.language_rounded,
              iconColor: const Color(0xFF475569),
              iconBg: const Color(0xFFF1F5F9),
              title: 'Language',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLanguagePill('English'),
                  const SizedBox(width: 8),
                  _buildLanguagePill('Nepali'),
                ],
              ),
            ),
            _settingsTile(
              icon: Icons.help_outline_rounded,
              iconColor: const Color(0xFF475569),
              iconBg: const Color(0xFFF1F5F9),
              title: 'Help & Support',
              onTap: () => _showInfoMessage('Help & Support'),
            ),
          ]),
          const SizedBox(height: 22),

          // ── SIGN OUT ──
          InkWell(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 20, color: Color(0xFFDC2626)),
                  SizedBox(width: 10),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Sopaan v1.0.0 · Nepal Skills-to-Jobs AI',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF98A2B3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final doc = _doc;

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
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      ),
      body: doc == null
          ? _buildBody(null, user)
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: doc.snapshots(),
              builder: (context, snap) {
                return _buildBody(snap.data?.data(), user);
              },
            ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }
}

class _ProfileSectionConfig {
  final IconData icon;
  final String label;
  final String subtitle;
  final String firestoreKey;
  final Color color;
  final Color bgColor;

  const _ProfileSectionConfig({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.firestoreKey,
    required this.color,
    required this.bgColor,
  });
}
