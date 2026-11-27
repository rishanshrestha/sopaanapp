import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {
  // ── Design tokens ──────────────────────────────────────
  static const _bg    = Color(0xFFF7F9FC);
  static const _ink   = Color(0xFF0B1220);
  static const _muted = Color(0xFF667085);
  static const _border = Color(0xFFF0F2F5);
  static const _white = Colors.white;
  static const _teal  = Color(0xFF16B8A6);

  // ── Form controllers ───────────────────────────────────
  final _fullNameCtrl    = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _locationCtrl    = TextEditingController();
  final _targetRoleCtrl  = TextEditingController();
  final _bioCtrl         = TextEditingController();
  final _websiteCtrl     = TextEditingController();
  final _linkedinCtrl    = TextEditingController();

  bool _loading = true;
  bool _saving  = false;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final doc = _doc;
    if (doc == null) {
      setState(() => _loading = false);
      return;
    }
    final snap = await doc.get();
    final data = snap.data() ?? {};

    _fullNameCtrl.text   = (data['displayName'] ?? data['fullName'] ?? data['name'] ?? '').toString();
    _phoneCtrl.text      = (data['phone'] ?? data['phoneNumber'] ?? '').toString();
    _locationCtrl.text   = (data['location'] ?? data['city'] ?? '').toString();
    _targetRoleCtrl.text = (data['targetRole'] ?? data['careerRole'] ?? data['role'] ?? '').toString();
    _bioCtrl.text        = (data['bio'] ?? data['about'] ?? data['summary'] ?? '').toString();
    _websiteCtrl.text    = (data['website'] ?? data['portfolioUrl'] ?? '').toString();
    _linkedinCtrl.text   = (data['linkedin'] ?? data['linkedinUrl'] ?? '').toString();

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final doc = _doc;
    if (doc == null) return;

    setState(() => _saving = true);
    try {
      await doc.set({
        'displayName': _fullNameCtrl.text.trim(),
        'fullName'   : _fullNameCtrl.text.trim(),
        'phone'      : _phoneCtrl.text.trim(),
        'location'   : _locationCtrl.text.trim(),
        'targetRole' : _targetRoleCtrl.text.trim(),
        'bio'        : _bioCtrl.text.trim(),
        'website'    : _websiteCtrl.text.trim(),
        'linkedin'   : _linkedinCtrl.text.trim(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal information saved!'),
            backgroundColor: Color(0xFF16B8A6),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _targetRoleCtrl.dispose();
    _bioCtrl.dispose();
    _websiteCtrl.dispose();
    _linkedinCtrl.dispose();
    super.dispose();
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14.5, color: _ink),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: _muted, fontSize: 14),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 20, color: _muted)
                  : null,
              filled: true,
              fillColor: _white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _teal, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: Color(0xFF98A2B3),
        ),
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
          'Personal Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _saving ? null : _save,
              style: TextButton.styleFrom(
                backgroundColor: _teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── BASIC INFO ──────────────────────────────
                  _sectionLabel('BASIC INFO'),
                  Container(
                    padding: const EdgeInsets.all(18),
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
                        _field(
                          label: 'Full Name',
                          controller: _fullNameCtrl,
                          hint: 'e.g. Risan Shrestha',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        _field(
                          label: 'Phone Number',
                          controller: _phoneCtrl,
                          hint: 'e.g. +977 98XXXXXXXX',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                        ),
                        _field(
                          label: 'Location / City',
                          controller: _locationCtrl,
                          hint: 'e.g. Kathmandu, Nepal',
                          prefixIcon: Icons.location_on_outlined,
                        ),
                        _field(
                          label: 'Target Role / Career Goal',
                          controller: _targetRoleCtrl,
                          hint: 'e.g. Backend Developer',
                          prefixIcon: Icons.track_changes_outlined,
                        ),
                        _field(
                          label: 'Bio / Summary',
                          controller: _bioCtrl,
                          hint:
                              'A short introduction about yourself...',
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ── LINKS ──────────────────────────────────
                  _sectionLabel('LINKS'),
                  Container(
                    padding: const EdgeInsets.all(18),
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
                        _field(
                          label: 'Portfolio / Website',
                          controller: _websiteCtrl,
                          hint: 'https://yoursite.com',
                          keyboardType: TextInputType.url,
                          prefixIcon: Icons.link_rounded,
                        ),
                        _field(
                          label: 'LinkedIn Profile URL',
                          controller: _linkedinCtrl,
                          hint: 'https://linkedin.com/in/username',
                          keyboardType: TextInputType.url,
                          prefixIcon: Icons.business_center_outlined,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── SAVE BUTTON ───────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
