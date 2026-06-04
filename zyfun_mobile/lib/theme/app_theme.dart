import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/constants/constants.dart';

/// 应用主题配置
class AppTheme {
  static const BorderRadius _radius = AppRadius.largeCard;

  /// 亮色主题
  static ShadThemeData get lightTheme => ShadThemeData(
        brightness: Brightness.light,
        radius: _radius,
        colorScheme: const ShadZincColorScheme.light(
          primary: AppColors.primary,
          background: AppColors.backgroundMuted,
          card: AppColors.surface,
          border: AppColors.border,
          muted: AppColors.textSecondary,
          secondary: AppColors.primarySoft,
          secondaryForeground: AppColors.primary,
          destructive: AppColors.error,
        ),
        primaryButtonTheme: const ShadButtonTheme(
          height: 44,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        secondaryButtonTheme: const ShadButtonTheme(
          height: 44,
          backgroundColor: AppColors.primarySoft,
          foregroundColor: AppColors.primary,
        ),
        ghostButtonTheme: const ShadButtonTheme(
          height: 44,
          foregroundColor: AppColors.textPrimary,
        ),
        cardTheme: ShadCardTheme(
          backgroundColor: AppColors.surface,
          radius: _radius,
          padding: AppSpacing.cardInsets,
          shadows: AppShadows.md,
          border: ShadBorder.all(
            color: AppColors.border,
            radius: _radius,
          ),
        ),
      );

  /// 暗色主题
  static ShadThemeData get darkTheme => ShadThemeData(
        brightness: Brightness.dark,
        radius: _radius,
        colorScheme: const ShadSlateColorScheme.dark(
          primary: AppColors.primaryDark,
          background: AppColors.backgroundDark,
          card: AppColors.surfaceDark,
          border: AppColors.borderDark,
          muted: AppColors.textSecondaryDark,
          secondary: AppColors.surfaceSubtleDark,
          secondaryForeground: AppColors.textPrimaryDark,
          destructive: AppColors.error,
        ),
        primaryButtonTheme: const ShadButtonTheme(
          height: 44,
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.backgroundDark,
        ),
        secondaryButtonTheme: const ShadButtonTheme(
          height: 44,
          backgroundColor: AppColors.surfaceSubtleDark,
          foregroundColor: AppColors.textPrimaryDark,
        ),
        ghostButtonTheme: const ShadButtonTheme(
          height: 44,
          foregroundColor: AppColors.textPrimaryDark,
        ),
        cardTheme: ShadCardTheme(
          backgroundColor: AppColors.surfaceDark,
          radius: _radius,
          padding: AppSpacing.cardInsets,
          shadows: AppShadows.darkCard,
          border: ShadBorder.all(
            color: AppColors.borderDark,
            radius: _radius,
          ),
        ),
      );
}
