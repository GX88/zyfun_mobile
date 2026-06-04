import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zyfun_mobile/data/models/setting.dart';
import 'package:zyfun_mobile/data/models/analyze.dart';
import 'package:zyfun_mobile/data/models/iptv.dart';
import 'package:zyfun_mobile/data/models/site.dart';
import 'package:zyfun_mobile/data/models/video.dart';
import 'package:zyfun_mobile/data/services/config_import_service.dart';
import 'package:zyfun_mobile/domain/repositories/analyze_repository.dart';
import 'package:zyfun_mobile/domain/repositories/iptv_repository.dart';
import 'package:zyfun_mobile/domain/repositories/site_repository.dart';
import 'package:zyfun_mobile/domain/repositories/setting_repository.dart';
import 'package:zyfun_mobile/presentation/pages/about/about_page.dart';
import 'package:zyfun_mobile/presentation/pages/ai/ai_page.dart';
import 'package:zyfun_mobile/presentation/pages/setting/setting_page.dart';
import 'package:zyfun_mobile/presentation/providers/app_providers.dart';
import 'package:zyfun_mobile/presentation/providers/setting_provider.dart';
import 'package:zyfun_mobile/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SettingPage 可以跳转到关于页和 AI 功能页', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          settingNotifierProvider.overrideWith((ref) => _FakeSettingNotifier()),
          settingRepositoryProvider.overrideWithValue(_FakeSettingRepository()),
          configImportServiceProvider.overrideWithValue(_NoopConfigImportService()),
          siteRepositoryProvider.overrideWithValue(_FakeSiteRepository()),
          iptvRepositoryProvider.overrideWithValue(_FakeIptvRepository()),
        ],
        child: const _TestSettingsRouterApp(),
      ),
    );

    await tester.pumpAndSettle();

    final aboutButton = find.widgetWithText(ShadButton, '关于应用');
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(aboutButton);
    await tester.pumpAndSettle();
    expect(find.text('zyfun Flutter Mobile'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    final aiButton = find.widgetWithText(ShadButton, '打开 AI 功能页').first;
    await tester.drag(find.byType(ListView).first, const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(aiButton);
    await tester.pumpAndSettle();
    expect(find.text('AI 推荐'), findsOneWidget);
  });

  testWidgets('AiPage 可以跳转到搜索页', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _TestAiRouterApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('去搜索 科幻'));
    await tester.pumpAndSettle();

    expect(find.text('搜索测试页'), findsOneWidget);
  });
}

class _TestSettingsRouterApp extends StatelessWidget {
  const _TestSettingsRouterApp();

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/setting',
      routes: <RouteBase>[
        GoRoute(path: '/setting', builder: (context, state) => const SettingPage()),
        GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
        GoRoute(path: '/ai', builder: (context, state) => const AiPage()),
        GoRoute(path: '/shadcn', builder: (context, state) => const Scaffold(body: Text('shadcn 测试页'))),
        GoRoute(path: '/film', builder: (context, state) => const Scaffold(body: Text('影视测试页'))),
        GoRoute(path: '/live', builder: (context, state) => const Scaffold(body: Text('直播测试页'))),
        GoRoute(path: '/history', builder: (context, state) => const Scaffold(body: Text('历史测试页'))),
        GoRoute(path: '/favorite', builder: (context, state) => const Scaffold(body: Text('收藏测试页'))),
        GoRoute(path: '/search', builder: (context, state) => const Scaffold(body: Text('搜索测试页'))),
      ],
    );

    return ShadApp.router(
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}

class _TestAiRouterApp extends StatelessWidget {
  const _TestAiRouterApp();

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/ai',
      routes: <RouteBase>[
        GoRoute(path: '/ai', builder: (context, state) => const AiPage()),
        GoRoute(path: '/search', builder: (context, state) => const Scaffold(body: Text('搜索测试页'))),
        GoRoute(path: '/film', builder: (context, state) => const Scaffold(body: Text('影视测试页'))),
        GoRoute(path: '/live', builder: (context, state) => const Scaffold(body: Text('直播测试页'))),
        GoRoute(path: '/history', builder: (context, state) => const Scaffold(body: Text('历史测试页'))),
        GoRoute(path: '/favorite', builder: (context, state) => const Scaffold(body: Text('收藏测试页'))),
        GoRoute(path: '/setting', builder: (context, state) => const Scaffold(body: Text('设置测试页'))),
      ],
    );

    return ShadApp.router(
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}

class _FakeSettingNotifier extends SettingNotifier {
  _FakeSettingNotifier()
      : super(
          _FakeSettingRepository(),
          _NoopConfigImportService(),
        ) {
    state = const Setting(
      version: '1.0.0-test',
      theme: 'system',
      lang: 'zh_CN',
      player: PlayerConfig(type: 'media_kit'),
    );
  }
}

class _FakeSettingRepository implements SettingRepository {
  Setting _setting = const Setting();

  @override
  Future<Setting> getAllSettings() async => const Setting();

  @override
  Future<Setting> exportSetting() async => _setting;

  @override
  Future<T?> getSetting<T>(String key) async => null;

  @override
  Future<void> importSetting(Setting setting) async {
    _setting = setting;
  }

  @override
  Future<void> resetSetting() async {
    _setting = const Setting();
  }

  @override
  Future<void> updateSetting<T>(String key, T value) async {}
}

class _NoopConfigImportService extends ConfigImportService {
  _NoopConfigImportService()
      : super(
          siteRepository: _FakeSiteRepository(),
          iptvRepository: _FakeIptvRepository(),
          analyzeRepository: _FakeAnalyzeRepository(),
          settingRepository: _FakeSettingRepository(),
        );
}

class _FakeSiteRepository implements SiteRepository {
  @override
  Future<void> addSite(Site site) async {}

  @override
  Future<void> deleteSite(String id) async {}

  @override
  Future<String?> getDefaultSite() async => null;

  @override
  Future<List<Site>> getAllSites() async => const <Site>[];

  @override
  Future<String> getPlayUrl(String siteId, String episodeUrl) async => episodeUrl;

  @override
  Future<Site?> getSiteById(String id) async => null;

  @override
  Future<VideoDetail> getVideoDetail(String siteId, String videoId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> getCategories(String siteId) async => const <Category>[];

  @override
  Future<List<Video>> getVideosByCategory(String siteId, String categoryId, int page) async {
    return const <Video>[];
  }

  @override
  Future<List<Video>> searchVideos(String siteId, String keyword) async => const <Video>[];

  @override
  Future<void> setDefaultSite(String id) async {}

  @override
  Future<void> updateSite(Site site) async {}
}

class _FakeIptvRepository implements IptvRepository {
  @override
  Future<void> addIptv(Iptv iptv) async {}

  @override
  Future<void> deleteIptv(String id) async {}

  @override
  Future<List<Iptv>> getAllIptvs() async => const <Iptv>[];

  @override
  Future<List<Channel>> getChannels(String iptvId) async => const <Channel>[];

  @override
  Future<String?> getDefaultIptv() async => null;

  @override
  Future<Iptv?> getIptvById(String id) async => null;

  @override
  Future<List<Channel>> parseM3u(String content) async => const <Channel>[];

  @override
  Future<void> setDefaultIptv(String id) async {}

  @override
  Future<void> updateIptv(Iptv iptv) async {}
}

class _FakeAnalyzeRepository implements AnalyzeRepository {
  @override
  Future<void> addAnalyze(Analyze analyze) async {}

  @override
  Future<void> deleteAnalyze(String id) async {}

  @override
  Future<List<Analyze>> getAllAnalyzes() async => const <Analyze>[];

  @override
  Future<Analyze?> getAnalyzeById(String id) async => null;

  @override
  Future<String?> getDefaultAnalyze() async => null;

  @override
  Future<void> setDefaultAnalyze(String id) async {}

  @override
  Future<void> updateAnalyze(Analyze analyze) async {}
}
