import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// 应用主题配置
class AppTheme {
  /// 亮色主题
  static ShadThemeData get lightTheme => ShadThemeData(
      brightness: Brightness.light,
      colorScheme: ShadZincColorScheme.light(),
      primaryButtonTheme: ShadButtonTheme(height: 44),
    );

  /// 暗色主题
  static ShadThemeData get darkTheme => ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: ShadSlateColorScheme.dark(),
      primaryButtonTheme: ShadButtonTheme(height: 44),
    );
}
