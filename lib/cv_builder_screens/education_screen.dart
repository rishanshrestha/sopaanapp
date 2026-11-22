import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  static const String _key = 'educationItems';
  static const List<String> _labels = ['Degree / Course', 'University / Institution', 'Graduation Year', 'GPA / Grade'];

  late final List<TextEditingController> _c =
  List.generate(_labels.length, (_) => TextEditingController());
  bool _saving = false;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  @override
  void dispose() {
    for (final c in _c) {
      c.dispose();
    }
    super.dispose();
  }

  String _format() {
    final degree = _c[0].text.trim();
    final inst = _c[1].text.trim();
    final year = _c[2].text.trim();
    final gpa = _c[3].text.trim();
    if (degree.isEmpty && inst.isEmpty) return '';
    var s = [degree, inst].where((e) => e.isNotEmpty).join(' — ');
    if (year.isNotEmpty) s += ' ($year)';
    if (gpa.isNotEmpty) s += ' · $gpa';
    return s;
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _add() async {
    final entry = _format();
    if (entry.isEmpty) {
      _snack('Please fill in the required fields.');
      return;
    }
    final doc = _doc;
    if (doc == null) {
      _snack('Please log in first.');
      return;
    }
    setState(() => _saving = true);
    try {
      await doc.set({
        _key: FieldValue.arrayUnion([entry])
      }, SetOptions(merge: true));
      for (final c in _c) {
        c.clear();
      }
      if (mounted) _snack('Added!');
    } catch (e) {
      if (mounted) _snack('Could not save: $e');
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _remove(String item) async {
    try {
      await _doc?.set({
        _key: FieldValue.arrayRemove([item])
      }, SetOptions(merge: true));
    } catch (e) {
      if (mounted) _snack('Could not remove: $e');
    }
  }

  Widget _field(int i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_labels[i],
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
          const SizedBox(height: 6),
          TextField(
            controller: _c[i],
            style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                const BorderSide(color: Color(0xFF16B8A6), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Education',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0B1220))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add form
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0F2F5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add new',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B1220))),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  for (int i = 0; i < _labels.length; i++) _field(i),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _add,
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
                          : const Text('Add',
                          style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Your saved entries',
                style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B1220))),
            const SizedBox(height: 10),
            // Saved list
            if (_doc == null)
              const Text('Log in to see your entries.')
            else
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _doc!.snapshots(),
                builder: (context, snap) {
                  final raw = snap.data?.data()?[_key];
                  final items = raw is List
                      ? raw.map((e) => e.toString()).toList()
                      : <String>[];
                  if (items.isEmpty) {
                    return const Text('Nothing added yet.',
                        style: TextStyle(color: Color(0xFF667085)));
                  }
                  return Column(
                    children: items.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(item,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF111827))),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 20, color: Color(0xFF9CA3AF)),
                              onPressed: () => _remove(item),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}