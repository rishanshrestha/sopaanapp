import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ============================================================
// DESIGN TOKENS
// ============================================================

class _C {
  static const teal = Color(0xFF14B8A6);
  static const tealLight = Color(0xFFE6F7F5);
  static const tealBorder = Color(0xFFA7F3D0);
  static const navy = Color(0xFF0A1F33);
  static const ink = Color(0xFF1F2937);
  static const muted = Color(0xFF6B7280);
  static const faint = Color(0xFF9CA3AF);
  static const line = Color(0xFFE5E7EB);
  static const bg = Color(0xFFF9FAFB);
}

// ============================================================
// SKILLS SECTION COMPONENT
// ============================================================

class SkillsSection extends StatefulWidget {
  final List<String>? skills;
  final VoidCallback? onChanged;

  const SkillsSection({
    super.key,
    this.skills,
    this.onChanged,
  });

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection> {
  final TextEditingController _skillInputController = TextEditingController();
  final List<String> _internalSkills = ['Flutter', 'Dart', 'Firebase', 'UI/UX Design'];

  // Suggested popular skills for fast one-tap adding
  final List<String> _suggestedSkills = [
    'Kotlin',
    'Python',
    'React',
    'Git',
    'REST APIs',
    'SQL',
    'Docker',
    'Figma',
    'Agile',
    'Node.js',
  ];

  List<String> get _skills => widget.skills ?? _internalSkills;

  @override
  void dispose() {
    _skillInputController.dispose();
    super.dispose();
  }

  void _addSkill([String? text]) {
    final raw = (text ?? _skillInputController.text).trim();
    if (raw.isEmpty) return;

    final newSkills = raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);

    setState(() {
      for (final s in newSkills) {
        final exists = _skills.any((e) => e.toLowerCase() == s.toLowerCase());
        if (!exists) {
          _skills.add(s);
        }
      }
      _skillInputController.clear();
    });

    widget.onChanged?.call();
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.removeWhere((s) => s.toLowerCase() == skill.toLowerCase());
    });
    widget.onChanged?.call();
  }

  void _clearAll() {
    setState(() {
      _skills.clear();
    });
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final availableSuggestions = _suggestedSkills
        .where((s) => !_skills.any((e) => e.toLowerCase() == s.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECTION TITLE & COUNTER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _C.tealLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    size: 18,
                    color: _C.teal,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Skills & Expertise',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _C.navy,
                  ),
                ),
              ],
            ),
            if (_skills.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.tealLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.tealBorder),
                ),
                child: Text(
                  '${_skills.length} added',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _C.teal,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // INPUT FIELD & ADD BUTTON
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(Icons.code_rounded, color: _C.faint, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _skillInputController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addSkill(),
                  decoration: const InputDecoration(
                    hintText: 'Add skill (e.g. Kotlin, Docker)',
                    hintStyle: TextStyle(fontSize: 14, color: _C.faint),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  style: const TextStyle(fontSize: 14, color: _C.ink, fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: ElevatedButton.icon(
                  onPressed: () => _addSkill(),
                  icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.teal,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // SUGGESTED QUICK ADD CHIPS
        if (availableSuggestions.isNotEmpty) ...[
          const Text(
            'Suggested for you:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _C.muted,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: availableSuggestions.take(6).map((skill) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ActionChip(
                    avatar: const Icon(Icons.add_circle_outline, size: 15, color: _C.teal),
                    label: Text(
                      skill,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _C.navy,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: _C.line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () => _addSkill(skill),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // SKILLS DISPLAY AREA
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.line),
          ),
          child: _skills.isEmpty
              ? const Column(
                  children: [
                    SizedBox(height: 12),
                    Icon(Icons.style_outlined, size: 36, color: _C.faint),
                    SizedBox(height: 8),
                    Text(
                      'No skills added yet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _C.muted,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Type above or tap a suggestion to add your technical skills.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: _C.faint),
                    ),
                    SizedBox(height: 12),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _C.tealBorder),
                            boxShadow: [
                              BoxShadow(
                                color: _C.teal.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                skill,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _C.navy,
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => _removeSkill(skill),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: _C.tealLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: _C.teal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    if (_skills.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _clearAll,
                          icon: const Icon(Icons.delete_sweep_outlined, size: 16, color: Colors.redAccent),
                          label: const Text(
                            'Clear All',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.redAccent),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

// ============================================================
// SKILLS SECTION SCREEN (Dedicated Add & Manage Skills Screen)
// ============================================================

class SkillsSectionDemoScreen extends StatefulWidget {
  const SkillsSectionDemoScreen({super.key});

  @override
  State<SkillsSectionDemoScreen> createState() => _SkillsSectionDemoScreenState();
}

class _SkillsSectionDemoScreenState extends State<SkillsSectionDemoScreen> {
  List<String> _skills = [];
  bool _loading = true;
  bool _saving = false;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    final doc = _doc;
    if (doc == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final snap = await doc.get();
      if (snap.exists && snap.data() != null) {
        final data = snap.data()!;
        final raw = data['skills'];
        if (raw is List) {
          _skills = raw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
        } else if (raw is String && raw.isNotEmpty) {
          _skills = raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveSkills() async {
    final doc = _doc;
    if (doc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save your skills.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await doc.set({'skills': _skills}, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: _C.teal,
            content: Text('Skills saved successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save skills: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Manage Skills',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: _C.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saving ? null : _saveSkills,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _C.teal))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SkillsSection(
                      skills: _skills,
                      onChanged: () {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveSkills,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.navy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _saving
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : const Text(
                                'Save Skills to Profile',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
