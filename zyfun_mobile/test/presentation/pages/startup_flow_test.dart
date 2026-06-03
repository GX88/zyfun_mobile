import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zyfun_mobile/core/constants/constants.dart';
import 'package:zyfun_mobile/data/models/setting.dart';
import 'package:zyfun_mobile/domain/repositories/setting_repository.dart';
import 'package:zyfun_mobile/presentation/pages/disclaimer/disclaimer_page.dart';
import 'package:zyfun_mobile/presentation/pages/splash/splash_page.dart';
import 'package:zyfun_mobile/presentation/providers/app_providers.dart';
import 'package:zyfun_mobile/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SplashPage 首次启动后跳转到免责声明页', (tester) async {
    final repository = _InMemorySettingRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          settingRepositoryProvider.overrideWithValue(repository),
        ],
        child: const _TestStartupApp(
          initialLocation: RouteConstants.splash,
          splashPage: SplashPage(transitionDelay: Duration.zero),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('免责声明'), findsOneWidget);
    expect(find.text('使用须知'), findsOneWidget);
  });

  testWidgets('DisclaimerPage 接受后跳转到首页', (tester) async {
    final repository = _InMemorySettingRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          settingRepositoryProvider.overrideWithValue(repository),
        ],
        child: const _TestStartupApp(
          initialLocation: RouteConstants.disclaimer,
        ),
      ),
    );

    await tester.tap(find.text('我已阅读并继续'));
    await tester.pumpAndSettle();

    expect(find.text('影视首页'), findsOneWidget);
    expect(repository.values[StorageKeys.disclaimerAccepted], true);
  });
}

class _TestStartupApp extends StatelessWidget {
  const _TestStartupApp({
    required this.initialLocation,
    this.splashPage,
  });

  final String initialLocation;
  final SplashPage? splashPage;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: <RouteBase>[
        GoRoute(
          path: RouteConstants.splash,
          builder: (context, state) => splashPage ?? const SplashPage(),
        ),
        GoRoute(
          path: RouteConstants.disclaimer,
          builder: (context, state) => const DisclaimerPage(),
        ),
        GoRoute(
          path: RouteConstants.film,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('影视首页')),
          ),
        ),
      ],
    );

    return ShadApp.router(
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}

class _InMemorySettingRepository implements SettingRepository {
  final Map<String, Object?> values = <String, Object?>{};
  Setting? setting;

  @override
  Future<Setting> exportSetting() async => setting ?? const Setting();

  @override
  Future<Setting> getAllSettings() async => setting ?? const Setting();

  @override
  Future<T?> getSetting<T>(String key) async {
    final value = values[key];
    if (key == StorageKeys.setting && setting != null) {
      return setting!.toJson() as T;
    }
    return value as T?;
  }

  @override
  Future<void> importSetting(Setting setting) async {
    this.setting = setting;
    values[StorageKeys.setting] = setting.toJson();
  }

  @override
  Future<void> resetSetting() async {
    setting = null;
    values.clear();
  }

  @override
  Future<void> updateSetting<T>(String key, T value) async {
    values[key] = value;
  }
}
