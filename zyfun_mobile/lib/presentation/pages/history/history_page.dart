import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../data/models/history.dart';
import '../../components/app_bottom_nav_bar.dart';
import '../../providers/history_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyListProvider);
    final notifier = ref.read(historyListProvider.notifier);
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史'),
        actions: <Widget>[
          IconButton(
            tooltip: '清空历史',
            onPressed: historyAsync.valueOrNull?.isEmpty ?? true
                ? null
                : () => _confirmClearAll(context, notifier),
            icon: const Icon(LucideIcons.trash2),
          ),
          IconButton(
            tooltip: '设置',
            onPressed: () => context.push('/setting'),
            icon: const Icon(LucideIcons.settings2),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (histories) {
          if (histories.isEmpty) {
            return Center(
              child: Text('暂无播放历史', style: theme.textTheme.muted),
            );
          }

          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: histories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = histories[index];
                return _HistoryCard(
                  item: item,
                  onContinue: () => _continueWatching(context, item),
                  onDelete: () => _deleteHistory(context, notifier, item),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(error.toString(), style: theme.textTheme.muted),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 2),
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

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.item,
    required this.onContinue,
    required this.onDelete,
  });

  final History item;
  final VoidCallback onContinue;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      title: Text(item.title, style: theme.textTheme.large),
      description: Text(item.episodeName ?? '继续观看', style: theme.textTheme.muted),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('进度 ${item.progressText} / ${item.durationText}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: item.progressPercent),
            const SizedBox(height: 12),
            Text(
              '上次观看 ${_formatUpdatedAt(item.updatedAt)}',
              style: theme.textTheme.small,
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                ShadButton(
                  onPressed: onContinue,
                  child: const Text('继续观看'),
                ),
                const SizedBox(width: 8),
                ShadButton.outline(
                  onPressed: onDelete,
                  child: const Text('删除'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
}
