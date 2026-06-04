import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zyfun_mobile/data/models/analyze.dart';
import 'package:zyfun_mobile/domain/repositories/analyze_repository.dart';
import 'package:zyfun_mobile/presentation/pages/parse/parse_page.dart';
import 'package:zyfun_mobile/presentation/providers/app_providers.dart';
import 'package:zyfun_mobile/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ParsePage 渲染解析列表并支持切换默认项', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repository = _FakeAnalyzeRepository(
      analyzes: <Analyze>[
        _buildAnalyze(id: 'a1', name: '线路一', api: 'https://example.com/1'),
        _buildAnalyze(id: 'a2', name: '线路二', api: 'https://example.com/2'),
      ],
      defaultAnalyzeId: 'a1',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyzeRepositoryProvider.overrideWithValue(repository),
        ],
        child: const _TestParseApp(child: ParsePage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('默认解析'), findsOneWidget);
    expect(find.text('线路一'), findsWidgets);
    expect(find.text('线路二'), findsOneWidget);

    await tester.tap(find.widgetWithText(ShadButton, '设为默认').last);
    await tester.pumpAndSettle();

    expect(repository.defaultAnalyzeId, 'a2');
  });

  testWidgets('ParsePage 支持新增解析接口', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repository = _FakeAnalyzeRepository(
      analyzes: <Analyze>[
        _buildAnalyze(id: 'a1', name: '线路一', api: 'https://example.com/1'),
      ],
      defaultAnalyzeId: 'a1',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          analyzeRepositoryProvider.overrideWithValue(repository),
        ],
        child: const _TestParseApp(child: ParsePage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('新增解析'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(ShadInput).at(0), '自建解析');
    await tester.enterText(find.byType(ShadInput).at(1), 'https://example.com/parse');
    await tester.enterText(find.byType(ShadInput).at(2), 'm3u8, mp4');
    await tester.enterText(find.byType(ShadInput).at(3), 'return data.url;');

    await tester.tap(find.widgetWithText(ShadButton, '新增'));
    await tester.pumpAndSettle();

    expect(repository.analyzes.length, 2);
    expect(repository.analyzes.any((item) => item.name == '自建解析'), isTrue);
  });
}

class _TestParseApp extends StatelessWidget {
  const _TestParseApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/parse',
      routes: <RouteBase>[
        GoRoute(
          path: '/parse',
          builder: (context, state) => child,
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

Analyze _buildAnalyze({
  required String id,
  required String name,
  required String api,
}) {
  return Analyze(
    id: id,
    key: id,
    name: name,
    api: api,
    type: 2,
    flag: const <String>['m3u8'],
    script: '',
    createdAt: 1,
    updatedAt: 1,
  );
}

class _FakeAnalyzeRepository implements AnalyzeRepository {
  _FakeAnalyzeRepository({
    required List<Analyze> analyzes,
    required this.defaultAnalyzeId,
  }) : analyzes = List<Analyze>.from(analyzes);

  final List<Analyze> analyzes;
  String? defaultAnalyzeId;

  @override
  Future<void> addAnalyze(Analyze analyze) async {
    analyzes.add(analyze);
  }

  @override
  Future<void> deleteAnalyze(String id) async {
    analyzes.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<Analyze>> getAllAnalyzes() async => List<Analyze>.from(analyzes);

  @override
  Future<Analyze?> getAnalyzeById(String id) async {
    return analyzes.where((item) => item.id == id).cast<Analyze?>().firstWhere(
          (item) => item != null,
          orElse: () => null,
        );
  }

  @override
  Future<String?> getDefaultAnalyze() async => defaultAnalyzeId;

  @override
  Future<void> setDefaultAnalyze(String id) async {
    defaultAnalyzeId = id;
  }

  @override
  Future<void> updateAnalyze(Analyze analyze) async {
    final index = analyzes.indexWhere((item) => item.id == analyze.id);
    if (index >= 0) {
      analyzes[index] = analyze;
    }
  }
}
