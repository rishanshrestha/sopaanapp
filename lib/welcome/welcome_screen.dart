import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../components/primary_button.dart';
import '../components/secondary_button.dart';
import 'login.dart';
import 'signup.dart';

// ============================================================
// DESIGN TOKENS
// ============================================================

class _C {
  static const teal = Color(0xFF14B8A6);
  static const green = Color(0xFF22C55E);
  static const indigo = Color(0xFF5B6CFF);
  static const amber = Color(0xFFF79009);

  static const navy = Color(0xFF0A1A2F);
  static const ink = Color(0xFF0B1F33);
  static const muted = Color(0xFF667A8C);
  static const faint = Color(0xFF98A2B3);
  static const line = Color(0xFFE3EBF1);
  static const track = Color(0xFFE6EDF2);

  static const bg = Color(0xFFFFFFFF);
  static const bgTop = Color(0xFFF4F9FB);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, green],
  );
}

// ============================================================
// WELCOME SCREEN
// ============================================================

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..forward();

  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _intro.dispose();
    _float.dispose();
    super.dispose();
  }

  // Fade and slide entrance animation
  Widget _reveal({
    required double start,
    required Widget child,
  }) {
    final anim = CurvedAnimation(
      parent: _intro,
      curve: Interval(
        start,
        start + 0.4,
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: Stack(
          children: [
            const Positioned.fill(
              child: _Background(),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    28,
                    24,
                    28,
                    30,
                  ),
                  child: Column(
                    children: [
                      // TOP BRAND
                      _reveal(
                        start: 0.0,
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: _BrandLockup(),
                        ),
                      ),

                      const SizedBox(height: 44),

                      // MAIN ILLUSTRATION
                      _reveal(
                        start: 0.1,
                        child: _buildHeroIllustration(),
                      ),

                      const SizedBox(height: 38),

                      // TITLE
                      _reveal(
                        start: 0.25,
                        child: const Text(
                          'Your career.\nYour next step.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            height: 1.18,
                            fontWeight: FontWeight.w800,
                            color: _C.ink,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // DESCRIPTION
                      _reveal(
                        start: 0.3,
                        child: const Text(
                          'Sopaan uses AI to understand your skills, '
                          'discover opportunities and help you build '
                          'the career you want.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: _C.muted,
                          ),
                        ),
                      ),

                      const SizedBox(height: 34),

                      // BUTTONS
                      _reveal(
                        start: 0.4,
                        child: Column(
                          children: [
                            PrimaryButton(
                              label: 'Create an account',
                              onTap: () {
                                Get.to(() => const Signup());
                              },
                            ),

                            const SizedBox(height: 14),

                            SecondaryButton(
                              label: 'I already have an account',
                              onTap: () {
                                Get.to(() => const Login());
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 26),

                      // FOOTER
                      _reveal(
                        start: 0.5,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 13,
                              color: _C.teal,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'AI-powered career guidance',
                              style: TextStyle(
                                fontSize: 12,
                                color: _C.faint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO ILLUSTRATION
  // ============================================================

  Widget _buildHeroIllustration() {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _C.teal.withValues(alpha: 0.16),
                  _C.indigo.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Soft ring
          Container(
            width: 232,
            height: 232,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _C.teal.withValues(alpha: 0.12),
                width: 1.2,
              ),
            ),
          ),

          // Main career card
          Container(
            width: 215,
            height: 180,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _C.line),
              boxShadow: [
                BoxShadow(
                  color: _C.teal.withValues(alpha: 0.14),
                  blurRadius: 36,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card header
                const Row(
                  children: [
                    SopaanLogo(
                      size: 35,
                      radius: 11,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sopaan AI',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _C.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Career insight',
                          style: TextStyle(
                            fontSize: 9,
                            color: _C.faint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Career match label
                const Text(
                  'Your career match',
                  style: TextStyle(
                    fontSize: 10,
                    color: _C.muted,
                  ),
                ),

                const SizedBox(height: 7),

                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0,
                            end: 0.87,
                          ),
                          duration: const Duration(
                            milliseconds: 1200,
                          ),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 8,
                              backgroundColor: _C.track,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                _C.teal,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '87%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _C.teal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Tags
                Row(
                  children: [
                    _miniTag('Skills', _C.teal),
                    const SizedBox(width: 5),
                    _miniTag('AI', _C.indigo),
                    const SizedBox(width: 5),
                    _miniTag('Jobs', _C.amber),
                  ],
                ),
              ],
            ),
          ),

          // Floating AI badge
          Positioned(
            top: 22,
            right: 14,
            child: _floatingBadge(
              icon: Icons.auto_awesome,
              color: _C.indigo,
              direction: 1,
            ),
          ),

          // Floating career badge
          Positioned(
            bottom: 28,
            left: 8,
            child: _floatingBadge(
              icon: Icons.work_outline_rounded,
              color: _C.teal,
              direction: -1,
            ),
          ),

          // Floating learning badge
          Positioned(
            bottom: 8,
            right: 30,
            child: _floatingBadge(
              icon: Icons.school_outlined,
              color: _C.amber,
              direction: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MINI TAG
  // ============================================================

  Widget _miniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // FLOATING BADGE
  // ============================================================

  Widget _floatingBadge({
    required IconData icon,
    required Color color,
    required int direction,
  }) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(
          _float.value,
        );

        final dy = (t - 0.5) * 10 * direction;

        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _C.line),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.20),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 19,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SOPAAN LOGO - IMAGE ASSET
// ============================================================

class SopaanLogo extends StatelessWidget {
  final double size;
  final double radius;

  const SopaanLogo({
    super.key,
    this.size = 42,
    this.radius = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: _C.teal.withValues(alpha: 0.25),
            blurRadius: size * 0.4,
            offset: Offset(0, size * 0.16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          'assets/images/logo.jpeg',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: _C.gradient,
              ),
              child: Icon(
                Icons.trending_up_rounded,
                color: Colors.white,
                size: size * 0.5,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// BRAND LOCKUP
// ============================================================

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SopaanLogo(
          size: 42,
          radius: 13,
        ),
        SizedBox(width: 11),
        Text(
          'Sopaan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _C.ink,
            letterSpacing: -0.5,
          ),
        ),
      ],
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
          colors: [
            _C.bgTop,
            _C.bg,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _Glow(
              color: _C.teal.withValues(alpha: 0.14),
              size: 280,
            ),
          ),
          Positioned(
            bottom: -110,
            left: -80,
            child: _Glow(
              color: _C.green.withValues(alpha: 0.10),
              size: 300,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// GLOW EFFECT
// ============================================================

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
