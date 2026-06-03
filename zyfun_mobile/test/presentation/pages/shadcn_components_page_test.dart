import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zyfun_mobile/presentation/pages/shadcn/shadcn_components_page.dart';
import 'package:zyfun_mobile/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ShadcnComponentsPage 渲染核心组件分组', (tester) async {
    await tester.pumpWidget(
      ShadApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const ShadcnComponentsPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Shadcn 组件库'), findsOneWidget);
    expect(find.text('组件概览'), findsOneWidget);
    expect(find.text('交互组件'), findsWidgets);
    expect(find.text('表格与菜单'), findsOneWidget);
    expect(find.text('打开确认对话框'), findsOneWidget);

    await tester.tap(find.text('表单'));
    await tester.pumpAndSettle();

    expect(find.text('表单组件'), findsOneWidget);
    expect(find.text('保存表单'), findsOneWidget);
  });

  testWidgets('ShadcnComponentsPage 在窄屏下可以完成基础渲染', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ShadApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const ShadcnComponentsPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Shadcn 组件库'), findsOneWidget);
    expect(find.text('组件概览'), findsOneWidget);
    expect(find.text('交互组件'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
