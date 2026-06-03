import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../presentation/pages/film/film_page.dart';
import '../../presentation/pages/history/history_page.dart';
import '../../presentation/pages/live/live_page.dart';
import '../../presentation/pages/search/search_page.dart';
import '../../presentation/pages/setting/setting_page.dart';

/// 应用路由配置
/// 
/// 路由结构:
/// - / (主页 - 底部导航)
///   - /film (影视)
///   - /live (直播)
///   - /history (历史)
///   - /favorite (收藏)
///   - /setting (设置)
/// - /player/:id (播放器)
/// - /detail/:id (详情页)
/// - /search (搜索)
/// - /parse (解析配置)

final GoRouter router = GoRouter(
  initialLocation: '/film',
  routes: [
    // 底部导航主页
    GoRoute(
      path: '/',
      name: 'home',
      redirect: (context, state) => '/film',
    ),
    
    // 影视页面
    GoRoute(
      path: '/film',
      name: 'film',
      builder: (context, state) => const FilmPage(),
    ),
    
    // 直播页面
    GoRoute(
      path: '/live',
      name: 'live',
      builder: (context, state) => const LivePage(),
    ),
    
    // 历史页面
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const HistoryPage(),
    ),
    
    // 收藏页面
    GoRoute(
      path: '/favorite',
      name: 'favorite',
      builder: (context, state) => const PlaceholderPage(title: '收藏'),
    ),
    
    // 设置页面
    GoRoute(
      path: '/setting',
      name: 'setting',
      builder: (context, state) => const SettingPage(),
    ),
    
    // 播放器页面
    GoRoute(
      path: '/player/:id',
      name: 'player',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PlaceholderPage(title: '播放器 - $id');
      },
    ),
    
    // 详情页面
    GoRoute(
      path: '/detail/:id',
      name: 'detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PlaceholderPage(title: '详情 - $id');
      },
    ),
    
    // 搜索页面
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchPage(),
    ),
    
    // 解析配置页面
    GoRoute(
      path: '/parse',
      name: 'parse',
      builder: (context, state) => const PlaceholderPage(title: '解析'),
    ),
  ],
);

/// 临时占位页面
class PlaceholderPage extends StatelessWidget {
  final String title;
  
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 64,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              '$title 开发中...',
              style: theme.textTheme.h2,
            ),
            const SizedBox(height: 8),
            Text(
              '功能即将上线',
              style: theme.textTheme.muted,
            ),
          ],
        ),
      ),
    );
  }
}
