import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../components/app_bottom_nav_bar.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  static const List<_AiRecommendation> _recommendations = <_AiRecommendation>[
    _AiRecommendation(
      title: '高口碑科幻片单',
      summary: '结合当前热门趋势，优先推荐近年科幻、灾难与硬核设定作品。',
      keyword: '科幻',
    ),
    _AiRecommendation(
      title: '适合追更的国产剧',
      summary: '偏向剧情节奏稳定、适合移动端碎片化观看的连续剧。',
      keyword: '国产剧',
    ),
    _AiRecommendation(
      title: '深夜轻松综艺',
      summary: '优先推荐轻松、低门槛、适合边看边放松的综艺节目。',
      keyword: '综艺',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AI 功能')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ShadCard(
            title: Text('AI 推荐', style: theme.textTheme.h3),
            description: const Text('当前阶段先提供本地推荐卡片，帮助你快速进入搜索与内容浏览。'),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('推荐模式：本地规则推荐', style: theme.textTheme.large),
                  const SizedBox(height: 8),
                  Text(
                    '后续会接入真实模型服务与个性化推荐，现在优先确保移动端闭环与页面可用性。',
                    style: theme.textTheme.muted,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._recommendations.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ShadCard(
                title: Text(item.title, style: theme.textTheme.large),
                description: Text(item.summary, style: theme.textTheme.muted),
                footer: Align(
                  alignment: Alignment.centerLeft,
                  child: ShadButton(
                    onPressed: () => context.push('/search'),
                    child: Text('去搜索 ${item.keyword}'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 4),
    );
  }
}

class _AiRecommendation {
  const _AiRecommendation({
    required this.title,
    required this.summary,
    required this.keyword,
  });

  final String title;
  final String summary;
  final String keyword;
}
