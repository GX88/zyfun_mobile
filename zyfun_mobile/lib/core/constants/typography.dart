import 'package:flutter/material.dart';

import 'colors.dart';

class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'Inter';
  static const List<String> fallback = <String>['Noto Sans SC', 'sans-serif'];

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fallback,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fallback,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fallback,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fallback,
    fontSize: 15,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fallback,
    fontSize: 13,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fallback,
    fontSize: 12,
    height: 1.3,
    color: AppColors.textTertiary,
  );

  static const TextStyle numeric = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );
}
