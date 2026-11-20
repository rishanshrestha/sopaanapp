import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// Backward compatibility alias
typedef Forgot = ForgotPasswordScreen;

// ============================================================
// DESIGN TOKENS
// ============================================================

class _C {
  static const teal = Color(0xFF14B8A6);
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

typedef AC = _C;

// ============================================================
// FORGOT PASSWORD SCREEN
// ============================================================

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _email = TextEditingController();

  bool _loading = false;
  bool _sent = false;
  String? _emailErr;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();

    final email = _email.text.trim();

    // Validate email
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() {
        _emailErr = 'Enter a valid email, like name@example.com.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _emailErr = null;
    });

    try {
      // Firebase password reset
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      setState(() {
        _sent = true;
      });

      Get.snackbar(
        'Success',
        'Password reset email sent!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('RESET ERROR: ${e.code} | ${e.message}');

      if (mounted) {
        Get.snackbar(
          'Reset Failed',
          e.message ?? 'Failed to send password reset email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      debugPrint('RESET ERROR: $e');

      if (mounted) {
        Get.snackbar(
          'Error',
          'Something went wrong. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AC.bg,
        body: Stack(
          children: [
            const Positioned.fill(
              child: AuthBackground(),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RoundBackButton(),
                    const SizedBox(height: 32),
                    const Text(
                      'Reset your password',
                      style: TextStyle(
                        fontSize: 30,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        color: AC.ink,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Enter your email and we'll send you "
                          'a link to set a new password.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: AC.muted,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AuthCard(
                      child: _sent ? _successView() : _resetForm(),
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

  // Email input and reset button
  Widget _resetForm() {
    return Column(
      children: [
        AuthField(
          label: 'Email',
          hint: 'name@example.com',
          icon: Icons.mail_outline_rounded,
          controller: _email,
          errorText: _emailErr,
          enabled: !_loading,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [
            AutofillHints.email,
          ],
          onChanged: (_) {
            if (_emailErr != null) {
              setState(() {
                _emailErr = null;
              });
            }
          },
          onSubmitted: (_) {
            if (!_loading) {
              _send();
            }
          },
        ),
        const SizedBox(height: 20),
        AuthButton(
          label: 'Send reset link',
          loading: _loading,
          onPressed: _loading ? null : _send,
        ),
      ],
    );
  }

  // Success confirmation
  Widget _successView() {
    return Column(
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 50,
          color: AC.teal,
        ),
        const SizedBox(height: 14),
        const Text(
          'Check your email!',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: AC.ink,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'If an account exists for ${_email.text.trim()}, '
              'check your inbox and spam folder for '
              'the password reset link.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14.5,
            height: 1.5,
            color: AC.ink,
          ),
        ),
        const SizedBox(height: 24),
        AuthButton(
          label: 'Back to sign in',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Get.back();
            }
          },
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            setState(() {
              _sent = false;
            });
          },
          child: const Text('Try another email'),
        ),
      ],
    );
  }
}

// ============================================================
// COMPONENT HELPERS
// ============================================================

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5],
          colors: [AC.bgTop, AC.bg],
        ),
      ),
    );
  }
}

class RoundBackButton extends StatelessWidget {
  const RoundBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Back',
      child: Material(
        color: Colors.white,
        elevation: 0,
        shape: const CircleBorder(side: BorderSide(color: AC.line)),
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
            child: Icon(Icons.arrow_back_rounded, size: 21, color: AC.ink),
          ),
        ),
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AC.line),
        boxShadow: [
          BoxShadow(
            color: AC.navy.withValues(alpha: 0.07),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? errorText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.focusNode,
    this.errorText,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
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
        ? AC.error
        : focused
        ? AC.teal
        : AC.line;

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
              color: hasError ? AC.error : AC.ink,
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
                color: (hasError ? AC.error : AC.teal)
                    .withValues(alpha: focused ? 0.16 : 0.0),
                blurRadius: 0,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: AC.navy.withValues(alpha: 0.04),
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
                      ? AC.error
                      : focused
                      ? AC.teal
                      : AC.faint,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  autofillHints: widget.autofillHints,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  cursorColor: AC.teal,
                  style: const TextStyle(color: AC.ink, fontSize: 15.5),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: const TextStyle(color: AC.faint, fontSize: 15),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
                    color: AC.error,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: const TextStyle(
                      color: AC.error,
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

class AuthButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const AuthButton({
    super.key,
    required this.label,
    this.loading = false,
    required this.onPressed,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
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
          gradient: AC.gradient,
          boxShadow: [
            BoxShadow(
              color: AC.teal.withValues(alpha: enabled ? 0.34 : 0.14),
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
                  color: AC.navy,
                ),
              )
                  : Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: AC.navy,
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
