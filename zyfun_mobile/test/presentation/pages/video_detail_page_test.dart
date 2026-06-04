import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zyfun_mobile/data/models/favorite.dart';
import 'package:zyfun_mobile/data/models/history.dart';
import 'package:zyfun_mobile/data/models/site.dart';
import 'package:zyfun_mobile/data/models/video.dart';
import 'package:zyfun_mobile/domain/repositories/favorite_repository.dart';
import 'package:zyfun_mobile/domain/repositories/history_repository.dart';
import 'package:zyfun_mobile/domain/repositories/site_repository.dart';
import 'package:zyfun_mobile/presentation/pages/detail/video_detail_page.dart';
import 'package:zyfun_mobile/presentation/providers/app_providers.dart';
import 'package:zyfun_mobile/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('VideoDetailPage 渲染详情并支持收藏', (tester) async {
    final siteRepository = _FakeSiteRepository();
    final favoriteRepository = _FakeFavoriteRepository();
    final historyRepository = _FakeHistoryRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          siteRepositoryProvider.overrideWithValue(siteRepository),
          favoriteRepositoryProvider.overrideWithValue(favoriteRepository),
          historyRepositoryProvider.overrideWithValue(historyRepository),
        ],
        child: const _TestDetailApp(
          child: VideoDetailPage(
            siteId: 'site-1',
            videoId: 'video-1',
            title: '流浪地球 2',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('流浪地球 2'), findsWidgets);
    expect(find.text('剧情简介'), findsOneWidget);
    expect(find.text('第 1 集'), findsOneWidget);

    await tester.tap(find.byTooltip('收藏'));
    await tester.pumpAndSettle();

    expect(favoriteRepository.items.length, 1);
    expect(find.byTooltip('取消收藏'), findsOneWidget);

    await tester.tap(find.widgetWithText(ShadButton, '第 1 集'));
    await tester.pumpAndSettle();

    expect(historyRepository.items.length, 1);
    expect(historyRepository.items.single.episodeName, '第 1 集');
  });

  testWidgets('VideoDetailPage 播放时会携带连播上下文参数', (tester) async {
    final siteRepository = _FakeSiteRepository();
    final favoriteRepository = _FakeFavoriteRepository();
    final historyRepository = _FakeHistoryRepository();
    GoRouterState? visitedState;

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          siteRepositoryProvider.overrideWithValue(siteRepository),
          favoriteRepositoryProvider.overrideWithValue(favoriteRepository),
          historyRepositoryProvider.overrideWithValue(historyRepository),
        ],
        child: _TestDetailApp(
          onPlayerRoute: (state) => visitedState = state,
          child: const VideoDetailPage(
            siteId: 'site-1',
            videoId: 'video-1',
            title: '流浪地球 2',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ShadButton, '第 2 集'));
    await tester.pumpAndSettle();

    expect(visitedState?.uri.queryParameters['siteId'], 'site-1');
    expect(visitedState?.uri.queryParameters['index'], '1');
    expect(visitedState?.uri.queryParameters['playlist'], contains('第 1 集'));
    expect(visitedState?.uri.queryParameters['playlist'], contains('第 2 集'));
  });
}

class _TestDetailApp extends StatelessWidget {
  const _TestDetailApp({required this.child, this.onPlayerRoute});

  final Widget child;
  final void Function(GoRouterState state)? onPlayerRoute;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/detail/video-1',
      routes: <RouteBase>[
        GoRoute(
          path: '/detail/:id',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/player/:id',
          builder: (context, state) {
            onPlayerRoute?.call(state);
            return const Scaffold(
              body: Center(child: Text('播放器测试页')),
            );
          },
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

class _FakeSiteRepository implements SiteRepository {
  @override
  Future<void> addSite(Site site) async {}

  @override
  Future<void> deleteSite(String id) async {}

  @override
  Future<String?> getDefaultSite() async => 'site-1';

  @override
  Future<List<Site>> getAllSites() async => const <Site>[];

  @override
  Future<String> getPlayUrl(String siteId, String episodeUrl) async => episodeUrl;

  @override
  Future<Site?> getSiteById(String id) async => const Site(
        id: 'site-1',
        key: 'site-1',
        name: '演示站点',
        api: 'https://example.com/api.php/provide/vod/',
        createdAt: 1,
        updatedAt: 1,
      );

  @override
  Future<List<Video>> getVideosByCategory(String siteId, String categoryId, int page) async {
    return const <Video>[];
  }

  @override
  Future<VideoDetail> getVideoDetail(String siteId, String videoId) async {
    return const VideoDetail(
      video: Video(
        id: 'video-1',
        title: '流浪地球 2',
        siteId: 'site-1',
        description: '太阳即将毁灭，人类再次启程。',
        content: '这是测试用详情内容。',
        year: '2023',
        area: '中国大陆',
        type: '科幻',
        actor: '吴京',
        director: '郭帆',
      ),
      episodes: <String>['第 1 集', '第 2 集'],
      playUrls: <Map<String, String>>[
        <String, String>{'name': '第 1 集', 'url': 'https://example.com/1.m3u8'},
        <String, String>{'name': '第 2 集', 'url': 'https://example.com/2.m3u8'},
      ],
      detailUrl: 'https://example.com/detail/video-1',
    );
  }

  @override
  Future<List<Category>> getCategories(String siteId) async => const <Category>[];

  @override
  Future<List<Video>> searchVideos(String siteId, String keyword) async => const <Video>[];

  @override
  Future<void> setDefaultSite(String id) async {}

  @override
  Future<void> updateSite(Site site) async {}
}

class _FakeFavoriteRepository implements FavoriteRepository {
  final List<Favorite> items = <Favorite>[];

  @override
  Future<void> addFavorite(Favorite favorite) async {
    items.removeWhere((item) => item.id == favorite.id);
    items.add(favorite);
  }

  @override
  Future<void> deleteFavorite(String id) async {
    items.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<Favorite>> getAllFavorites() async => items;

  @override
  Future<Favorite?> getFavoriteById(String id) async {
    return items.where((item) => item.id == id).cast<Favorite?>().firstWhere(
          (item) => item != null,
          orElse: () => null,
        );
  }

  @override
  Future<Favorite?> getFavoriteByVideo(String siteId, String videoId) async {
    return items
        .where((item) => item.siteId == siteId && item.videoId == videoId)
        .cast<Favorite?>()
        .firstWhere(
          (item) => item != null,
          orElse: () => null,
        );
  }
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
  Future<List<History>> getRecentHistories({int limit = 50}) async => items.take(limit).toList();

  @override
  Future<void> updateHistory(History history) async {
    await addHistory(history);
  }
}
