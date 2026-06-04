import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/constants/constants.dart';
import '../../components/app_bar.dart';
import '../../components/cards/app_cards.dart';
import '../../components/texts.dart';
import '../../providers/setting_provider.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setting = ref.watch(settingNotifierProvider);

    return Scaffold(
      appBar: const ZySectionAppBar(title: '关于', showBack: true),
      body: ListView(
        padding: AppSpacing.pageInsets,
        children: <Widget>[
          StatCard(
            label: 'zyfun Flutter Mobile',
            value: setting.version,
            footnote: '面向 Android / iOS 的移动端实验实现。',
          ),
          const SizedBox(height: AppSpacing.lg),
          FunctionCard(
            title: '当前能力',
            description: '聚焦影视、直播、解析、收藏与历史等移动端核心能力。',
            icon: LucideIcons.chevronRight,
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : AppColors.surface,
              borderRadius: AppRadius.card,
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderDark
                    : AppColors.border,
              ),
              boxShadow: Theme.of(context).brightness == Brightness.dark
                  ? AppShadows.darkCard
                  : AppShadows.md,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PrimaryText('后续规划', style: AppTypography.h3),
                SizedBox(height: AppSpacing.sm),
                SecondaryText('保留当前阶段未完成功能的明确说明。'),
                SizedBox(height: AppSpacing.lg),
                _InfoLine(label: '后台播放', value: '计划在 13.6 阶段接入 audio_service'),
                _InfoLine(label: 'PIP', value: '计划在 13.6 阶段接入原生画中画'),
                _InfoLine(label: 'AI', value: '当前先提供本地推荐入口，后续接真实模型服务'),
              ],
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: PrimaryText('$label：$value'),
    );
  }
}
