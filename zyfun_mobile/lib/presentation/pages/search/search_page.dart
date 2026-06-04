import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/constants/constants.dart';
import '../../components/app_bottom_nav_bar.dart';
import '../../components/app_bar.dart';
import '../../components/texts.dart';
import '../../providers/site_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(siteNotifierProvider).searchKeyword,
    );
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

    return Scaffold(
      appBar: ZySearchAppBar(
        placeholder: '搜索影视、演员、导演',
        onTap: () {},
        actions: <Widget>[
          IconButton(
            tooltip: '清空',
            onPressed: () {
              _controller.clear();
              notifier.clearSearch();
            },
            icon: const Icon(LucideIcons.rotateCcw),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.pageInsets,
        children: <Widget>[
          AppSearchBar(
            controller: _controller,
            isSearching: state.isSearching,
            onSubmitted: notifier.search,
            onSearch: () => notifier.search(_controller.text),
            buttonEnabled: state.selectedSite != null,
            buttonLabel: state.selectedSite == null
                ? '请先选择站点'
                : '搜索 ${state.selectedSite!.name}',
          ),
          const SizedBox(height: AppSpacing.lg),
          if (state.searchKeyword.isNotEmpty)
            SecondaryText(
              '“${state.searchKeyword}” 共 ${state.searchResults.length} 条结果',
            ),
          const SizedBox(height: AppSpacing.md),
          if (state.searchResults.isEmpty && state.searchKeyword.isNotEmpty)
            ShadCard(
              title: Text('暂无结果', style: AppTypography.h3),
              description: const Text('当前搜索页使用演示数据流，后续会接真实站点搜索接口。'),
            )
          else
            ...state.searchResults.map(
              (video) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: VideoCard(
                  video: video,
                  showPlayButton: false,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 1),
    );
  }
}
