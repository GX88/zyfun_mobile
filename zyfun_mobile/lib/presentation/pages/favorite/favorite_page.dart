import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../data/models/favorite.dart';
import '../../components/app_bottom_nav_bar.dart';
import '../../providers/favorite_provider.dart';

class FavoritePage extends ConsumerStatefulWidget {
  const FavoritePage({super.key});

  @override
  ConsumerState<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends ConsumerState<FavoritePage> {
  String _selectedGroup = '全部';

  @override
  Widget build(BuildContext context) {
    final favoriteAsync = ref.watch(favoriteListProvider);
    final notifier = ref.read(favoriteListProvider.notifier);
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('收藏'),
        actions: <Widget>[
          IconButton(
            tooltip: '设置',
            onPressed: () => context.push('/setting'),
            icon: const Icon(LucideIcons.settings2),
          ),
        ],
      ),
      body: favoriteAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Text('暂无收藏内容', style: theme.textTheme.muted),
            );
          }

          final groups = _buildGroups(favorites);
          final visibleItems = _filterFavorites(favorites);

          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Text('分组', style: theme.textTheme.large),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: groups
                      .map(
                        (group) => ShadButton.outline(
                          onPressed: () => setState(() => _selectedGroup = group),
                          backgroundColor:
                              _selectedGroup == group ? theme.colorScheme.secondary : null,
                          child: Text(group),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text('共 ${visibleItems.length} 条收藏', style: theme.textTheme.muted),
                const SizedBox(height: 12),
                ...visibleItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FavoriteCard(
                      item: item,
                      groupLabel: _groupLabel(item),
                      onOpen: () => _openDetail(context, item),
                      onDelete: () => _deleteFavorite(context, notifier, item),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(error.toString(), style: theme.textTheme.muted),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 3),
    );
  }

  List<String> _buildGroups(List<Favorite> favorites) {
    final groups = <String>{'全部'};
    for (final item in favorites) {
      groups.add(_groupLabel(item));
    }
    return groups.toList();
  }

  List<Favorite> _filterFavorites(List<Favorite> favorites) {
    if (_selectedGroup == '全部') {
      return favorites;
    }
    return favorites.where((item) => _groupLabel(item) == _selectedGroup).toList();
  }

  String _groupLabel(Favorite item) {
    return item.siteId.isEmpty ? '未分组' : item.siteId;
  }

  void _openDetail(BuildContext context, Favorite item) {
    final uri = Uri(
      path: '/detail/${item.videoId}',
      queryParameters: <String, String>{
        'siteId': item.siteId,
        'title': item.title,
      },
    );
    context.push(uri.toString());
  }

  Future<void> _deleteFavorite(
    BuildContext context,
    FavoriteListNotifier notifier,
    Favorite item,
  ) async {
    await notifier.deleteFavorite(item.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text('已删除收藏 ${item.title}')),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.item,
    required this.groupLabel,
    required this.onOpen,
    required this.onDelete,
  });

  final Favorite item;
  final String groupLabel;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      title: Text(item.title, style: theme.textTheme.large),
      description: Text(groupLabel, style: theme.textTheme.muted),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '收藏时间 ${_formatCreatedAt(item.createdAt)}',
              style: theme.textTheme.small,
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                ShadButton(
                  onPressed: onOpen,
                  child: const Text('查看详情'),
                ),
                const SizedBox(width: 8),
                ShadButton.outline(
                  onPressed: onDelete,
                  child: const Text('删除收藏'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCreatedAt(int timestamp) {
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
