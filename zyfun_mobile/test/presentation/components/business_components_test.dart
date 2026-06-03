import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zyfun_mobile/data/models/video.dart';
import 'package:zyfun_mobile/presentation/components/app_bottom_nav_bar.dart';
import 'package:zyfun_mobile/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('VideoCard 渲染标题与操作按钮', (tester) async {
    const video = Video(
      id: 'v1',
      title: '三体',
      description: '文明的碰撞。',
      type: '科幻',
      siteId: 'site-1',
    );

    await tester.pumpWidget(
      ShadApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const Scaffold(body: VideoCard(video: video)),
      ),
    );

    expect(find.text('三体'), findsOneWidget);
    expect(find.text('播放'), findsOneWidget);
    expect(find.text('详情'), findsOneWidget);
  });

  testWidgets('VideoCard 在暗色主题下保持可渲染', (tester) async {
    const video = Video(
      id: 'v2',
      title: '流浪地球',
      description: '带着地球去流浪。',
      type: '科幻',
      siteId: 'site-2',
    );

    await tester.pumpWidget(
      ShadApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const Scaffold(body: VideoCard(video: video)),
      ),
    );

    final context = tester.element(find.text('流浪地球'));
    final theme = ShadTheme.of(context);

    expect(theme.brightness, Brightness.dark);
    expect(find.text('流浪地球'), findsOneWidget);
    expect(find.text('播放'), findsOneWidget);
  });

  testWidgets('SearchBar 渲染输入框和按钮', (tester) async {
    final controller = TextEditingController(text: '银河');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ShadApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: Scaffold(
          body: AppSearchBar(
            controller: controller,
            isSearching: false,
            onSubmitted: (_) {},
            onSearch: () {},
            buttonLabel: '执行搜索',
          ),
        ),
      ),
    );

    expect(find.text('执行搜索'), findsOneWidget);
    expect(find.text('银河'), findsOneWidget);
  });

  testWidgets('DanmakuSwitch 渲染状态文案', (tester) async {
    await tester.pumpWidget(
      ShadApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: Scaffold(
          body: DanmakuSwitch(
            value: true,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('弹幕开关'), findsOneWidget);
    expect(find.text('弹幕已开启'), findsOneWidget);
  });

  testWidgets('NavigationMenuCard 渲染导航项', (tester) async {
    await tester.pumpWidget(
      ShadApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const Scaffold(
          body: NavigationMenuCard(
            title: '快捷入口',
            description: '常用页面',
            items: <NavigationMenuItem>[
              NavigationMenuItem(
                label: '影视首页',
                route: '/film',
                icon: LucideIcons.clapperboard,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('快捷入口'), findsOneWidget);
    expect(find.text('影视首页'), findsOneWidget);
  });

  testWidgets('AppSearchBar 在窄屏下仍能展示核心内容', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = TextEditingController(text: '星际穿越');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ShadApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: AppSearchBar(
              controller: controller,
              isSearching: false,
              onSubmitted: (_) {},
              onSearch: () {},
              buttonLabel: '立即搜索',
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('星际穿越'), findsOneWidget);
    expect(find.text('立即搜索'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
