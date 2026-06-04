import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/constants/constants.dart';
import '../../../data/models/site.dart';
import '../../../data/models/video.dart';
import '../../../domain/repositories/site_repository.dart';
import '../../components/app_bar.dart';
import '../../components/app_bottom_nav_bar.dart';
import '../../components/buttons/app_buttons.dart';
import '../../components/cards/app_cards.dart';
import '../../components/chips/app_chips.dart';
import '../../components/texts.dart';
import '../../providers/site_provider.dart';

class FilmPage extends ConsumerStatefulWidget {
  const FilmPage({super.key});

  @override
  ConsumerState<FilmPage> createState() => _FilmPageState();
}

class _FilmPageState extends ConsumerState<FilmPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(siteNotifierProvider.notifier).loadSites(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(siteNotifierProvider);
    final notifier = ref.read(siteNotifierProvider.notifier);
    final featured = state.videos.isNotEmpty
        ? state.videos.first
        : state.searchResults.isNotEmpty
            ? state.searchResults.first
            : null;
    final continueWatching = state.searchResults.isNotEmpty
        ? state.searchResults.take(4).toList()
        : state.videos.skip(1).take(4).toList();

    return Scaffold(
      appBar: ZySearchAppBar(
        placeholder: '搜索剧集、演员、导演',
        onTap: () => context.push('/search'),
        actions: <Widget>[
          IconButton(
            tooltip: '历史',
            onPressed: () => context.push('/history'),
            icon: const Icon(LucideIcons.clock3, size: AppIconSize.md),
          ),
          IconButton(
            tooltip: '刷新',
            onPressed: () => notifier.loadSites(),
            icon: const Icon(LucideIcons.refreshCw, size: AppIconSize.md),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.loadSites,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverPadding(
              padding: AppSpacing.pageInsets,
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    if (state.errorMessage != null) ...<Widget>[
                      _ErrorBanner(message: state.errorMessage!),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    _SiteSelectorSection(
                      sites: state.sites,
                      selectedSite: state.selectedSite,
                      isLoading: state.isLoading,
                      onTap: notifier.selectSite,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _CategorySection(
                      categories: state.categories,
                      selectedCategoryId: state.selectedCategory?.id,
                      isLoading: state.isCategoryLoading,
                      onTap: notifier.loadVideosByCategory,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _HeroSection(
                      featured: featured,
                      selectedSite: state.selectedSite,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _QuickActionsSection(),
                    const SizedBox(height: AppSpacing.lg),
                    _ContinueWatchingSection(videos: continueWatching),
                    const SizedBox(height: AppSpacing.lg),
                    _SourceStatusSection(
                      selectedSite: state.selectedSite,
                      categoryCount: state.categories.length,
                      videoCount: state.videos.length,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _LatestResultSection(videos: state.videos),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 0),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: AppRadius.card,
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(LucideIcons.circleAlert, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: SecondaryText(
              message,
              style: AppTypography.bodySmall.copyWith(color: const Color(0xFF991B1B)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SiteSelectorSection extends StatelessWidget {
  const _SiteSelectorSection({
    required this.sites,
    required this.selectedSite,
    required this.isLoading,
    required this.onTap,
  });

  final List<Site> sites;
  final Site? selectedSite;
  final bool isLoading;
  final ValueChanged<Site> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const PrimaryText('站点切换', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.xs),
        const SecondaryText('优先展示视觉层级，暂不考虑真实内容差异。'),
        const SizedBox(height: AppSpacing.md),
        if (isLoading) const LinearProgressIndicator(),
        if (sites.isEmpty && !isLoading)
          const FunctionCard(
            title: '暂无站点',
            description: '当前没有可展示站点，稍后下拉刷新重试。',
            icon: LucideIcons.circleOff,
            onTap: _noop,
          )
        else
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final site = sites[index];
                final selected = selectedSite?.id == site.id;
                return _SitePillCard(
                  site: site,
                  selected: selected,
                  onTap: () => onTap(site),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemCount: sites.length,
            ),
          ),
      ],
    );
  }
}

class _SitePillCard extends StatelessWidget {
  const _SitePillCard({
    required this.site,
    required this.selected,
    required this.onTap,
  });

  final Site site;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Ink(
          width: 180,
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primarySoft
                : (isDark ? AppColors.surfaceDark : AppColors.surface),
            borderRadius: AppRadius.card,
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.border),
            ),
            boxShadow: isDark ? AppShadows.darkCard : AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: PrimaryText(
                      site.name,
                      style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selected)
                    const Icon(LucideIcons.badgeCheck, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              SecondaryText(site.typeName),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.categories,
    required this.selectedCategoryId,
    required this.isLoading,
    required this.onTap,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final bool isLoading;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const PrimaryText('分类导航', style: AppTypography.h3),
            const Spacer(),
            if (isLoading)
              const SizedBox(
                width: AppIconSize.sm,
                height: AppIconSize.sm,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (categories.isEmpty)
          const SecondaryText('当前站点暂无分类')
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: categories
                .map(
                  (category) => CategoryChip(
                    label: category.name,
                    selected: selectedCategoryId == category.id,
                    onTap: () => onTap(category.id),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.featured, required this.selectedSite});

  final Video? featured;
  final Site? selectedSite;

  @override
  Widget build(BuildContext context) {
    if (featured == null) {
      return const FunctionCard(
        title: '推荐内容加载中',
        description: '当前尚未拿到演示内容，稍后会自动补齐推荐区域。',
        icon: LucideIcons.loaderCircle,
        onTap: _noop,
      );
    }

    final item = featured!;

    return HeroBannerCard(
      title: item.title,
      description: item.description ?? '当前由演示数据生成的推荐大卡位。',
      imageUrl: item.cover,
      badge: selectedSite?.name ?? '今日推荐',
      onTap: () {
        context.push(
          Uri(
            path: '/detail/${item.id}',
            queryParameters: <String, String>{
              'siteId': item.siteId,
              'title': item.title,
            },
          ).toString(),
        );
      },
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    const items = <({String title, IconData icon, String route})>[
      (title: '电视剧', icon: LucideIcons.tv2, route: '/film'),
      (title: '电影', icon: LucideIcons.clapperboard, route: '/film'),
      (title: '综艺', icon: LucideIcons.mic2, route: '/film'),
      (title: '动漫', icon: LucideIcons.sparkles, route: '/film'),
      (title: '纪录片', icon: LucideIcons.earth, route: '/film'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const PrimaryText('快捷入口', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: List<Widget>.generate(items.length, (index) {
            final item = items[index];
            final gradient = AppColors.quickActionGradients[index];
            return Expanded(
              child: GestureDetector(
                onTap: () => context.push(item.route),
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == items.length - 1 ? 0 : AppSpacing.sm,
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: gradient,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.sm,
                        ),
                        child: Icon(item.icon, color: Colors.white, size: AppIconSize.lg),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        item.title,
                        style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ContinueWatchingSection extends StatelessWidget {
  const _ContinueWatchingSection({required this.videos});

  final List<Video> videos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const PrimaryText('继续观看', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.xs),
        const SecondaryText('先用已有演示数据模拟最近继续观看区域。'),
        const SizedBox(height: AppSpacing.md),
        if (videos.isEmpty)
          const SecondaryText('暂无继续观看内容')
        else
          SizedBox(
            height: 332,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: videos.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 240,
                  child: VideoCard(video: videos[index]),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SourceStatusSection extends StatelessWidget {
  const _SourceStatusSection({
    required this.selectedSite,
    required this.categoryCount,
    required this.videoCount,
  });

  final Site? selectedSite;
  final int categoryCount;
  final int videoCount;

  @override
  Widget build(BuildContext context) {
    final sourceName = selectedSite?.name ?? '未选择站点';
    final statuses = <({String title, String value, StatusChipTone tone})>[
      (title: '当前线路', value: sourceName, tone: StatusChipTone.info),
      (title: '分类数量', value: '$categoryCount 个', tone: StatusChipTone.success),
      (title: '内容数量', value: '$videoCount 条', tone: StatusChipTone.warning),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const PrimaryText('源状态监控', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.xs),
        const SecondaryText('突出设计稿中的工具属性，先以本地状态做可视化展示。'),
        const SizedBox(height: AppSpacing.md),
        Column(
          children: statuses
              .map(
                (status) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _StatusRow(
                    title: status.title,
                    value: status.value,
                    tone: status.tone,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.title,
    required this.value,
    required this.tone,
  });

  final String title;
  final String value;
  final StatusChipTone tone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: isDark ? AppShadows.darkCard : AppShadows.sm,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PrimaryText(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                SecondaryText(value),
              ],
            ),
          ),
          StatusChip(label: _statusLabel(tone), tone: tone),
        ],
      ),
    );
  }

  String _statusLabel(StatusChipTone tone) {
    switch (tone) {
      case StatusChipTone.success:
        return '正常';
      case StatusChipTone.warning:
        return '活跃';
      case StatusChipTone.danger:
        return '异常';
      case StatusChipTone.info:
        return '已选';
    }
  }
}

class _LatestResultSection extends StatelessWidget {
  const _LatestResultSection({required this.videos});

  final List<Video> videos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const PrimaryText('最近更新', style: AppTypography.h3),
            const Spacer(),
            LinkActionButton(
              label: '查看更多',
              size: AppButtonSize.small,
              onPressed: () => context.push('/search'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (videos.isEmpty)
          const SecondaryText('暂无更新内容')
        else
          Column(
            children: videos
                .take(4)
                .map(
                  (video) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: VideoCard(video: video),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

void _noop() {}
