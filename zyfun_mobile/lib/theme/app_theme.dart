import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// 应用主题配置
class AppTheme {
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(16));

  static const Color _brandPrimary = Color(0xFF4F7CFF);
  static const Color _brandPrimaryDark = Color(0xFF7AA2FF);
  static const Color _brandCanvasLight = Color(0xFFF5F7FC);
  static const Color _brandCanvasDark = Color(0xFF0F172A);
  static const Color _brandCardLight = Color(0xFFFFFFFF);
  static const Color _brandCardDark = Color(0xFF111827);

  static const List<BoxShadow> _cardShadows = <BoxShadow>[
    BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  /// 亮色主题
  static ShadThemeData get lightTheme => ShadThemeData(
        brightness: Brightness.light,
        radius: _radius,
        colorScheme: const ShadZincColorScheme.light(
          primary: _brandPrimary,
          background: _brandCanvasLight,
          card: _brandCardLight,
        ),
        primaryButtonTheme: const ShadButtonTheme(
          height: 46,
          backgroundColor: _brandPrimary,
          foregroundColor: Colors.white,
        ),
        secondaryButtonTheme: const ShadButtonTheme(
          height: 44,
          backgroundColor: Color(0xFFEAF0FF),
          foregroundColor: _brandPrimary,
        ),
        ghostButtonTheme: const ShadButtonTheme(
          height: 44,
          foregroundColor: Color(0xFF334155),
        ),
        cardTheme: ShadCardTheme(
          backgroundColor: _brandCardLight,
          radius: _radius,
          padding: const EdgeInsets.all(18),
          shadows: _cardShadows,
          border: ShadBorder.all(
            color: const Color(0xFFE2E8F0),
            radius: _radius,
          ),
        ),
      );

  /// 暗色主题
  static ShadThemeData get darkTheme => ShadThemeData(
        brightness: Brightness.dark,
        radius: _radius,
        colorScheme: const ShadSlateColorScheme.dark(
          primary: _brandPrimaryDark,
          background: _brandCanvasDark,
          card: _brandCardDark,
        ),
        primaryButtonTheme: const ShadButtonTheme(
          height: 46,
          backgroundColor: _brandPrimaryDark,
          foregroundColor: Color(0xFF0F172A),
        ),
        secondaryButtonTheme: const ShadButtonTheme(
          height: 44,
          backgroundColor: Color(0xFF172036),
          foregroundColor: Color(0xFFD7E3FF),
        ),
        ghostButtonTheme: const ShadButtonTheme(
          height: 44,
          foregroundColor: Color(0xFFE5E7EB),
        ),
        cardTheme: ShadCardTheme(
          backgroundColor: _brandCardDark,
          radius: _radius,
          padding: const EdgeInsets.all(18),
          shadows: const <BoxShadow>[
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 28,
              offset: Offset(0, 16),
            ),
          ],
          border: ShadBorder.all(
            color: const Color(0xFF1F2937),
            radius: _radius,
          ),
        ),
      );
}
