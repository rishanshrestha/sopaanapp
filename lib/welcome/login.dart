import "package:firebase_auth/firebase_auth.dart"
    show FirebaseAuth, FirebaseAuthException, GoogleAuthProvider, OAuthCredential;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

//import 'forgot.dart';
//import 'services/firestore_service.dart';
//import 'signup.dart';
import 'welcome_screen.dart' show SopaanLogo;
//import 'wrapper.dart';

// Backward compatibility alias
typedef Login = LoginScreen;

// ============================================================
// DESIGN TOKENS
// ============================================================

class _C {
  static const teal = Color(0xFF14B8A6);
  static const tealDeep = Color(0xFF0F9488);
  static const green = Color(0xFF22C55E);

  static const navy = Color(0xFF0A1A2F);
  static const ink = Color(0xFF0B1F33);
  static const muted = Color(0xFF667A8C);
  static const faint = Color(0xFF98A2B3);
  static const line = Color(0xFFE3EBF1);
  static const error = Color(0xFFE5484D);

  static const bg = Color(0xFFFFFFFF);
  static const bgTop = Color(0xFFEAF8F5);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, green],
  );
}

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Google Sign-In must only be initialized once per app run.
  static bool _googleInitialized = false;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();

  // State
  bool _loading = false;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  // Intro animation
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _intro.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ==========================================================
  // REVEAL ANIMATION
  // ==========================================================

  Widget _reveal({required double start, required Widget child}) {
    final anim = CurvedAnimation(
      parent: _intro,
      curve: Interval(
        start,
        (start + 0.5).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  // ==========================================================
  // VALIDATION
  // ==========================================================

  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    String? emailError;
    String? passwordError;

    if (email.isEmpty) {
      emailError = 'Enter your email address.';
    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      emailError = 'Enter a valid email, like name@example.com.';
    }

    if (password.isEmpty) {
      passwordError = 'Enter your password.';
    }

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    return emailError == null && passwordError == null;
  }

  // ==========================================================
  // ERROR MESSAGES
  // ==========================================================

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      default:
        return e.message ?? 'Please check your email and password.';
    }
  }

  // ==========================================================
  // EMAIL/PASSWORD LOGIN
  // ==========================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_validate()) return;

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      //await FirestoreService.syncCurrentUser();

      if (!mounted) return;

      //Get.offAll(() => const Wrapper());
    } on FirebaseAuthException catch (e) {
      debugPrint('AUTH ERROR: ${e.code} | ${e.message}');
      _showMessage('${_messageFor(e)} (${e.code})');
    } catch (e, st) {
      debugPrint('UNKNOWN LOGIN ERROR: $e\n$st');
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ==========================================================
  // GOOGLE LOGIN
  // ==========================================================

  Future<void> _googleSignIn() async {
    FocusScope.of(context).unfocus();

    setState(() => _loading = true);

    try {
      if (!_googleInitialized) {
        await GoogleSignIn.instance.initialize(
          // Web Client ID from Firebase Console
          serverClientId:
          '764853879315-25tjidsksmklsc7o9hfe4g42a9epclqk.apps.googleusercontent.com',
        );
        _googleInitialized = true;
      }

      final GoogleSignInAccount googleUser =
      await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      //await FirestoreService.syncCurrentUser();

      if (!mounted) return;

      //Get.offAll(() => const Wrapper());
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      debugPrint('GOOGLE SIGN-IN ERROR: ${e.code} | ${e.description}');
      _showMessage('Google sign-in failed. Please try again.');
    } on FirebaseAuthException catch (e) {
      debugPrint('GOOGLE AUTH ERROR: ${e.code} | ${e.message}');
      _showMessage('${_messageFor(e)} (${e.code})');
    } catch (e, st) {
      debugPrint('GOOGLE UNKNOWN ERROR: $e\n$st');
      _showMessage('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _C.navy,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: Stack(
          children: [
            const Positioned.fill(child: _Background()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              _buildHero(),
                              const SizedBox(height: 28),
                              _buildForm(),
                              const Spacer(),
                              const SizedBox(height: 28),
                              _buildFooter(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // HERO
  // ==========================================================

  Widget _buildHero() {
    return _reveal(
      start: 0.0,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _HaloPainter(centerY: 52)),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: _RoundIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Get.back();
                }
              },
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: _C.teal.withValues(alpha: 0.34),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const SopaanLogo(size: 72, radius: 22),
              ),
              const SizedBox(height: 28),
              const Text(
                'Welcome back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: _C.ink,
                  letterSpacing: -1.1,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Sign in to pick up your career journey where you left it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, height: 1.5, color: _C.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FORM
  // ==========================================================

  Widget _buildForm() {
    return _reveal(
      start: 0.18,
      child: _FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppField(
              label: 'Email',
              hint: 'name@example.com',
              icon: Icons.mail_outline_rounded,
              controller: _emailController,
              errorText: _emailError,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              enabled: !_loading,
              onChanged: (_) {
                if (_emailError != null) setState(() => _emailError = null);
              },
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: 18),
            _AppField(
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              controller: _passwordController,
              focusNode: _passwordFocus,
              errorText: _passwordError,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              enabled: !_loading,
              onChanged: (_) {
                if (_passwordError != null) {
                  setState(() => _passwordError = null);
                }
              },
              onSubmitted: (_) {
                if (!_loading) _login();
              },
              suffix: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: _loading
                    ? null
                    : () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 21,
                  color: _C.faint,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _loading
                    ? null
                    : () {
                  // Get.to(() => const Forgot());
                },
                style: TextButton.styleFrom(
                  foregroundColor: _C.tealDeep,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: const Size(0, 44),
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _PrimaryButton(
              label: 'Sign in',
              loading: _loading,
              onPressed: _loading ? null : _login,
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(child: Divider(color: _C.line, height: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'or',
                    style: TextStyle(
                      color: _C.faint,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: _C.line, height: 1)),
              ],
            ),
            const SizedBox(height: 24),
            _GoogleButton(onPressed: _loading ? null : _googleSignIn),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // FOOTER
  // ==========================================================

  Widget _buildFooter() {
    return _reveal(
      start: 0.35,
      child: Column(
        children: [
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(color: _C.muted, fontSize: 14),
                ),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                    // Get.to(() => const Signup());
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _C.tealDeep,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: const Size(0, 44),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Create account',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 13, color: _C.faint),
              SizedBox(width: 6),
              Text(
                'Your sign-in is encrypted',
                style: TextStyle(color: _C.faint, fontSize: 12.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ROUND ICON BUTTON
// ============================================================

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        elevation: 0,
        shape: const CircleBorder(side: BorderSide(color: _C.line)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 21, color: _C.ink),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// APP FIELD
// ============================================================

class _AppField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

  const _AppField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.focusNode,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.suffix,
  });

  @override
  State<_AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<_AppField> {
  FocusNode? _ownFocus;

  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _ownFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final focused = _focus.hasFocus;

    final borderColor = hasError
        ? _C.error
        : focused
        ? _C.teal
        : _C.line;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: hasError ? _C.error : _C.ink,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: focused ? 1.8 : 1.3),
            boxShadow: [
              BoxShadow(
                color: (hasError ? _C.error : _C.teal)
                    .withValues(alpha: focused ? 0.16 : 0.0),
                blurRadius: 0,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: _C.navy.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: hasError
                      ? _C.error
                      : focused
                      ? _C.teal
                      : _C.faint,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  autofillHints: widget.autofillHints,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  cursorColor: _C.teal,
                  style: const TextStyle(color: _C.ink, fontSize: 15.5),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: const TextStyle(color: _C.faint, fontSize: 15),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
              if (widget.suffix != null) widget.suffix!,
              if (widget.suffix == null) const SizedBox(width: 16),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: hasError
              ? Padding(
            padding: const EdgeInsets.only(left: 4, top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 15,
                    color: _C.error,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: const TextStyle(
                      color: _C.error,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

// ============================================================
// PRIMARY BUTTON
// ============================================================

class _PrimaryButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return AnimatedScale(
      scale: _pressed && enabled ? 0.98 : 1,
      duration: const Duration(milliseconds: 110),
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: _C.gradient,
          boxShadow: [
            BoxShadow(
              color: _C.teal.withValues(alpha: enabled ? 0.34 : 0.14),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.onPressed,
            onHighlightChanged: (value) {
              if (mounted) setState(() => _pressed = value);
            },
            child: Center(
              child: widget.loading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: _C.navy,
                ),
              )
                  : Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: _C.navy,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// GOOGLE BUTTON
// ============================================================

class _GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _GoogleButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _C.ink,
          side: const BorderSide(color: _C.line, width: 1.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 22, height: 22, child: _GoogleG()),
            SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// GOOGLE G
// ============================================================

class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GoogleGPainter());
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.2;

    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    Paint arc(Color color) {
      return Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
    }

    const rad = 3.141592653589793 / 180;

    canvas.drawArc(rect, 20 * rad, 70 * rad, false, arc(const Color(0xFF34A853)));
    canvas.drawArc(rect, 90 * rad, 90 * rad, false, arc(const Color(0xFFFBBC05)));
    canvas.drawArc(rect, 180 * rad, 90 * rad, false, arc(const Color(0xFFEA4335)));
    canvas.drawArc(rect, 270 * rad, 75 * rad, false, arc(const Color(0xFF4285F4)));

    final bar = Paint()..color = const Color(0xFF4285F4);

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.5,
        size.height * 0.5 - stroke / 2,
        size.width * 0.5,
        stroke,
      ),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// BACKGROUND
// ============================================================

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5],
          colors: [_C.bgTop, _C.bg],
        ),
      ),
    );
  }
}

// ============================================================
// HALO
// ============================================================

class _HaloPainter extends CustomPainter {
  final double centerY;

  const _HaloPainter({required this.centerY});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, centerY);

    for (var i = 1; i <= 4; i++) {
      final radius = 36.0 + i * 38;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = _C.teal.withValues(alpha: 0.20 - i * 0.04),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HaloPainter old) => old.centerY != centerY;
}

// ============================================================
// FORM CARD
// ============================================================

class _FormCard extends StatelessWidget {
  final Widget child;

  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _C.line),
        boxShadow: [
          BoxShadow(
            color: _C.navy.withValues(alpha: 0.07),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}