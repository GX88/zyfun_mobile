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
    final spotlightVideos = state.videos.take(3).toList(growable: false);
    final capabilityStats = <({String label, String value, String footnote})>[
      (label: '多源聚合', value: '${state.sites.length}', footnote: '当前可切换站点'),
      (label: '智能切换', value: '${state.categories.length}', footnote: '已加载分类'),
      (label: '状态监控', value: '${state.videos.length}', footnote: '可展示内容条数'),
      (label: '观看体验', value: 'HD', footnote: '优先流畅播放'),
    ];

    return Scaffold(
      appBar: ZySearchAppBar(
        placeholder: '搜索影视、演员、导演',
        onTap: () => context.push('/search'),
        actions: <Widget>[
          IconButton(
            tooltip: '历史',
            onPressed: () => context.push('/history'),
            icon: const Icon(LucideIcons.clock3, size: AppIconSize.md),
          ),
          IconButton(
            tooltip: '刷新',
            onPressed: notifier.loadSites,
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
                    const _BrandHeroSection(),
                    const SizedBox(height: AppSpacing.lg),
                    _CapabilityGrid(items: capabilityStats),
                    const SizedBox(height: AppSpacing.lg),
                    if (state.errorMessage != null) ...<Widget>[
                      _ErrorBanner(message: state.errorMessage!),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    _SiteControlSection(
                      sites: state.sites,
                      selectedSite: state.selectedSite,
                      isLoading: state.isLoading,
                      onTap: notifier.selectSite,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _CategoryTabSection(
                      categories: state.categories,
                      selectedCategoryId: state.selectedCategory?.id,
                      isLoading: state.isCategoryLoading,
                      onTap: notifier.loadVideosByCategory,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _ToolDashboardSection(
                      selectedSite: state.selectedSite,
                      categoryCount: state.categories.length,
                      videoCount: state.videos.length,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SpotlightSection(featured: featured),
                    const SizedBox(height: AppSpacing.lg),
                    const _QuickActionPanel(),
                    const SizedBox(height: AppSpacing.lg),
                    _RankingPanel(videos: spotlightVideos),
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

class _BrandHeroSection extends StatelessWidget {
  const _BrandHeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.largeCard,
        boxShadow: AppShadows.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  LucideIcons.sparkles,
                  color: Colors.white,
                  size: AppIconSize.lg,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'ZyFun',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      '多源高清 · 智能切换',
                      style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            '聚合多源影视与线路状态，优先帮助你更快找到、切换并稳定播放。',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: _HeroTag(
                  icon: LucideIcons.layers3,
                  label: '多源聚合',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _HeroTag(
                  icon: LucideIcons.activity,
                  label: '状态感知',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: AppRadius.card,
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: Colors.white, size: AppIconSize.sm),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CapabilityGrid extends StatelessWidget {
  const _CapabilityGrid({required this.items});

  final List<({String label, String value, String footnote})> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return StatCard(
          label: item.label,
          value: item.value,
          footnote: item.footnote,
        );
      },
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

class _SiteControlSection extends StatelessWidget {
  const _SiteControlSection({
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
        Row(
          children: <Widget>[
            const PrimaryText('线路控制台', style: AppTypography.h3),
            const Spacer(),
            StatusChip(
              label: selectedSite == null ? '未连接' : '已连接',
              tone: selectedSite == null ? StatusChipTone.warning : StatusChipTone.success,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        const SecondaryText('首页先突出线路选择与状态切换，而不是把内容流作为第一优先级。'),
        const SizedBox(height: AppSpacing.md),
        if (isLoading) const LinearProgressIndicator(),
        const SizedBox(height: AppSpacing.sm),
        if (sites.isEmpty && !isLoading)
          const FunctionCard(
            title: '暂无站点',
            description: '当前没有可展示站点，稍后下拉刷新重试。',
            icon: LucideIcons.circleOff,
            onTap: _noop,
          )
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: sites
                .map(
                  (site) => AppChip(
                    label: site.name,
                    selected: selectedSite?.id == site.id,
                    onTap: () => onTap(site),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _CategoryTabSection extends StatelessWidget {
  const _CategoryTabSection({
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
            const PrimaryText('分类切换', style: AppTypography.h3),
            const Spacer(),
            if (isLoading)
              const SizedBox(
                width: AppIconSize.sm,
                height: AppIconSize.sm,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryChip(
                label: category.name,
                selected: selectedCategoryId == category.id,
                onTap: () => onTap(category.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ToolDashboardSection extends StatelessWidget {
  const _ToolDashboardSection({
    required this.selectedSite,
    required this.categoryCount,
    required this.videoCount,
  });

  final Site? selectedSite;
  final int categoryCount;
  final int videoCount;

  @override
  Widget build(BuildContext context) {
    final cards = <({String title, String value, String description, StatusChipTone tone})>[
      (
        title: '当前线路',
        value: selectedSite?.name ?? '未选择',
        description: '默认进入站点',
        tone: StatusChipTone.info,
      ),
      (
        title: '源状态监控',
        value: categoryCount > 0 ? '正常' : '待加载',
        description: '$categoryCount 个分类已同步',
        tone: categoryCount > 0 ? StatusChipTone.success : StatusChipTone.warning,
      ),
      (
        title: '资源索引',
        value: '$videoCount',
        description: '当前可视内容条数',
        tone: StatusChipTone.warning,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const PrimaryText('首页监控面板', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.xs),
        const SecondaryText('这一区在设计上更像源状态与能力总览，而不是普通推荐列表。'),
        const SizedBox(height: AppSpacing.md),
        Column(
          children: cards
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _DashboardCard(item: item),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.item});

  final ({String title, String value, String description, StatusChipTone tone}) item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        boxShadow: isDark ? AppShadows.darkCard : AppShadows.sm,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SecondaryText(item.title),
                const SizedBox(height: AppSpacing.xs),
                PrimaryText(
                  item.value,
                  style: AppTypography.h3,
                ),
                const SizedBox(height: AppSpacing.xs),
                CaptionText(item.description),
              ],
            ),
          ),
          StatusChip(label: _toneLabel(item.tone), tone: item.tone),
        ],
      ),
    );
  }

  String _toneLabel(StatusChipTone tone) {
    switch (tone) {
      case StatusChipTone.success:
        return '正常';
      case StatusChipTone.warning:
        return '监控';
      case StatusChipTone.danger:
        return '异常';
      case StatusChipTone.info:
        return '已选';
    }
  }
}

class _SpotlightSection extends StatelessWidget {
  const _SpotlightSection({required this.featured});

  final Video? featured;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const PrimaryText('今日推荐', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.xs),
        const SecondaryText('内容区保留，但退到工具型首页的第二层级。'),
        const SizedBox(height: AppSpacing.md),
        if (featured == null)
          const FunctionCard(
            title: '推荐内容加载中',
            description: '当前尚未拿到演示内容，稍后会自动补齐推荐区域。',
            icon: LucideIcons.loaderCircle,
            onTap: _noop,
          )
        else
          HeroBannerCard(
            title: featured!.title,
            description: featured!.description ?? '当前由演示数据生成的推荐大卡位。',
            imageUrl: featured!.cover,
            badge: featured!.type ?? '推荐',
            onTap: () {
              context.push(
                Uri(
                  path: '/detail/${featured!.id}',
                  queryParameters: <String, String>{
                    'siteId': featured!.siteId,
                    'title': featured!.title,
                  },
                ).toString(),
              );
            },
          ),
      ],
    );
  }
}

class _QuickActionPanel extends StatelessWidget {
  const _QuickActionPanel();

  @override
  Widget build(BuildContext context) {
    const actions = <({String title, String subtitle, IconData icon, String route})>[
      (
        title: '快速探索',
        subtitle: '切换分类与榜单',
        icon: LucideIcons.compass,
        route: '/search',
      ),
      (
        title: '直播入口',
        subtitle: '查看频道与节目单',
        icon: LucideIcons.tv,
        route: '/live',
      ),
      (
        title: '历史记录',
        subtitle: '继续上次播放',
        icon: LucideIcons.history,
        route: '/history',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const PrimaryText('核心入口', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.md),
        Column(
          children: actions
              .map(
                (action) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: FunctionCard(
                    title: action.title,
                    description: action.subtitle,
                    icon: action.icon,
                    onTap: () => context.push(action.route),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _RankingPanel extends StatelessWidget {
  const _RankingPanel({required this.videos});

  final List<Video> videos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const PrimaryText('热门榜单', style: AppTypography.h3),
            const Spacer(),
            LinkActionButton(
              label: '全部',
              size: AppButtonSize.small,
              onPressed: () => context.push('/search'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (videos.isEmpty)
          const SecondaryText('暂无榜单数据')
        else
          Column(
            children: List<Widget>.generate(videos.length, (index) {
              final video = videos[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _RankingRow(rank: index + 1, video: video),
              );
            }),
          ),
      ],
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.rank, required this.video});

  final int rank;
  final Video video;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () {
          context.push(
            Uri(
              path: '/detail/${video.id}',
              queryParameters: <String, String>{
                'siteId': video.siteId,
                'title': video.title,
              },
            ).toString(),
          );
        },
        child: Ink(
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
            boxShadow: isDark ? AppShadows.darkCard : AppShadows.sm,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.quickActionGradients[(rank - 1) % AppColors.quickActionGradients.length],
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$rank',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    PrimaryText(
                      video.title,
                      style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SecondaryText(
                      video.description ?? video.actor ?? '热门资源推荐',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              StatusChip(label: video.type ?? '影视', tone: StatusChipTone.info),
            ],
          ),
        ),
      ),
    );
  }
}

void _noop() {}
