import 'package:flutter/material.dart';

/// UI design tokens for colors and gradients.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF818CF8);
  static const Color primarySoft = Color(0xFFEEF2FF);

  static const Color success = Color(0xFF22C55E);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoSoft = Color(0xFFDBEAFE);

  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundMuted = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color backgroundMutedDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceSubtleDark = Color(0xFF172036);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color textDisabledDark = Color(0xFF475569);
  static const Color borderDark = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF334155);

  static const LinearGradient vipGradient = LinearGradient(
    colors: <Color>[Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const List<LinearGradient> quickActionGradients = <LinearGradient>[
    LinearGradient(
      colors: <Color>[Color(0xFF60A5FA), Color(0xFF2563EB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: <Color>[Color(0xFFA78BFA), Color(0xFF7C3AED)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: <Color>[Color(0xFFF472B6), Color(0xFFEC4899)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: <Color>[Color(0xFF34D399), Color(0xFF10B981)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: <Color>[Color(0xFFFBBF24), Color(0xFFF59E0B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];
}
