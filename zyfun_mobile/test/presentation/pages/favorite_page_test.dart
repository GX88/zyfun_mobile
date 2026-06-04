import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zyfun_mobile/data/models/favorite.dart';
import 'package:zyfun_mobile/domain/repositories/favorite_repository.dart';
import 'package:zyfun_mobile/presentation/pages/favorite/favorite_page.dart';
import 'package:zyfun_mobile/presentation/providers/app_providers.dart';
import 'package:zyfun_mobile/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FavoritePage 支持分组筛选和删除', (tester) async {
    final repository = _FakeFavoriteRepository(
      items: <Favorite>[
        _buildFavorite(id: 'f1', siteId: 'site-a', title: '流浪地球 2'),
        _buildFavorite(id: 'f2', siteId: 'site-b', title: '三体'),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          favoriteRepositoryProvider.overrideWithValue(repository),
        ],
        child: const _TestFavoriteApp(child: FavoritePage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('流浪地球 2'), findsOneWidget);
    expect(find.text('三体'), findsOneWidget);

    await tester.tap(find.text('site-a').first);
    await tester.pumpAndSettle();

    expect(find.text('流浪地球 2'), findsOneWidget);
    expect(find.text('三体'), findsNothing);

    await tester.tap(find.text('删除收藏'));
    await tester.pumpAndSettle();

    expect(repository.items.length, 1);
    expect(repository.items.single.title, '三体');
  });

  testWidgets('FavoritePage 支持跳转详情', (tester) async {
    final repository = _FakeFavoriteRepository(
      items: <Favorite>[
        _buildFavorite(id: 'f1', siteId: 'site-a', title: '流浪地球 2'),
      ],
    );
    String? visitedSiteId;

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          favoriteRepositoryProvider.overrideWithValue(repository),
        ],
        child: _TestFavoriteApp(
          onDetailRoute: (state) => visitedSiteId = state.uri.queryParameters['siteId'],
          child: const FavoritePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('查看详情'));
    await tester.pumpAndSettle();

    expect(visitedSiteId, 'site-a');
  });
}

class _TestFavoriteApp extends StatelessWidget {
  const _TestFavoriteApp({required this.child, this.onDetailRoute});

  final Widget child;
  final void Function(GoRouterState state)? onDetailRoute;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/favorite',
      routes: <RouteBase>[
        GoRoute(
          path: '/favorite',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/detail/:id',
          builder: (context, state) {
            onDetailRoute?.call(state);
            return const Scaffold(body: Text('详情测试页'));
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
          path: '/history',
          builder: (context, state) => const Scaffold(body: Text('历史测试页')),
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

Favorite _buildFavorite({
  required String id,
  required String siteId,
  required String title,
}) {
  return Favorite(
    id: id,
    siteId: siteId,
    videoId: '${id}_video',
    title: title,
    createdAt: DateTime(2026, 6, 4, 13, 0).millisecondsSinceEpoch,
  );
}

class _FakeFavoriteRepository implements FavoriteRepository {
  _FakeFavoriteRepository({required List<Favorite> items}) : items = List<Favorite>.from(items);

  final List<Favorite> items;

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
  Future<List<Favorite>> getAllFavorites() async => List<Favorite>.from(items);

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
