import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/constants/constants.dart';
import '../../../data/models/video.dart';
import '../../../domain/repositories/site_repository.dart';
import '../../components/app_bar.dart';
import '../../components/app_bottom_nav_bar.dart';
import '../../components/cards/app_cards.dart';
import '../../components/chips/app_chips.dart';
import '../../components/texts.dart';
import '../../providers/site_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _controller;
  final List<String> _recentKeywords = <String>['国漫', '悬疑', '纪录片'];
  String _selectedYear = '全部';
  String _selectedRegion = '全部';
  String _selectedKind = '推荐';

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(siteNotifierProvider);
    _controller = TextEditingController(text: initialState.searchKeyword);
    if (initialState.sites.isEmpty) {
      Future<void>.microtask(
        () => ref.read(siteNotifierProvider.notifier).loadSites(),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(siteNotifierProvider);
    final notifier = ref.read(siteNotifierProvider.notifier);
    final bool hasSearch = state.searchKeyword.isNotEmpty;
    final List<Video> visibleVideos = hasSearch ? state.searchResults : state.videos;

    return Scaffold(
      appBar: ZySearchAppBar(
        placeholder: '探索片单、演员、导演',
        onTap: () {},
        actions: <Widget>[
          IconButton(
            tooltip: '历史',
            onPressed: () => context.push('/history'),
            icon: const Icon(LucideIcons.clock3, size: AppIconSize.md),
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          _ExploreSidebar(
            categories: state.categories,
            selectedCategoryId: state.selectedCategory?.id,
            isLoading: state.isCategoryLoading,
            onTap: notifier.loadVideosByCategory,
          ),
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(0, AppSpacing.md, AppSpacing.md, AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      <Widget>[
                        _ExploreSummary(selectedSite: state.selectedSite),
                        const SizedBox(height: AppSpacing.md),
                        AppSearchBar(
                          controller: _controller,
                          isSearching: state.isSearching,
                          onSubmitted: (value) => _submitSearch(value, notifier),
                          onSearch: () => _submitSearch(_controller.text, notifier),
                          buttonEnabled: state.selectedSite != null,
                          buttonLabel: state.selectedSite == null
                              ? '请先选择站点'
                              : '搜索 ${state.selectedSite!.name}',
                          placeholder: '输入关键词后切换到搜索结果模式',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _FilterSection(
                          selectedYear: _selectedYear,
                          selectedRegion: _selectedRegion,
                          selectedKind: _selectedKind,
                          onYearChanged: (value) => setState(() => _selectedYear = value),
                          onRegionChanged: (value) => setState(() => _selectedRegion = value),
                          onKindChanged: (value) => setState(() => _selectedKind = value),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _SearchHistorySection(
                          recentKeywords: _recentKeywords,
                          onKeywordTap: (keyword) {
                            _controller.text = keyword;
                            _submitSearch(keyword, notifier);
                          },
                          onClear: () => setState(_recentKeywords.clear),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ResultHeader(
                          title: hasSearch ? '搜索结果' : '探索内容',
                          subtitle: hasSearch
                              ? '“${state.searchKeyword}” 共 ${state.searchResults.length} 条结果'
                              : state.selectedCategory?.name ?? '当前分类推荐',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (state.errorMessage != null) ...<Widget>[
                          _InlineError(message: state.errorMessage!),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ],
                    ),
                  ),
                ),
                if (visibleVideos.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(0, 0, AppSpacing.md, AppSpacing.lg),
                    sliver: SliverToBoxAdapter(
                      child: _ExploreEmptyState(hasSearch: hasSearch),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(0, 0, AppSpacing.md, AppSpacing.lg),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.62,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _ExploreVideoTile(video: visibleVideos[index]),
                        childCount: visibleVideos.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 1),
    );
  }

  void _submitSearch(String keyword, SiteNotifier notifier) {
    final normalized = keyword.trim();
    if (normalized.isEmpty) {
      notifier.clearSearch();
      return;
    }
    if (!_recentKeywords.contains(normalized)) {
      setState(() {
        _recentKeywords.insert(0, normalized);
        if (_recentKeywords.length > 6) {
          _recentKeywords.removeLast();
        }
      });
    }
    notifier.search(normalized);
  }
}

class _ExploreSidebar extends StatelessWidget {
  const _ExploreSidebar({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
      ),
      child: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
            child: Align(
              alignment: Alignment.centerLeft,
              child: PrimaryText('分类', style: AppTypography.body),
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: LinearProgressIndicator(),
            ),
          Expanded(
            child: categories.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        '暂无分类',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                    ),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final selected = category.id == selectedCategoryId;
                      return _SidebarItem(
                        label: category.name,
                        selected: selected,
                        onTap: () => onTap(category.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primarySoft
                : (isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtle),
            borderRadius: AppRadius.card,
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.border),
            ),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: selected
                    ? AppColors.primary
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreSummary extends StatelessWidget {
  const _ExploreSummary({required this.selectedSite});

  final dynamic selectedSite;

  @override
  Widget build(BuildContext context) {
    return StatCard(
      label: '当前线路',
      value: selectedSite?.name ?? '未选择站点',
      footnote: '这一页先承接探索 Tab 的视觉重构，筛选项暂用本地状态模拟。',
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.selectedYear,
    required this.selectedRegion,
    required this.selectedKind,
    required this.onYearChanged,
    required this.onRegionChanged,
    required this.onKindChanged,
  });

  final String selectedYear;
  final String selectedRegion;
  final String selectedKind;
  final ValueChanged<String> onYearChanged;
  final ValueChanged<String> onRegionChanged;
  final ValueChanged<String> onKindChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(LucideIcons.filter, size: AppIconSize.md),
            const SizedBox(width: AppSpacing.sm),
            const PrimaryText('筛选区', style: AppTypography.h3),
            const Spacer(),
            StatusChip(label: '演示', tone: StatusChipTone.info),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilterRow(
          title: '年代',
          items: const <String>['全部', '2026', '2025', '2024'],
          selected: selectedYear,
          onSelected: onYearChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilterRow(
          title: '地区',
          items: const <String>['全部', '中国', '日韩', '欧美'],
          selected: selectedRegion,
          onSelected: onRegionChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        _FilterRow(
          title: '类型',
          items: const <String>['推荐', '热播', '高分', '最新'],
          selected: selectedKind,
          onSelected: onKindChanged,
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 36,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: SecondaryText(title),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: items
                .map(
                  (item) => AppChip(
                    label: item,
                    selected: item == selected,
                    onTap: () => onSelected(item),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SearchHistorySection extends StatelessWidget {
  const _SearchHistorySection({
    required this.recentKeywords,
    required this.onKeywordTap,
    required this.onClear,
  });

  final List<String> recentKeywords;
  final ValueChanged<String> onKeywordTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const PrimaryText('搜索历史', style: AppTypography.h3),
            const Spacer(),
            TextButton(
              onPressed: recentKeywords.isEmpty ? null : onClear,
              child: const Text('清空'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (recentKeywords.isEmpty)
          const SecondaryText('暂无搜索历史')
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: recentKeywords
                .map(
                  (keyword) => AppChip(
                    label: keyword,
                    onTap: () => onKeywordTap(keyword),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        PrimaryText(title, style: AppTypography.h3),
        const SizedBox(height: AppSpacing.xs),
        SecondaryText(subtitle),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

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
      child: SecondaryText(
        message,
        style: AppTypography.bodySmall.copyWith(color: const Color(0xFF991B1B)),
      ),
    );
  }
}

class _ExploreEmptyState extends StatelessWidget {
  const _ExploreEmptyState({required this.hasSearch});

  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    return FunctionCard(
      title: hasSearch ? '暂无搜索结果' : '暂无探索内容',
      description: hasSearch ? '换个关键词试试，或先切换左侧分类。' : '先选择站点和分类，内容区会自动展示。',
      icon: hasSearch ? LucideIcons.searchX : LucideIcons.layoutGrid,
      onTap: _noop,
    );
  }
}

class _ExploreVideoTile extends StatelessWidget {
  const _ExploreVideoTile({required this.video});

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
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            boxShadow: isDark ? AppShadows.darkCard : AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: HeroBannerCard(
                  title: video.title,
                  description: video.description ?? '暂无简介',
                  imageUrl: video.cover,
                  badge: video.type ?? '影视',
                ),
              ),
              Padding(
                padding: AppSpacing.cardInsets,
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
                      _subtitle(video),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(Video video) {
    final parts = <String>[
      if ((video.year ?? '').isNotEmpty) video.year!,
      if ((video.area ?? '').isNotEmpty) video.area!,
      if ((video.actor ?? '').isNotEmpty) video.actor!,
    ];
    if (parts.isEmpty) {
      return video.description ?? '当前使用演示数据展示探索页列表。';
    }
    return parts.join(' / ');
  }
}

void _noop() {}
