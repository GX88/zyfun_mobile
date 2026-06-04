import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/constants/constants.dart';
import '../../../data/models/favorite.dart';
import '../../components/app_bar.dart';
import '../../components/buttons/app_buttons.dart';
import '../../components/texts.dart';
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

    return Scaffold(
      appBar: ZySectionAppBar(
        title: '我的收藏',
        showBack: true,
        actions: <Widget>[
          IconButton(
            tooltip: '刷新',
            onPressed: notifier.refresh,
            icon: const Icon(LucideIcons.refreshCcw, size: AppIconSize.md),
          ),
        ],
      ),
      body: favoriteAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return const Center(
              child: Padding(
                padding: AppSpacing.pageInsets,
                child: _FavoriteEmptyState(),
              ),
            );
          }

          final groups = _buildGroups(favorites);
          final visibleItems = _filterFavorites(favorites);

          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: ListView(
              padding: AppSpacing.pageInsets,
              children: <Widget>[
                _FavoriteHero(totalCount: favorites.length),
                const SizedBox(height: AppSpacing.lg),
                PrimaryText('收藏分组', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: groups
                      .map(
                        (group) => _GroupChip(
                          label: group,
                          selected: _selectedGroup == group,
                          onPressed: () => setState(() => _selectedGroup = group),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: <Widget>[
                    PrimaryText('条目 ${visibleItems.length}', style: AppTypography.h3),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: SecondaryText('长按前无需进入详情，直接管理常用收藏。'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.62,
                  ),
                  itemBuilder: (context, index) {
                    final item = visibleItems[index];
                    return _FavoriteCard(
                      item: item,
                      groupLabel: _groupLabel(item),
                      onOpen: () => _openDetail(context, item),
                      onDelete: () => _deleteFavorite(context, notifier, item),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: AppSpacing.pageInsets,
            child: SecondaryText(error.toString()),
          ),
        ),
      ),
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
    final isDark = ShadTheme.of(context).brightness == Brightness.dark;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: onOpen,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _FavoriteCover(title: item.title, imageUrl: item.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Color(0x000F172A), Color(0xCC0F172A)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.sm,
                    right: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.32),
                            borderRadius: AppRadius.chip,
                          ),
                          child: Text(
                            groupLabel,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: AppSpacing.cardInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SecondaryText('收藏于 ${_formatCreatedAt(item.createdAt)}'),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PrimaryButton(
                        onPressed: onOpen,
                        label: '查看',
                        size: AppButtonSize.small,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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

class _FavoriteHero extends StatelessWidget {
  const _FavoriteHero({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.largeCard,
        boxShadow: AppShadows.lg,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: AppRadius.button,
            ),
            child: const Icon(LucideIcons.star, color: Colors.white, size: AppIconSize.lg),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '收藏片单',
                  style: AppTypography.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '共 $totalCount 条内容，按站点快速归类，便于稍后继续观看。',
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  const _GroupChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = ShadTheme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primarySoft
              : (isDark ? AppColors.surfaceDark : AppColors.surface),
          borderRadius: AppRadius.chip,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _FavoriteEmptyState extends StatelessWidget {
  const _FavoriteEmptyState();

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
            child: const Icon(LucideIcons.starOff, color: Colors.white, size: AppIconSize.lg),
          ),
          const SizedBox(height: AppSpacing.md),
          const PrimaryText('还没有收藏内容', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.xs),
          const SecondaryText('看到感兴趣的影片后，可以从详情页加入收藏。'),
        ],
      ),
    );
  }
}

class _FavoriteCover extends StatelessWidget {
  const _FavoriteCover({required this.title, required this.imageUrl});

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
            title.isEmpty ? '收藏' : title.characters.first,
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
