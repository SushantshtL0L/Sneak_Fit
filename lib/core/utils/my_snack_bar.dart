import 'package:flutter/material.dart';

enum SnackBarType { success, error, info, warning }

void showMySnackBar({
  required BuildContext context,
  required String message,
  SnackBarType type = SnackBarType.success,
}) {
  final Color backgroundColor;
  final IconData icon;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = const Color(0xFF4CAF50);
      icon = Icons.check_circle_outline;
      break;
    case SnackBarType.error:
      backgroundColor = const Color(0xFFE57373);
      icon = Icons.error_outline;
      break;
    case SnackBarType.warning:
      backgroundColor = const Color(0xFFFFB74D);
      icon = Icons.warning_amber_rounded;
      break;
    case SnackBarType.info:
      backgroundColor = const Color(0xFF64B5F6);
      icon = Icons.info_outline;
      break;
  }

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20), // Added bottom margin
      duration: const Duration(seconds: 3),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}