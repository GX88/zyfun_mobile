import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../data/models/site.dart';
import '../../components/app_bottom_nav_bar.dart';
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
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('影视'),
        actions: <Widget>[
          IconButton(
            tooltip: '搜索',
            onPressed: () => context.push('/search'),
            icon: const Icon(LucideIcons.search),
          ),
          IconButton(
            tooltip: '设置',
            onPressed: () => context.push('/setting'),
            icon: const Icon(LucideIcons.settings2),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(siteNotifierProvider.notifier).loadSites(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            ShadCard(
              title: Text('站点', style: theme.textTheme.h4),
              description: const Text('选择默认影视站点并查看本地配置状态。'),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (state.isLoading)
                      const LinearProgressIndicator(),
                    if (state.errorMessage != null) ...<Widget>[
                      Text(
                        state.errorMessage!,
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.destructive,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (state.sites.isEmpty && !state.isLoading)
                      Text(
                        '暂无站点配置',
                        style: theme.textTheme.muted,
                      )
                    else
                      ...state.sites.map(
                        (site) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SiteTile(
                            site: site,
                            selected: state.selectedSite?.id == site.id,
                            onTap: () => ref
                                .read(siteNotifierProvider.notifier)
                                .selectSite(site),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ShadCard(
              title: Text('分类', style: theme.textTheme.h4),
              description: Text(
                state.selectedSite == null
                    ? '请选择站点后查看分类。'
                    : '当前站点：${state.selectedSite!.name}',
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: state.categories.isEmpty
                    ? Text('暂无分类数据', style: theme.textTheme.muted)
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.categories
                            .map(
                              (category) => _CategoryChip(
                                label: category.name,
                                selected: state.selectedCategory?.id == category.id,
                                onPressed: () => ref
                                    .read(siteNotifierProvider.notifier)
                                    .loadVideosByCategory(category.id),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            ShadCard(
              title: Text('内容列表', style: theme.textTheme.h4),
              description: Text(
                state.selectedCategory == null
                    ? '当前没有已选分类。'
                    : '分类：${state.selectedCategory!.name}',
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: state.isCategoryLoading
                    ? const LinearProgressIndicator()
                    : state.videos.isEmpty
                        ? Text('暂无内容', style: theme.textTheme.muted)
                        : Column(
                            children: state.videos
                                .map(
                                  (video) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: VideoCard(video: video),
                                  ),
                                )
                                .toList(),
                          ),
              ),
            ),
            if (state.searchResults.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              ShadCard(
                title: Text('最近搜索结果', style: theme.textTheme.h4),
                description: Text('关键字：${state.searchKeyword}'),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: state.searchResults
                        .take(4)
                        .map(
                          (video) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: VideoCard(video: video),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 0),
    );
  }
}

class _SiteTile extends StatelessWidget {
  const _SiteTile({
    required this.site,
    required this.selected,
    required this.onTap,
  });

  final Site site;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(site.name, style: theme.textTheme.large),
                  const SizedBox(height: 4),
                  Text(site.typeName, style: theme.textTheme.muted),
                ],
              ),
            ),
            if (selected)
              Icon(LucideIcons.check, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return ShadButton(onPressed: onPressed, child: Text(label));
    }
    return ShadButton.outline(onPressed: onPressed, child: Text(label));
  }
}
