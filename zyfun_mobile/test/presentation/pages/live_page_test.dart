import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zyfun_mobile/data/models/history.dart';
import 'package:zyfun_mobile/data/models/iptv.dart';
import 'package:zyfun_mobile/domain/repositories/history_repository.dart';
import 'package:zyfun_mobile/domain/repositories/iptv_repository.dart';
import 'package:zyfun_mobile/presentation/pages/live/live_page.dart';
import 'package:zyfun_mobile/presentation/providers/app_providers.dart';
import 'package:zyfun_mobile/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LivePage 渲染频道分组并支持回看入口', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final iptvRepository = _FakeIptvRepository();
    final historyRepository = _FakeHistoryRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          iptvRepositoryProvider.overrideWithValue(iptvRepository),
          historyRepositoryProvider.overrideWithValue(historyRepository),
        ],
        child: const _TestLiveApp(child: LivePage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('当前播放'), findsOneWidget);
    expect(find.text('CCTV-1'), findsWidgets);
    expect(find.text('央视'), findsWidgets);
    expect(find.text('回看入口'), findsOneWidget);

    final replayButton = find.widgetWithText(ShadButton, '回看入口').first;
    await tester.tap(replayButton);
    await tester.pumpAndSettle();

    expect(historyRepository.items, hasLength(1));
    expect(historyRepository.items.single.title, 'CCTV-1');
  });
}

class _TestLiveApp extends StatelessWidget {
  const _TestLiveApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/live',
      routes: <RouteBase>[
        GoRoute(
          path: '/live',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/player/:id',
          builder: (context, state) => const Scaffold(body: Text('播放器测试页')),
        ),
        GoRoute(
          path: '/setting',
          builder: (context, state) => const Scaffold(body: Text('设置测试页')),
        ),
        GoRoute(
          path: '/film',
          builder: (context, state) => const Scaffold(body: Text('影视测试页')),
        ),
        GoRoute(
          path: '/parse',
          builder: (context, state) => const Scaffold(body: Text('解析测试页')),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const Scaffold(body: Text('历史测试页')),
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

class _FakeIptvRepository implements IptvRepository {
  final List<Iptv> _iptvs = <Iptv>[
    const Iptv(
      id: 'iptv-1',
      key: 'iptv-1',
      name: '默认直播源',
      api: 'demo',
      type: 3,
      epg: 'https://example.com/epg.xml',
      createdAt: 1,
      updatedAt: 1,
    ),
  ];

  @override
  Future<void> addIptv(Iptv iptv) async {
    _iptvs.add(iptv);
  }

  @override
  Future<void> deleteIptv(String id) async {}

  @override
  Future<List<Iptv>> getAllIptvs() async => _iptvs;

  @override
  Future<List<Channel>> getChannels(String iptvId) async {
    return const <Channel>[
      Channel(
        id: 'cctv1',
        name: 'CCTV-1',
        url: 'https://example.com/cctv1.m3u8',
        group: '央视',
      ),
      Channel(
        id: 'hunan',
        name: '湖南卫视',
        url: 'https://example.com/hunan.m3u8',
        group: '卫视',
      ),
    ];
  }

  @override
  Future<Iptv?> getIptvById(String id) async => _iptvs.first;

  @override
  Future<String?> getDefaultIptv() async => 'iptv-1';

  @override
  Future<List<Channel>> parseM3u(String content) async => const <Channel>[];

  @override
  Future<void> setDefaultIptv(String id) async {}

  @override
  Future<void> updateIptv(Iptv iptv) async {}
}

class _FakeHistoryRepository implements HistoryRepository {
  final List<History> items = <History>[];

  @override
  Future<void> addHistory(History history) async {
    items.removeWhere((item) => item.id == history.id);
    items.add(history);
  }

  @override
  Future<void> clearAllHistories() async {
    items.clear();
  }

  @override
  Future<void> deleteHistory(String id) async {
    items.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<History>> getAllHistories() async => items;

  @override
  Future<History?> getHistoryById(String id) async {
    return items.where((item) => item.id == id).cast<History?>().firstWhere(
          (item) => item != null,
          orElse: () => null,
        );
  }

  @override
  Future<List<History>> getRecentHistories({int limit = 20}) async => items.take(limit).toList();

  @override
  Future<void> updateHistory(History history) async {
    await addHistory(history);
  }
}
