import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context, {
  required String content,
  SnackBarAction? action,
  IconData? icon,
  bool isError = false,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final backgroundColor = isError
      ? (isDark ? const Color(0xFF3B1219) : const Color(0xFFFEE2E2))
      : (isDark ? const Color(0xFF1A2E1A) : const Color(0xFFECFDF5));

  final textColor = isError
      ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B))
      : (isDark ? const Color(0xFF86EFAC) : const Color(0xFF065F46));

  final iconColor = isError
      ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626))
      : (isDark ? const Color(0xFF86EFAC) : const Color(0xFF10B981));

  final effectiveIcon =
      icon ?? (isError ? Icons.error_outline : Icons.check_circle_outline);

  final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(effectiveIcon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            content,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
    action: action,
    duration: const Duration(seconds: 2),
    backgroundColor: backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
