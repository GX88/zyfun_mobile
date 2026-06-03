import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../components/app_bottom_nav_bar.dart';
import '../../providers/setting_provider.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setting = ref.watch(settingNotifierProvider);
    final notifier = ref.read(settingNotifierProvider.notifier);
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ShadCard(
            title: Text('外观', style: theme.textTheme.h4),
            description: const Text('调整主题和基础显示选项。'),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('主题模式', style: theme.textTheme.large),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _ThemeModeButton(
                        label: '跟随系统',
                        selected: setting.theme == 'system',
                        onPressed: () => notifier.updateThemeMode('system'),
                      ),
                      _ThemeModeButton(
                        label: '浅色',
                        selected: setting.theme == 'light',
                        onPressed: () => notifier.updateThemeMode('light'),
                      ),
                      _ThemeModeButton(
                        label: '深色',
                        selected: setting.theme == 'dark',
                        onPressed: () => notifier.updateThemeMode('dark'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('硬件加速', style: theme.textTheme.large),
                      ),
                      ShadSwitch(
                        value: setting.hardwareAcceleration,
                        onChanged: (value) =>
                            notifier.updateHardwareAcceleration(value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ShadCard(
            title: Text('配置摘要', style: theme.textTheme.h4),
            description: const Text('当前仅展示关键配置，后续补齐完整设置项。'),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('语言：${setting.lang}'),
                  const SizedBox(height: 8),
                  Text('超时：${setting.timeout} ms'),
                  const SizedBox(height: 8),
                  Text('默认热搜：${setting.hot}'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 3),
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return ShadButton(onPressed: onPressed, child: Text(label));
    }
    return ShadButton.outline(onPressed: onPressed, child: Text(label));
  }
}
