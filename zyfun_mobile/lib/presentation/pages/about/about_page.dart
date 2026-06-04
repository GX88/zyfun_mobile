import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../components/app_bottom_nav_bar.dart';
import '../../providers/setting_provider.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final setting = ref.watch(settingNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ShadCard(
            title: Text('zyfun Flutter Mobile', style: theme.textTheme.h3),
            description: const Text('面向 Android / iOS 的移动端实验实现。'),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('版本：${setting.version}'),
                  const SizedBox(height: 8),
                  Text('主题模式：${setting.theme}'),
                  const SizedBox(height: 8),
                  Text('语言：${setting.lang}'),
                  const SizedBox(height: 8),
                  Text('播放器：${setting.player?.type ?? 'media_kit'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ShadCard(
            title: Text('当前能力', style: theme.textTheme.h4),
            description: const Text('聚焦影视、直播、解析、收藏与历史等移动端核心能力。'),
            child: const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _InfoLine(label: '影视', value: '站点切换、分类浏览、详情播放'),
                  _InfoLine(label: '直播', value: '频道分组、节目单、回看入口'),
                  _InfoLine(label: '本地数据', value: '历史、收藏、配置导入导出'),
                  _InfoLine(label: '播放器', value: 'media_kit 内核，已支持全屏与横屏'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ShadCard(
            title: Text('后续规划', style: theme.textTheme.h4),
            description: const Text('保留当前阶段未完成功能的明确说明。'),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _InfoLine(label: '后台播放', value: '计划在 13.6 阶段接入 audio_service'),
                  _InfoLine(label: 'PIP', value: '计划在 13.6 阶段接入原生画中画'),
                  _InfoLine(label: 'AI', value: '当前先提供本地推荐入口，后续接真实模型服务'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 4),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label：$value'),
    );
  }
}
