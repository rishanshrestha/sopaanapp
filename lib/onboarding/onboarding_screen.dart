import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../welcome/welcome_screen.dart';

// ============================================================
// DESIGN TOKENS
// ============================================================

class _C {
  static const teal = Color(0xFF14B8A6);
  static const green = Color(0xFF22C55E);
  static const navy = Color(0xFF0A1A2F);
  static const amber = Color(0xFFF5A524);

  static const bg = Color(0xFFFFFFFF);
  static const bgTop = Color(0xFFF4F9FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceHi = Color(0xFFF1F6F9);

  static const ink = Color(0xFF0B1F33);
  static const body = Color(0xFF1F3347);
  static const muted = Color(0xFF667A8C);
  static const line = Color(0xFFE3EBF1);
  static const track = Color(0xFFD3DEE7);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, green],
  );
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onFinished;

  const OnboardingScreen({
    super.key,
    this.onFinished,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;

  final PageController pageController = PageController();

  /// User selections for each page (indexes of selected items).
  final Map<OnboardingType, Set<int>> selected = {
    for (final type in OnboardingType.values) type: <int>{},
  };

  final List<OnboardingData> pages = [
    OnboardingData(
      icon: Icons.bolt_rounded,
      title: 'Your skills can take\nyou further.',
      description:
          'Discover how your abilities map to real career opportunities across Nepal and beyond.',
      type: OnboardingType.skills,
    ),
    OnboardingData(
      icon: Icons.auto_awesome_rounded,
      title: 'Let AI understand\nwhat you can do.',
      description:
          'Our AI builds a comprehensive picture of your abilities from your education, projects and experience.',
      type: OnboardingType.profile,
    ),
    OnboardingData(
      icon: Icons.track_changes_rounded,
      title: 'Discover opportunities\nmade for you.',
      description:
          'Find jobs, internships and freelance work matched specifically to your current skill level.',
      type: OnboardingType.opportunities,
    ),
    OnboardingData(
      icon: Icons.menu_book_rounded,
      title: 'Know what to\nlearn next.',
      description:
          "Sopaan's AI identifies your skill gaps and recommends the exact learning you need to advance.",
      type: OnboardingType.learning,
    ),
    OnboardingData(
      icon: Icons.rocket_launch_rounded,
      title: 'Build your career\nwith AI.',
      description:
          'CV analysis, mock interviews, application tracking — everything you need in one intelligent platform.',
      type: OnboardingType.finalPage,
    ),
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  bool _isSelected(OnboardingType type, int index) =>
      selected[type]!.contains(index);

  void _toggle(OnboardingType type, int index) {
    HapticFeedback.selectionClick();
    setState(() {
      final set = selected[type]!;
      if (!set.remove(index)) {
        set.add(index);
      }
    });
  }

  void nextPage() {
    if (currentPage < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } else {
      finishOnboarding();
    }
  }

  void skipOnboarding() {
    finishOnboarding();
  }

  void finishOnboarding() {
    if (!mounted) return;

    if (widget.onFinished != null) {
      widget.onFinished!();
    } else {
      Get.off(() => const WelcomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = currentPage == pages.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: Stack(
          children: [
            // Background gradient + soft colour glows
            const Positioned.fill(child: _Background()),

            SafeArea(
              child: Column(
                children: [
                  // Skip button (hidden on last page, space kept so layout is stable)
                  SizedBox(
                    height: 48,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20, top: 4),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isLast ? 0 : 1,
                          child: IgnorePointer(
                            ignoring: isLast,
                            child: TextButton(
                              onPressed: skipOnboarding,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  side: const BorderSide(color: _C.line),
                                ),
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  color: _C.muted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Pages
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: pages.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _buildPage(pages[index], index);
                      },
                    ),
                  ),

                  // Bottom navigation
                  _buildBottomNavigation(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data, int index) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon badge
            _IconBadge(
              key: ValueKey('badge_$index'),
              icon: data.icon,
              accent: index.isEven ? _C.teal : _C.green,
            ),

            const SizedBox(height: 26),

            // Title
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 27,
                height: 1.25,
                fontWeight: FontWeight.w800,
                color: _C.ink,
                letterSpacing: -0.6,
              ),
            ),

            const SizedBox(height: 10),

            // Description
            Text(
              data.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.6,
                color: _C.muted,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 22),

            // Selection hint
            _SelectHint(
              text: _hintFor(data.type),
              count: selected[data.type]!.length,
            ),

            const SizedBox(height: 14),

            // Visual (selectable)
            _buildVisual(data),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _hintFor(OnboardingType type) {
    switch (type) {
      case OnboardingType.skills:
        return 'Tap the skills you have';
      case OnboardingType.profile:
        return 'Tap what AI should look at';
      case OnboardingType.opportunities:
        return "Tap what you're looking for";
      case OnboardingType.learning:
        return 'Tap your learning focus';
      case OnboardingType.finalPage:
        return 'Tap the tools you want first';
    }
  }

  Widget _buildVisual(OnboardingData data) {
    switch (data.type) {
      case OnboardingType.skills:
        return _skillsCard();

      case OnboardingType.profile:
        return _profileCards();

      case OnboardingType.opportunities:
        return _opportunityCards();

      case OnboardingType.learning:
        return _learningCard();

      case OnboardingType.finalPage:
        return _finalFeatures();
    }
  }

  // ============================================================
  // SKILLS
  // ============================================================

  Widget _skillsCard() {
    final skills = [
      {'name': 'Python', 'percentage': 88, 'color': _C.teal},
      {'name': 'Flask', 'percentage': 76, 'color': _C.green},
      {'name': 'MySQL', 'percentage': 72, 'color': _C.teal},
    ];

    return Column(
      children: skills.asMap().entries.map((entry) {
        final int index = entry.key;
        final skill = entry.value;
        final bool last = index == skills.length - 1;
        final int percentage = skill['percentage'] as int;
        final Color color = skill['color'] as Color;
        final bool isSel = _isSelected(OnboardingType.skills, index);

        return Padding(
          padding: EdgeInsets.only(bottom: last ? 0 : 10),
          child: _Selectable(
            selected: isSel,
            color: color,
            radius: 16,
            showBadge: false,
            padding: const EdgeInsets.all(14),
            onTap: () => _toggle(OnboardingType.skills, index),
            child: Row(
              children: [
                _CheckDot(selected: isSel, color: color, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            skill['name'] as String,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: _C.body,
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: percentage / 100),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 7,
                              backgroundColor: _C.track,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // AI PROFILE
  // ============================================================

  Widget _profileCards() {
    final cards = [
      {'title': 'Skills', 'emoji': '⚡', 'color': _C.teal},
      {'title': 'Education', 'emoji': '🎓', 'color': _C.green},
      {'title': 'Projects', 'emoji': '💻', 'color': _C.teal},
      {'title': 'Experience', 'emoji': '🏢', 'color': _C.green},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        final Color color = card['color'] as Color;
        final bool isSel = _isSelected(OnboardingType.profile, index);

        return _Selectable(
          selected: isSel,
          color: color,
          radius: 18,
          onTap: () => _toggle(OnboardingType.profile, index),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.14),
                  ),
                  child: Text(
                    card['emoji'] as String,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  card['title'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSel ? _C.ink : _C.body,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // OPPORTUNITIES
  // ============================================================

  Widget _opportunityCards() {
    final opportunities = [
      {'title': 'Jobs', 'emoji': '💼', 'color': _C.teal},
      {'title': 'Internships', 'emoji': '🎓', 'color': _C.green},
      {'title': 'Freelance', 'emoji': '⚡', 'color': _C.amber},
    ];

    return Row(
      children: opportunities.asMap().entries.map((entry) {
        final int index = entry.key;
        final item = entry.value;
        final Color color = item['color'] as Color;
        final bool isSel = _isSelected(OnboardingType.opportunities, index);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _Selectable(
              selected: isSel,
              color: color,
              radius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
              onTap: () => _toggle(OnboardingType.opportunities, index),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.14),
                      ),
                      child: Text(
                        item['emoji'] as String,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // LEARNING
  // ============================================================

  Widget _learningCard() {
    final items = [
      'Skill Gaps',
      'Learning Paths',
      'Career Roadmap',
    ];

    return Column(
      children: items.asMap().entries.map((entry) {
        final int index = entry.key;
        final String title = entry.value;
        final bool last = index == items.length - 1;
        final bool isSel = _isSelected(OnboardingType.learning, index);

        return Padding(
          padding: EdgeInsets.only(bottom: last ? 0 : 10),
          child: _Selectable(
            selected: isSel,
            color: _C.teal,
            radius: 16,
            showBadge: false,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onTap: () => _toggle(OnboardingType.learning, index),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _C.gradient,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: isSel ? _C.ink : _C.body,
                    ),
                  ),
                ),
                _CheckDot(selected: isSel, color: _C.teal, size: 22),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // FINAL FEATURES
  // ============================================================

  Widget _finalFeatures() {
    final features = [
      'CV AI',
      'Interview',
      'Tracker',
      'Roadmap',
      'Jobs',
      'Learning',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final bool isSel = _isSelected(OnboardingType.finalPage, index);
        final Color color = index.isEven ? _C.teal : _C.green;

        return _Selectable(
          selected: isSel,
          color: color,
          radius: 14,
          badgeSize: 16,
          onTap: () => _toggle(OnboardingType.finalPage, index),
          child: Center(
            child: Text(
              features[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isSel ? _C.ink : _C.muted,
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    final bool isLast = currentPage == pages.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 30),
      child: Column(
        children: [
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) {
                final bool active = index == currentPage;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 26 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: active ? null : _C.track,
                    gradient: active
                        ? const LinearGradient(colors: [_C.teal, _C.green])
                        : null,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 22),

          // Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isLast ? null : _C.surfaceHi,
              gradient: isLast
                  ? const LinearGradient(colors: [_C.teal, _C.green])
                  : null,
              border: Border.all(
                color: isLast ? Colors.transparent : _C.teal.withValues(alpha: 0.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isLast ? _C.teal : Colors.black)
                      .withValues(alpha: isLast ? 0.35 : 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: nextPage,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: isLast ? _C.navy : _C.ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLast ? 'Get Started' : 'Continue',
                    style: TextStyle(
                      fontSize: isLast ? 16 : 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLast
                        ? Icons.arrow_forward_rounded
                        : Icons.chevron_right_rounded,
                    size: isLast ? 18 : 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SELECTABLE WRAPPER
// ============================================================

class _Selectable extends StatelessWidget {
  final bool selected;
  final Color color;
  final double radius;
  final EdgeInsetsGeometry padding;
  final VoidCallback onTap;
  final Widget child;
  final bool showBadge;
  final double badgeSize;

  const _Selectable({
    required this.selected,
    required this.color,
    required this.onTap,
    required this.child,
    this.radius = 16,
    this.padding = EdgeInsets.zero,
    this.showBadge = true,
    this.badgeSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : _C.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: selected ? color : _C.line,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? color.withValues(alpha: 0.22)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: selected ? 18 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(padding: padding, child: child),
            if (showBadge)
              Positioned(
                top: 8,
                right: 8,
                child: _CheckDot(
                  selected: selected,
                  color: color,
                  size: badgeSize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CHECK DOT
// ============================================================

class _CheckDot extends StatelessWidget {
  final bool selected;
  final Color color;
  final double size;

  const _CheckDot({
    required this.selected,
    required this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? color : Colors.transparent,
        border: Border.all(
          color: selected ? color : _C.track,
          width: 1.5,
        ),
      ),
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: Icon(
          Icons.check_rounded,
          size: size * 0.66,
          color: _C.navy,
        ),
      ),
    );
  }
}

// ============================================================
// SELECT HINT
// ============================================================

class _SelectHint extends StatelessWidget {
  final String text;
  final int count;

  const _SelectHint({required this.text, required this.count});

  @override
  Widget build(BuildContext context) {
    final bool has = count > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: has
            ? _C.teal.withValues(alpha: 0.14)
            : _C.surface,
        border: Border.all(
          color: has ? _C.teal.withValues(alpha: 0.5) : _C.line,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            has ? Icons.check_circle_rounded : Icons.touch_app_rounded,
            size: 15,
            color: has ? _C.teal : _C.muted,
          ),
          const SizedBox(width: 7),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              has ? '$count selected' : text,
              key: ValueKey(has ? 'count_$count' : 'hint'),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: has ? _C.teal : _C.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BACKGROUND
// ============================================================

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_C.bgTop, _C.bg],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _Glow(color: _C.teal.withValues(alpha: 0.14), size: 280),
          ),
          Positioned(
            bottom: -110,
            left: -80,
            child: _Glow(color: _C.green.withValues(alpha: 0.10), size: 300),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ICON BADGE
// ============================================================

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color accent;

  const _IconBadge({
    super.key,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1.0),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Opacity(
          opacity: scale.clamp(0.0, 1.0),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Container(
        width: 100,
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withValues(alpha: 0.10),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: _C.gradient,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.45),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(icon, color: _C.navy, size: 36),
        ),
      ),
    );
  }
}

// ============================================================
// ONBOARDING TYPE
// ============================================================

enum OnboardingType {
  skills,
  profile,
  opportunities,
  learning,
  finalPage,
}

// ============================================================
// ONBOARDING DATA
// ============================================================

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final OnboardingType type;

  const OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.type,
  });
}
