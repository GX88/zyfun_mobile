import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../data/models/video.dart';
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
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索'),
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
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ShadInput(
            controller: _controller,
            placeholder: const Text('输入影片名、演员或关键词'),
            leading: const Icon(LucideIcons.search),
            trailing: state.isSearching
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            onSubmitted: (value) => notifier.search(value),
          ),
          const SizedBox(height: 12),
          ShadButton(
            onPressed: state.selectedSite == null
                ? null
                : () => notifier.search(_controller.text),
            child: Text(
              state.selectedSite == null ? '请先选择站点' : '搜索 ${state.selectedSite!.name}',
            ),
          ),
          const SizedBox(height: 16),
          if (state.searchKeyword.isNotEmpty)
            Text(
              '“${state.searchKeyword}” 共 ${state.searchResults.length} 条结果',
              style: theme.textTheme.muted,
            ),
          const SizedBox(height: 12),
          if (state.searchResults.isEmpty && state.searchKeyword.isNotEmpty)
            ShadCard(
              title: Text('暂无结果', style: theme.textTheme.large),
              description: const Text('当前搜索页使用演示数据流，后续会接真实站点搜索接口。'),
            )
          else
            ...state.searchResults.map(
              (video) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SearchResultTile(video: video),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      title: Text(video.title, style: theme.textTheme.large),
      description: Text(video.description ?? '暂无简介', style: theme.textTheme.muted),
      footer: Row(
        children: <Widget>[
          Text(video.type ?? '未分类', style: theme.textTheme.small),
          const Spacer(),
          ShadButton.outline(
            onPressed: () => context.push('/detail/${video.id}'),
            child: const Text('查看详情'),
          ),
        ],
      ),
    );
  }
}
