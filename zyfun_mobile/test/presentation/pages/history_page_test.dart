import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zyfun_mobile/data/models/history.dart';
import 'package:zyfun_mobile/domain/repositories/history_repository.dart';
import 'package:zyfun_mobile/presentation/pages/history/history_page.dart';
import 'package:zyfun_mobile/presentation/providers/app_providers.dart';
import 'package:zyfun_mobile/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HistoryPage 支持续看', (tester) async {
    final repository = _FakeHistoryRepository(
      items: <History>[
        _buildHistory(
          id: 'history-1',
          title: '流浪地球 2',
          episodeName: '第 1 集',
          episodeUrl: 'https://example.com/1.m3u8',
        ),
      ],
    );
    String? visitedPlayerUrl;

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          historyRepositoryProvider.overrideWithValue(repository),
        ],
        child: _TestHistoryApp(
          onPlayerRoute: (state) => visitedPlayerUrl = state.uri.queryParameters['url'],
          child: const HistoryPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('流浪地球 2'), findsOneWidget);
    expect(find.text('继续观看'), findsOneWidget);

    await tester.tap(find.text('继续观看'));
    await tester.pumpAndSettle();

    expect(visitedPlayerUrl, 'https://example.com/1.m3u8');
  });

  testWidgets('HistoryPage 支持单条删除', (tester) async {
    final repository = _FakeHistoryRepository(
      items: <History>[
        _buildHistory(
          id: 'history-1',
          title: '流浪地球 2',
          episodeName: '第 1 集',
          episodeUrl: 'https://example.com/1.m3u8',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          historyRepositoryProvider.overrideWithValue(repository),
        ],
        child: const _TestHistoryApp(child: HistoryPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(repository.items, isEmpty);
    expect(find.text('暂无播放历史'), findsOneWidget);
  });

  testWidgets('HistoryPage 支持批量清空', (tester) async {
    final repository = _FakeHistoryRepository(
      items: <History>[
        _buildHistory(
          id: 'history-1',
          title: '流浪地球 2',
          episodeName: '第 1 集',
          episodeUrl: 'https://example.com/1.m3u8',
        ),
        _buildHistory(
          id: 'history-2',
          title: '三体',
          episodeName: '第 2 集',
          episodeUrl: 'https://example.com/2.m3u8',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          historyRepositoryProvider.overrideWithValue(repository),
        ],
        child: const _TestHistoryApp(child: HistoryPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('清空历史'));
    await tester.pumpAndSettle();

    expect(find.text('清空历史'), findsOneWidget);
    await tester.tap(find.text('清空'));
    await tester.pumpAndSettle();

    expect(repository.items, isEmpty);
    expect(find.text('暂无播放历史'), findsOneWidget);
  });
}

class _TestHistoryApp extends StatelessWidget {
  const _TestHistoryApp({required this.child, this.onPlayerRoute});

  final Widget child;
  final void Function(GoRouterState state)? onPlayerRoute;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/history',
      routes: <RouteBase>[
        GoRoute(
          path: '/history',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/player/:id',
          builder: (context, state) {
            onPlayerRoute?.call(state);
            return const Scaffold(body: Text('播放器测试页'));
          },
        ),
        GoRoute(
          path: '/film',
          builder: (context, state) => const Scaffold(body: Text('影视测试页')),
        ),
        GoRoute(
          path: '/live',
          builder: (context, state) => const Scaffold(body: Text('直播测试页')),
        ),
        GoRoute(
          path: '/setting',
          builder: (context, state) => const Scaffold(body: Text('设置测试页')),
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

History _buildHistory({
  required String id,
  required String title,
  required String episodeName,
  required String episodeUrl,
}) {
  return History(
    id: id,
    siteId: 'site-1',
    videoId: 'video-1',
    title: title,
    episodeUrl: episodeUrl,
    episodeName: episodeName,
    progress: 60 * 1000,
    duration: 120 * 1000,
    createdAt: DateTime(2026, 6, 4, 12, 0).millisecondsSinceEpoch,
    updatedAt: DateTime(2026, 6, 4, 13, 30).millisecondsSinceEpoch,
  );
}

class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository({required List<History> items}) : items = List<History>.from(items);

  final List<History> items;

  @override
  Future<void> addHistory(History history) async {
    items.removeWhere((item) => item.id == history.id);
    items.insert(0, history);
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
  Future<List<History>> getAllHistories() async => List<History>.from(items);

  @override
  Future<History?> getHistoryById(String id) async {
    return items.where((item) => item.id == id).cast<History?>().firstWhere(
          (item) => item != null,
          orElse: () => null,
        );
  }

  @override
  Future<List<History>> getRecentHistories({int limit = 50}) async {
    return items.take(limit).toList();
  }

  @override
  Future<void> updateHistory(History history) async {
    await addHistory(history);
  }
}
