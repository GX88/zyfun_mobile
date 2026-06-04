import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/constants/constants.dart';
import '../../../data/models/history.dart';
import '../../components/app_bar.dart';
import '../../components/buttons/app_buttons.dart';
import '../../components/texts.dart';
import '../../providers/history_provider.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyListProvider);
    final notifier = ref.read(historyListProvider.notifier);
    final isEmpty = historyAsync.valueOrNull?.isEmpty ?? true;
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: ZySectionAppBar(
        title: '历史记录',
        showBack: true,
        actions: <Widget>[
          IconButton(
            tooltip: _isEditing ? '完成' : '编辑',
            onPressed: isEmpty ? null : () => setState(() => _isEditing = !_isEditing),
            icon: Icon(
              _isEditing ? LucideIcons.check : LucideIcons.squarePen,
              size: AppIconSize.md,
            ),
          ),
          IconButton(
            tooltip: '清空历史',
            onPressed: isEmpty ? null : () => _confirmClearAll(context, notifier),
            icon: const Icon(LucideIcons.trash2, size: AppIconSize.md),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (histories) {
          if (histories.isEmpty) {
            return const Center(
              child: Padding(
                padding: AppSpacing.pageInsets,
                child: _HistoryEmptyState(),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: ListView.separated(
              padding: AppSpacing.pageInsets,
              itemCount: histories.length + 1,
              separatorBuilder: (_, index) => SizedBox(
                height: index == 0 ? AppSpacing.lg : AppSpacing.md,
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _HistorySummary(
                    totalCount: histories.length,
                    staleCount: histories.where((item) => item.isExpired).length,
                    latestLabel: _formatUpdatedAt(histories.first.updatedAt),
                  );
                }

                final item = histories[index - 1];
                return _HistoryCard(
                  item: item,
                  isEditing: _isEditing,
                  onContinue: () => _continueWatching(context, item),
                  onDelete: () => _deleteHistory(context, notifier, item),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: AppSpacing.pageInsets,
            child: SecondaryText(error.toString(), style: theme.textTheme.muted),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClearAll(
    BuildContext context,
    HistoryListNotifier notifier,
  ) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空历史'),
        content: const Text('确认清空全部播放历史吗？此操作不可撤销。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (shouldClear != true || !context.mounted) {
      return;
    }

    await notifier.clearAll();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('已清空播放历史')),
    );
  }

  void _continueWatching(BuildContext context, History item) {
    final uri = Uri(
      path: '/player/${item.videoId}',
      queryParameters: <String, String>{
        'title': item.title,
        'url': item.episodeUrl,
        'siteId': item.siteId,
        if (item.episodeName != null && item.episodeName!.isNotEmpty)
          'episode': item.episodeName!,
      },
    );
    context.push(uri.toString());
  }

  Future<void> _deleteHistory(
    BuildContext context,
    HistoryListNotifier notifier,
    History item,
  ) async {
    await notifier.deleteHistory(item.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text('已删除 ${item.title}')),
    );
  }
}

class _HistorySummary extends StatelessWidget {
  const _HistorySummary({
    required this.totalCount,
    required this.staleCount,
    required this.latestLabel,
  });

  final int totalCount;
  final int staleCount;
  final String latestLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.largeCard,
        boxShadow: AppShadows.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: AppRadius.button,
                ),
                child: const Icon(LucideIcons.history, color: Colors.white, size: AppIconSize.lg),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '观看记录',
                      style: AppTypography.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '最近更新 $latestLabel，保留继续观看位置与来源站点。',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: _SummaryMetric(label: '总记录', value: '$totalCount'),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SummaryMetric(label: '过期记录', value: '$staleCount'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: AppTypography.caption.copyWith(color: const Color(0xFFE2E8F0)),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.h2.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.item,
    required this.isEditing,
    required this.onContinue,
    required this.onDelete,
  });

  final History item;
  final bool isEditing;
  final VoidCallback onContinue;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = ShadTheme.of(context).brightness == Brightness.dark;
    final progressPercent = item.progressPercent.clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: isDark ? AppShadows.darkCard : AppShadows.md,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 112,
            height: 164,
            child: _HistoryCover(title: item.title, imageUrl: item.cover),
          ),
          Expanded(
            child: Padding(
              padding: AppSpacing.cardInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: PrimaryText(
                          item.title,
                          style: AppTypography.h3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.isExpired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: AppRadius.chip,
                          ),
                          child: Text(
                            '较早',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SecondaryText(item.episodeName ?? '继续观看'),
                  const SizedBox(height: AppSpacing.sm),
                  SecondaryText('来源 ${item.siteId.isEmpty ? '默认站点' : item.siteId}'),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: <Widget>[
                      const Icon(LucideIcons.clock3, size: AppIconSize.sm),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: SecondaryText(
                          '进度 ${item.progressText} / ${item.durationText}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xs)),
                    child: LinearProgressIndicator(
                      value: progressPercent == 0 ? 0.02 : progressPercent,
                      minHeight: 6,
                      backgroundColor: isDark
                          ? AppColors.surfaceSubtleDark
                          : AppColors.surfaceSubtle,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SecondaryText('上次观看 ${_formatUpdatedAt(item.updatedAt)}'),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: PrimaryButton(
                          onPressed: onContinue,
                          label: '继续观看',
                          size: AppButtonSize.small,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      if (isEditing)
                        SizedBox(
                          width: 44,
                          height: 36,
                          child: OutlinedButton(
                            onPressed: onDelete,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              side: BorderSide(
                                color: isDark ? AppColors.borderDark : AppColors.border,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                            ),
                            child: const Icon(LucideIcons.trash2, size: AppIconSize.sm),
                          ),
                        )
                      else
                        OutlineActionButton(
                          onPressed: onDelete,
                          label: '删除',
                          size: AppButtonSize.small,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = ShadTheme.of(context).brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.largeCard,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: isDark ? AppShadows.darkCard : AppShadows.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
            ),
            child: const Icon(LucideIcons.history, color: Colors.white, size: AppIconSize.lg),
          ),
          const SizedBox(height: AppSpacing.md),
          const PrimaryText('暂无播放历史', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.xs),
          const SecondaryText('开始播放后，系统会在这里保留观看位置与最近记录。'),
        ],
      ),
    );
  }
}

class _HistoryCover extends StatelessWidget {
  const _HistoryCover({required this.title, required this.imageUrl});

  final String title;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Text(
            title.isEmpty ? '记' : title.characters.first,
            style: AppTypography.h1.copyWith(color: Colors.white),
          ),
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: const Center(
          child: Icon(LucideIcons.imageOff, color: Colors.white, size: AppIconSize.xl),
        ),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          color: AppColors.primarySoft,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }
}

String _formatUpdatedAt(int timestamp) {
  if (timestamp <= 0) {
    return '未知时间';
  }

  final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final year = time.year.toString().padLeft(4, '0');
  final month = time.month.toString().padLeft(2, '0');
  final day = time.day.toString().padLeft(2, '0');
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}
