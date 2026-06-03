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
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史'),
        actions: <Widget>[
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

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: histories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = histories[index];
              return _HistoryCard(item: item);
            },
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
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final History item;

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
          ],
        ),
      ),
    );
  }
}
