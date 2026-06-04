import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zyfun_mobile/presentation/components/player_danmaku_overlay.dart';
import 'package:zyfun_mobile/presentation/providers/danmaku_provider.dart';
import 'package:zyfun_mobile/theme/app_theme.dart';

void main() {
  testWidgets('PlayerDanmakuOverlay 只显示当前时间窗口内的弹幕', (tester) async {
    await tester.pumpWidget(
      ShadApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const Scaffold(
          body: PlayerDanmakuOverlay(
            enabled: true,
            position: Duration(seconds: 9),
            items: <DanmakuItem>[
              DanmakuItem(text: '第一条', time: Duration(seconds: 2)),
              DanmakuItem(text: '第二条', time: Duration(seconds: 8)),
              DanmakuItem(text: '第三条', time: Duration(seconds: 20)),
            ],
          ),
        ),
      ),
    );

    expect(find.text('第一条'), findsNothing);
    expect(find.text('第二条'), findsOneWidget);
    expect(find.text('第三条'), findsNothing);
  });

  testWidgets('PlayerDanmakuOverlay 关闭时不渲染弹幕', (tester) async {
    await tester.pumpWidget(
      ShadApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const Scaffold(
          body: PlayerDanmakuOverlay(
            enabled: false,
            position: Duration(seconds: 9),
            items: <DanmakuItem>[
              DanmakuItem(text: '第二条', time: Duration(seconds: 8)),
            ],
          ),
        ),
      ),
    );

    expect(find.text('第二条'), findsNothing);
  });
}
