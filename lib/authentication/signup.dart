import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'login.dart';
import '../welcome/welcome_screen.dart' show SopaanLogo;
import 'services/firestore_service.dart';
import 'wrapper.dart';

// Backward compatibility alias
typedef Signup = RegisterScreen;

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
// REGISTER SCREEN
// ============================================================

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _loading = false;
  bool _obscure = true;

  String? _nameErr;
  String? _emailErr;
  String? _passErr;
  String? _confirmErr;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _validate() {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pass = _password.text;
    final confirm = _confirm.text;

    String? nameErr;
    String? emailErr;
    String? passErr;
    String? confirmErr;

    if (name.length < 2) {
      nameErr = 'Enter your full name.';
    }

    if (email.isEmpty) {
      emailErr = 'Enter your email address.';
    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      emailErr = 'Enter a valid email, like name@example.com.';
    }

    if (pass.isEmpty) {
      passErr = 'Enter a password.';
    } else if (pass.length < 6) {
      passErr = 'Use at least 6 characters.';
    }

    if (confirm.isEmpty) {
      confirmErr = 'Confirm your password.';
    } else if (confirm != pass) {
      confirmErr = 'Passwords do not match.';
    }

    setState(() {
      _nameErr = nameErr;
      _emailErr = emailErr;
      _passErr = passErr;
      _confirmErr = confirmErr;
    });

    return nameErr == null &&
        emailErr == null &&
        passErr == null &&
        confirmErr == null;
  }

  // ============================================================
  // ERROR MESSAGES
  // ============================================================

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email sign-up is not enabled right now.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Please check your information and try again.';
    }
  }

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

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (_loading) return;
    if (!_validate()) return;

    setState(() => _loading = true);

    try {
      debugPrint('REGISTER: Starting registration...');

      final credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      final nameTrimmed = _name.text.trim();

      // Save the full name on the Firebase user profile.
      await credential.user?.updateDisplayName(nameTrimmed);

      // Sync newly registered user to Firestore
      await FirestoreService.syncCurrentUser(displayName: nameTrimmed);

      debugPrint('REGISTER: Registration successful');

      if (!mounted) return;

      _showMessage('Account created successfully!');

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Get.offAll(() => const Wrapper());
    } on FirebaseAuthException catch (e) {
      debugPrint('REGISTER ERROR: ${e.code} | ${e.message}');

      if (!mounted) return;

      if (e.code == 'email-already-in-use') {
        setState(() {
          _emailErr = 'An account already exists with this email.';
        });
        _emailFocus.requestFocus();
        return;
      }

      _showMessage(_messageFor(e));
    } catch (e, st) {
      debugPrint('REGISTER UNKNOWN ERROR: $e\n$st');
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ============================================================
  // UI
  // ============================================================

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
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    // HEADER
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        const Align(
                          alignment: Alignment.topLeft,
                          child: _RoundBackButton(),
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: _C.teal.withValues(alpha: 0.30),
                                    blurRadius: 26,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const SopaanLogo(size: 64, radius: 20),
                            ),
                            const SizedBox(height: 22),
                            const Text(
                              'Create your account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                height: 1.1,
                                fontWeight: FontWeight.w800,
                                color: _C.ink,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Start building your career with Sopaan.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: _C.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    // REGISTER CARD
                    _FormCard(
                      child: Column(
                        children: [
                          _AppField(
                            label: 'Full name',
                            hint: 'Your name',
                            icon: Icons.person_outline_rounded,
                            controller: _name,
                            errorText: _nameErr,
                            enabled: !_loading,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            onChanged: (_) {
                              if (_nameErr != null) {
                                setState(() => _nameErr = null);
                              }
                            },
                            onSubmitted: (_) => _emailFocus.requestFocus(),
                          ),
                          const SizedBox(height: 16),
                          _AppField(
                            label: 'Email',
                            hint: 'name@example.com',
                            icon: Icons.mail_outline_rounded,
                            controller: _email,
                            focusNode: _emailFocus,
                            errorText: _emailErr,
                            enabled: !_loading,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            onChanged: (_) {
                              if (_emailErr != null) {
                                setState(() => _emailErr = null);
                              }
                            },
                            onSubmitted: (_) => _passFocus.requestFocus(),
                          ),
                          const SizedBox(height: 16),
                          _AppField(
                            label: 'Password',
                            hint: 'At least 6 characters',
                            icon: Icons.lock_outline_rounded,
                            controller: _password,
                            focusNode: _passFocus,
                            errorText: _passErr,
                            enabled: !_loading,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            onChanged: (_) {
                              if (_passErr != null) {
                                setState(() => _passErr = null);
                              }
                            },
                            onSubmitted: (_) => _confirmFocus.requestFocus(),
                            suffix: IconButton(
                              tooltip:
                              _obscure ? 'Show password' : 'Hide password',
                              onPressed: _loading
                                  ? null
                                  : () => setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 21,
                                color: _C.faint,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _AppField(
                            label: 'Confirm password',
                            hint: 'Re-enter your password',
                            icon: Icons.lock_outline_rounded,
                            controller: _confirm,
                            focusNode: _confirmFocus,
                            errorText: _confirmErr,
                            enabled: !_loading,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            onChanged: (_) {
                              if (_confirmErr != null) {
                                setState(() => _confirmErr = null);
                              }
                            },
                            onSubmitted: (_) {
                              if (!_loading) _register();
                            },
                          ),
                          const SizedBox(height: 22),
                          _PrimaryButton(
                            label: 'Create account',
                            loading: _loading,
                            onPressed: _loading ? null : _register,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // LOGIN LINK
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(color: _C.muted, fontSize: 14),
                        ),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => Get.to(() => const Login()),
                          style: TextButton.styleFrom(
                            foregroundColor: _C.tealDeep,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: const Size(0, 44),
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ROUND BACK BUTTON
// ============================================================

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Back',
      child: Material(
        color: Colors.white,
        elevation: 0,
        shape: const CircleBorder(side: BorderSide(color: _C.line)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Get.back();
            }
          },
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.arrow_back_rounded, size: 21, color: _C.ink),
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
  final TextCapitalization textCapitalization;
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
    this.textCapitalization = TextCapitalization.none,
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
                  textCapitalization: widget.textCapitalization,
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
