import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../onboarding/onboarding_screen.dart';

// ============================================================================
// DESIGN TOKENS
// ============================================================================

class _C {
  static const teal = Color(0xFF16B8A6);
  static const indigo = Color(0xFF5B6CFF);
  static const ink = Color(0xFF0B1220);
  static const muted = Color(0xFF667085);
  static const track = Color(0xFFE5E7EB);
  static const bgTop = Color(0xFFF4F7FC);
  static const bgBottom = Colors.white;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double _progress = 0.0;
  Timer? _timer;

  late final AnimationController _entrance; // one-time staged reveal
  late final AnimationController _pulse; // AI node breathing + halo
  late final AnimationController _travel; // dot moving along the path

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _travel = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _startProgress();
  }

  // ==========================================================================
  // SPLASH PROGRESS (same behavior: fill bar, then go to onboarding)
  // ==========================================================================

  void _startProgress() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _progress += 0.015;

        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();

          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            Get.off(() => const OnboardingScreen());
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entrance.dispose();
    _pulse.dispose();
    _travel.dispose();
    super.dispose();
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bgBottom,
      body: Stack(
        children: [
          // Soft background: gradient + two blurred colour glows
          const Positioned.fill(child: _Background()),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final double height = constraints.maxHeight;

                final double hPad = (width * 0.08).clamp(24.0, 40.0);
                final bool compact = height < 650;
                final bool tiny = height < 560;

                final double pathWidth = (width * 0.78).clamp(210.0, 300.0);
                final double pathHeight = compact ? 120.0 : 150.0;
                final double logoSize = compact ? 60.0 : 72.0;
                final double titleSize = width < 350 ? 34.0 : 40.0;

                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: hPad,
                            vertical: tiny ? 10 : 20,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ----------------------------------------------
                              // SKILLS -> AI -> CAREER
                              // ----------------------------------------------
                              _JourneyPath(
                                width: pathWidth,
                                height: pathHeight,
                                entrance: _entrance,
                                pulse: _pulse,
                                travel: _travel,
                              ),

                              SizedBox(height: tiny ? 14 : 34),

                              // ----------------------------------------------
                              // LOGO
                              // ----------------------------------------------
                              _Reveal(
                                controller: _entrance,
                                begin: 0.45,
                                end: 0.80,
                                child: _Logo(size: logoSize),
                              ),

                              SizedBox(height: compact ? 14 : 22),

                              // ----------------------------------------------
                              // TITLE
                              // ----------------------------------------------
                              _Reveal(
                                controller: _entrance,
                                begin: 0.55,
                                end: 0.88,
                                child: Text(
                                  'Sopaan',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w800,
                                    color: _C.ink,
                                    letterSpacing: -1.0,
                                    height: 1.1,
                                  ),
                                ),
                              ),

                              SizedBox(height: compact ? 8 : 10),

                              // ----------------------------------------------
                              // SUBTITLE (pill)
                              // ----------------------------------------------
                              _Reveal(
                                controller: _entrance,
                                begin: 0.62,
                                end: 0.94,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _C.teal.withValues(alpha: 0.09),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: _C.teal.withValues(alpha: 0.23),
                                    ),
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'NEPAL SKILLS-TO-JOBS AI',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0E8F81),
                                        letterSpacing: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: compact ? 14 : 20),

                              // ----------------------------------------------
                              // TAGLINE
                              // ----------------------------------------------
                              _Reveal(
                                controller: _entrance,
                                begin: 0.70,
                                end: 1.0,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'Turn your skills into your career.',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _C.muted,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ========================================================
                    // PROGRESS BAR
                    // ========================================================
                    Padding(
                      padding: EdgeInsets.only(
                        left: hPad + 24,
                        right: hPad + 24,
                        bottom: compact ? 24 : 52,
                      ),
                      child: _ProgressBar(progress: _progress),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BACKGROUND
// ============================================================================

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_C.bgTop, _C.bgBottom],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _Glow(color: _C.indigo.withValues(alpha: 0.13), size: 260),
          ),
          Positioned(
            bottom: -110,
            left: -80,
            child: _Glow(color: _C.teal.withValues(alpha: 0.13), size: 280),
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

// ============================================================================
// STAGED REVEAL (fade + small rise)
// ============================================================================

class _Reveal extends StatelessWidget {
  final AnimationController controller;
  final double begin;
  final double end;
  final Widget child;

  const _Reveal({
    required this.controller,
    required this.begin,
    required this.end,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curve = Interval(begin, end, curve: Curves.easeOutCubic);

    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final t = curve.transform(controller.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 14),
            child: child,
          ),
        );
      },
    );
  }
}

// ============================================================================
// LOGO
// ============================================================================

class _Logo extends StatelessWidget {
  final double size;

  const _Logo({required this.size});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.30);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _C.indigo.withValues(alpha: 0.23),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: _C.teal.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(-4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          'assets/images/logo.jpeg',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_C.teal, _C.indigo],
                ),
              ),
              child: Center(
                child: Text(
                  'S',
                  style: TextStyle(
                    fontSize: size * 0.44,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// PROGRESS BAR
// ============================================================================

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      child: LayoutBuilder(
        builder: (context, c) {
          final double fillWidth = c.maxWidth * progress;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Track
              Container(
                decoration: BoxDecoration(
                  color: _C.track,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              // Fill
              Container(
                width: fillWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: const LinearGradient(colors: [_C.teal, _C.indigo]),
                  boxShadow: [
                    BoxShadow(
                      color: _C.indigo.withValues(alpha: 0.27),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// JOURNEY PATH  (Skills -> AI -> Career)
// ============================================================================

class _JourneyPath extends StatelessWidget {
  final double width;
  final double height;
  final AnimationController entrance;
  final AnimationController pulse;
  final AnimationController travel;

  const _JourneyPath({
    required this.width,
    required this.height,
    required this.entrance,
    required this.pulse,
    required this.travel,
  });

  @override
  Widget build(BuildContext context) {
    // Shared anchor points so the path and the nodes always line up.
    final double cy = height * 0.40;
    final double leftX = width * 0.16;
    final double midX = width * 0.50;
    final double rightX = width * 0.84;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dashed path + travelling light
          Positioned.fill(
            child: _Reveal(
              controller: entrance,
              begin: 0.15,
              end: 0.55,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _PathPainter(
                    travel: travel,
                    cy: cy,
                    leftX: leftX,
                    midX: midX,
                    rightX: rightX,
                  ),
                ),
              ),
            ),
          ),

          // Skills
          Positioned(
            left: leftX - 35,
            top: cy - 28,
            child: _Reveal(
              controller: entrance,
              begin: 0.0,
              end: 0.40,
              child: const _Node(
                icon: Icons.bolt_rounded,
                label: 'Skills',
                color: _C.teal,
              ),
            ),
          ),

          // AI
          Positioned(
            left: midX - 36,
            top: cy - 36,
            child: _Reveal(
              controller: entrance,
              begin: 0.15,
              end: 0.55,
              child: _AINode(pulse: pulse),
            ),
          ),

          // Career
          Positioned(
            left: rightX - 35,
            top: cy - 28,
            child: _Reveal(
              controller: entrance,
              begin: 0.30,
              end: 0.70,
              child: const _Node(
                icon: Icons.rocket_launch_rounded,
                label: 'Career',
                color: _C.indigo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SKILLS / CAREER NODE
// ============================================================================

class _Node extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Node({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: color.withValues(alpha: 0.78), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// AI NODE  (breathing + expanding halo ring)
// ============================================================================

class _AINode extends StatelessWidget {
  final AnimationController pulse;

  const _AINode({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, _) {
                final double t = pulse.value;

                // Breathing scale: smooth 0.94 -> 1.06 -> 0.94
                final double breathe =
                    1.0 + 0.06 * math.sin(t * 2 * math.pi);

                // Halo: expands and fades out once per cycle
                final double haloScale = 1.0 + t * 0.55;
                final double haloOpacity = (1.0 - t) * 0.35;

                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Transform.scale(
                      scale: haloScale,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _C.indigo.withValues(alpha: haloOpacity),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: breathe,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_C.teal, _C.indigo],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x665B6CFF),
                              blurRadius: 26,
                              spreadRadius: 1,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'AI',
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _C.indigo,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CONNECTING PATH + TRAVELLING LIGHT
// ============================================================================

class _PathPainter extends CustomPainter {
  final Animation<double> travel;
  final double cy;
  final double leftX;
  final double midX;
  final double rightX;

  _PathPainter({
    required this.travel,
    required this.cy,
    required this.leftX,
    required this.midX,
    required this.rightX,
  }) : super(repaint: travel);

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(leftX, cy)
      ..quadraticBezierTo(
        (leftX + midX) / 2,
        cy - size.height * 0.28,
        midX,
        cy,
      )
      ..quadraticBezierTo(
        (midX + rightX) / 2,
        cy + size.height * 0.28,
        rightX,
        cy,
      );

    final Paint dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0x9916B8A6), Color(0x995B6CFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    const double dash = 5;
    const double gap = 5;

    final metrics = path.computeMetrics().toList();

    // Dashed line
    for (final metric in metrics) {
      double d = 0;
      while (d < metric.length) {
        final double end = math.min(d + dash, metric.length);
        canvas.drawPath(metric.extractPath(d, end), dashPaint);
        d += dash + gap;
      }
    }

    // Travelling light: shows the Skills -> AI -> Career direction
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      final double pos = metric.length * Curves.easeInOut.transform(travel.value);
      final tangent = metric.getTangentForOffset(pos);

      if (tangent != null) {
        // Fade in/out at both ends so it never pops
        final double edge = math.min(travel.value, 1 - travel.value) * 6;
        final double alpha = edge.clamp(0.0, 1.0);

        final Color dotColor = Color.lerp(_C.teal, _C.indigo, travel.value)!;

        canvas.drawCircle(
          tangent.position,
          9,
          Paint()
            ..color = dotColor.withValues(alpha: 0.27 * alpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
        canvas.drawCircle(
          tangent.position,
          3.5,
          Paint()..color = dotColor.withValues(alpha: alpha),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) =>
      old.cy != cy ||
      old.leftX != leftX ||
      old.midX != midX ||
      old.rightX != rightX;
}
