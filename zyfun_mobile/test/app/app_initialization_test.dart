import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zyfun_mobile/data/repositories/setting_repository_impl.dart';
import 'package:zyfun_mobile/data/repositories/site_repository_impl.dart';
import 'package:zyfun_mobile/presentation/providers/app_providers.dart';
import 'package:zyfun_mobile/theme/app_theme.dart';

import 'package:zyfun_mobile/app/routes/app_routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('依赖注入初始化', () {
    test('ProviderContainer 可以读取核心 Provider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final siteRepository = container.read(siteRepositoryProvider);
      final settingRepository = container.read(settingRepositoryProvider);
      final database = container.read(appDatabaseProvider);

      expect(siteRepository, isA<SiteRepositoryImpl>());
      expect(settingRepository, isA<SettingRepositoryImpl>());
      expect(database, isNotNull);
    });
  });

  group('路由配置', () {
    test('默认初始路由为 /film', () {
      expect(router.routeInformationProvider.value.uri.path, '/film');
    });

    test('核心页面路由已注册', () {
      final paths = router.configuration.routes
          .whereType<GoRoute>()
          .map((route) => route.path)
          .toList();

      expect(paths, contains('/film'));
      expect(paths, contains('/live'));
      expect(paths, contains('/history'));
      expect(paths, contains('/search'));
      expect(paths, contains('/setting'));
    });
  });

  group('Shad 主题配置', () {
    test('亮色主题配置正确', () {
      final theme = AppTheme.lightTheme;

      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme, isA<ShadZincColorScheme>());
      expect(theme.primaryButtonTheme.height, 44);
    });

    test('暗色主题配置正确', () {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme, isA<ShadSlateColorScheme>());
      expect(theme.primaryButtonTheme.height, 44);
    });
  });
}
