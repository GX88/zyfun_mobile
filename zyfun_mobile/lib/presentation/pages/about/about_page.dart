import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/constants/constants.dart';
import '../../components/app_bar.dart';
import '../../components/buttons/app_buttons.dart';
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
          Container(
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppRadius.largeCard,
              boxShadow: AppShadows.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: AppRadius.button,
                  ),
                  child: const Icon(LucideIcons.info, color: Colors.white, size: AppIconSize.lg),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '关于 zyfun',
                  style: AppTypography.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '聚焦影视、直播与播放器体验的移动端实验实现，当前阶段优先完成 UI 重构。',
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          StatCard(
            label: '应用版本',
            value: setting.version,
            footnote: '面向 Android / iOS 的移动端实验实现。',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: PrimaryButton(
                  label: '检查更新',
                  onPressed: () => _showNotice(context, '当前没有可用更新，这里先保留 UI 入口。'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlineActionButton(
                  label: '开源协议',
                  onPressed: () => _showNotice(context, '后续可接入协议详情页或 licenses 页面。'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          FunctionCard(
            title: '当前能力',
            description: '聚焦影视、直播、解析、收藏与历史等移动端核心能力。',
            icon: LucideIcons.chevronRight,
            onTap: () => _showNotice(context, '当前版本以 UI 骨架和核心页面重构为主。'),
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
                PrimaryText('开源协议说明', style: AppTypography.h3),
                SizedBox(height: AppSpacing.sm),
                SecondaryText('应用基于 Flutter 与多个开源库构建。正式版本中应提供依赖清单、许可证类型与跳转入口。'),
                SizedBox(height: AppSpacing.md),
                _InfoLine(label: 'Flutter', value: 'UI 框架与跨平台运行时'),
                _InfoLine(label: 'Riverpod', value: '状态管理'),
                _InfoLine(label: 'shadcn_ui', value: '基础组件与视觉能力'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(message)));
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
