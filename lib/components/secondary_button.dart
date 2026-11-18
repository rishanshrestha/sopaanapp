import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color textColor;
  final Color borderColor;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.textColor = const Color(0xFF0B1F33),
    this.borderColor = const Color(0xFFE3EBF1),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: Colors.white.withValues(alpha: 0.85),
          side: BorderSide(
            color: borderColor,
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
