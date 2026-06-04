import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zyfun_mobile/presentation/pages/sniffer/sniffer_page.dart';
import 'package:zyfun_mobile/presentation/providers/app_providers.dart';
import 'package:zyfun_mobile/services/sniffer_service.dart';
import 'package:zyfun_mobile/theme/app_theme.dart';

void main() {
  testWidgets('SnifferPage 支持输入地址并触发加载', (tester) async {
    final service = _FakeSnifferService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          snifferServiceProvider.overrideWithValue(service),
        ],
        child: const _TestApp(
          child: SnifferPage(initialUrl: 'https://example.com'),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('WebView 嗅探容器'), findsOneWidget);
    expect(service.controller.loadedUrls, <String>['https://example.com']);

    await tester.enterText(find.byType(ShadInput).first, 'https://video.example.com');
    await tester.tap(find.text('加载页面'));
    await tester.pump();

    expect(service.controller.loadedUrls.last, 'https://video.example.com');
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: child,
    );
  }
}

class _FakeSnifferService extends SnifferService {
  _FakeSnifferService();

  final _FakeSnifferViewController controller = _FakeSnifferViewController();

  @override
  SnifferViewController createController() => controller;
}

class _FakeSnifferViewController implements SnifferViewController {
  final ValueNotifier<SnifferViewState> _state =
      const SnifferViewState(currentUrl: '').toNotifier();
  final List<String> loadedUrls = <String>[];

  @override
  ValueListenable<SnifferViewState> get stateListenable => _state;

  @override
  Widget buildView() => const ColoredBox(color: Colors.black12, child: SizedBox.expand());

  @override
  Future<void> dispose() async {
    _state.dispose();
  }

  @override
  Future<void> goBack() async {}

  @override
  Future<void> goForward() async {}

  @override
  Future<void> loadUrl(String url) async {
    loadedUrls.add(url);
    _state.value = _state.value.copyWith(currentUrl: url, isLoading: false, clearError: true);
  }

  @override
  Future<void> reload() async {}
}

extension on SnifferViewState {
  ValueNotifier<SnifferViewState> toNotifier() => ValueNotifier<SnifferViewState>(this);
}
