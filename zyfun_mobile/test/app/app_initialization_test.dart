import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zyfun_mobile/app/app.dart';
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
      expect(router.routeInformationProvider.value.uri.path, '/splash');
    });

    test('核心页面路由已注册', () {
      final paths = router.configuration.routes
          .whereType<GoRoute>()
          .map((route) => route.path)
          .toList();

      expect(paths, contains('/splash'));
      expect(paths, contains('/disclaimer'));
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
      expect(theme.primaryButtonTheme.height, 46);
      expect(theme.primaryButtonTheme.backgroundColor, const Color(0xFF4F7CFF));
      expect(theme.cardTheme.radius, const BorderRadius.all(Radius.circular(16)));
      expect(theme.cardTheme.padding, const EdgeInsets.all(18));
    });

    test('暗色主题配置正确', () {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme, isA<ShadSlateColorScheme>());
      expect(theme.primaryButtonTheme.height, 46);
      expect(theme.primaryButtonTheme.backgroundColor, const Color(0xFF7AA2FF));
      expect(theme.cardTheme.radius, const BorderRadius.all(Radius.circular(16)));
      expect(theme.cardTheme.padding, const EdgeInsets.all(18));
    });
  });

  group('国际化配置', () {
    testWidgets('应用注册 Shad 和 Flutter 本地化委托', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ZyfunApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final shadApp = tester.widget<ShadApp>(find.byType(ShadApp));
      final delegates = shadApp.localizationsDelegates?.toList() ?? const [];

      expect(delegates, contains(GlobalShadLocalizations.delegate));
      expect(delegates, contains(GlobalMaterialLocalizations.delegate));
      expect(delegates, contains(GlobalCupertinoLocalizations.delegate));
      expect(delegates, contains(GlobalWidgetsLocalizations.delegate));
      expect(shadApp.supportedLocales, contains(const Locale('zh', 'CN')));
      expect(shadApp.supportedLocales, contains(const Locale('zh', 'TW')));
      expect(shadApp.supportedLocales, contains(const Locale('en')));
    });
  });
}
