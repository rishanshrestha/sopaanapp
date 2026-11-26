import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../authentication/login.dart';
import '../career_profile/career_profile_screen.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../settings/settings.dart';

/// Standalone screen: pulls everything the user has added to their profile
/// (skills, projects, education, experience, certifications) from Firestore
/// (users/{uid}) and builds it into a CV, live. "Save CV" stores the CV in
/// the same `user_cvs` collection the existing CV builder uses.
/// No other project files are needed.
class CVFromProfileScreen extends StatefulWidget {
  const CVFromProfileScreen({super.key});

  @override
  State<CVFromProfileScreen> createState() => _CVFromProfileScreenState();
}

class _CVFromProfileScreenState extends State<CVFromProfileScreen> {
  bool _saving = false;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  // ── Reading helpers ────────────────────────────────────────────────────────
  List<String> _list(Map<String, dynamic> d, String key,
      {Pattern sep = ','}) {
    final raw = d[key];
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return raw
          .split(sep)
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  String _str(Map<String, dynamic> d, List<String> keys) {
    for (final k in keys) {
      final v = d[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    return '';
  }

  String _name(Map<String, dynamic> d) {
    final saved = _str(d, ['displayName', 'fullName', 'name']);
    if (saved.isNotEmpty) return saved;
    final user = FirebaseAuth.instance.currentUser;
    final fb = user?.displayName?.trim() ?? '';
    if (fb.isNotEmpty) return fb;
    final email = user?.email ?? '';
    if (email.contains('@')) {
      final p = email.split('@').first;
      return p.isEmpty ? 'Your Name' : p[0].toUpperCase() + p.substring(1);
    }
    return 'Your Name';
  }

  /// Collects everything from the profile into one CV map.
  Map<String, dynamic> _buildCv(Map<String, dynamic> d) {
    var education = _list(d, 'educationItems', sep: '\n');
    if (education.isEmpty) {
      final single = _str(d, ['education', 'degree']);
      if (single.isNotEmpty) education = [single];
    }
    return {
      'fullName': _name(d),
      'email': FirebaseAuth.instance.currentUser?.email ?? _str(d, ['email']),
      'phone': _str(d, ['phone']),
      'location': _str(d, ['location', 'city']),
      'linkedin': _str(d, ['linkedin']),
      'github': _str(d, ['github']),
      'targetRole': _str(d, ['targetRole', 'careerRole', 'role']),
      'skillList': _list(d, 'skills'),
      'educationItems': education,
      'projectItems': _list(d, 'projects', sep: '\n'),
      'experienceItems': _list(d, 'experience', sep: '\n'),
      'certificationItems': _list(d, 'certifications', sep: '\n'),
    };
  }

  // ── Saving ────────────────────────────────────────────────────────────────
  Future<void> _save(Map<String, dynamic> cv) async {
    final doc = _doc;
    if (doc == null) {
      _snack('Please log in first.');
      return;
    }
    setState(() => _saving = true);
    try {
      final now = DateTime.now().toIso8601String();
      final uid = FirebaseAuth.instance.currentUser!.uid;
      String first(String key) {
        final l = cv[key] as List;
        return l.isEmpty ? '' : l.first.toString();
      }

      final data = {
        ...cv,
        // Flat fields so the existing admin console still reads this CV.
        'userId': uid,
        'userEmail': cv['email'],
        'userName': cv['fullName'],
        'skills': (cv['skillList'] as List).join(', '),
        'degree': first('educationItems'),
        'projectTitle': first('projectItems'),
        'experienceRole': first('experienceItems'),
        'certName': first('certificationItems'),
        'status': 'Active',
        'createdAt': now,
        'updatedAt': now,
      };

      await FirebaseFirestore.instance.collection('user_cvs').add(data);
      await doc.set({'lastCv': data, 'cvUpdatedAt': now},
          SetOptions(merge: true));
      if (mounted) _snack('CV saved!');
    } catch (e) {
      if (mounted) _snack('Could not save CV: $e');
    }
    if (mounted) setState(() => _saving = false);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── UI pieces ─────────────────────────────────────────────────────────────
  Widget _section(String title, List<String> items, String emptyHint,
      {bool chips = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 22, color: Color(0xFFF0F2F5)),
        Text(title,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Color(0xFF16B8A6))),
        const SizedBox(height: 6),
        if (items.isEmpty)
          Text(emptyHint,
              style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF9CA3AF)))
        else if (chips)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items
                .map((s) => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(s,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF374151))),
            ))
                .toList(),
          )
        else
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6, right: 8),
                    child: Icon(Icons.circle, size: 5, color: Color(0xFF667085)),
                  ),
                  Expanded(
                    child: Text(item,
                        style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: Color(0xFF111827))),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  Widget _cvCard(Map<String, dynamic> cv) {
    final contact = [
      cv['email'],
      cv['phone'],
      cv['location'],
      cv['linkedin'],
      cv['github'],
    ].where((e) => e != null && e.toString().isNotEmpty).join('  ·  ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F2F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cv['fullName'] as String,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B1220))),
          if ((cv['targetRole'] as String).isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(cv['targetRole'] as String,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16B8A6))),
          ],
          if (contact.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(contact,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF667085))),
          ],
          _section('SKILLS', List<String>.from(cv['skillList']),
              'No skills added yet.',
              chips: true),
          _section('EDUCATION', List<String>.from(cv['educationItems']),
              'No education added yet.'),
          _section('EXPERIENCE', List<String>.from(cv['experienceItems']),
              'No experience added yet.'),
          _section('PROJECTS', List<String>.from(cv['projectItems']),
              'No projects added yet.'),
          _section('CERTIFICATIONS', List<String>.from(cv['certificationItems']),
              'No certifications added yet.'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doc = _doc;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('My CV',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0B1220))),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF111827)),
            tooltip: 'Career Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CareerProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF111827)),
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
      body: doc == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 54, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 16),
                    const Text(
                      'Log in to build your CV',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B1220),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to pull your experience, education, skills, and certifications into a live CV.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Login()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16B8A6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Go to Login', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            )
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: doc.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final cv = _buildCv(snap.data?.data() ?? {});
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Built automatically from your profile. Anything you add or remove updates this CV instantly.',
                  style:
                  TextStyle(fontSize: 12.5, color: Color(0xFF667085)),
                ),
                const SizedBox(height: 14),
                _cvCard(cv),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : () => _save(cv),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B1220),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _saving
                        ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : const Text('Save CV',
                        style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 3,
      ),
    );
  }
}