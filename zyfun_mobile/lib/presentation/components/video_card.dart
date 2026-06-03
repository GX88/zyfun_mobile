import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../data/models/video.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    required this.video,
    this.showPlayButton = true,
    this.showDetailButton = true,
  });

  final Video video;
  final bool showPlayButton;
  final bool showDetailButton;

  static const String demoPlayableUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      title: Text(video.title, style: theme.textTheme.large),
      description: Text(
        video.description ?? '暂无简介',
        style: theme.textTheme.muted,
      ),
      footer: Row(
        children: <Widget>[
          Text(video.type ?? '未分类', style: theme.textTheme.small),
          const Spacer(),
          if (showPlayButton) ...<Widget>[
            ShadButton(
              onPressed: () => _playVideo(context),
              child: const Text('播放'),
            ),
            if (showDetailButton) const SizedBox(width: 8),
          ],
          if (showDetailButton)
            ShadButton.outline(
              onPressed: () => context.push(
                Uri(
                  path: '/detail/${video.id}',
                  queryParameters: <String, String>{
                    'siteId': video.siteId,
                    'title': video.title,
                  },
                ).toString(),
              ),
              child: Text(showPlayButton ? '详情' : '查看详情'),
            ),
        ],
      ),
    );
  }

  void _playVideo(BuildContext context) {
    final candidateUrl = video.playUrls.isNotEmpty
        ? (video.playUrls.first['url'] ?? '')
        : '';
    final resolvedUrl =
        candidateUrl.contains('example.com') || candidateUrl.isEmpty
            ? demoPlayableUrl
            : candidateUrl;
    final episodeName =
        video.playUrls.isNotEmpty ? video.playUrls.first['name'] : '演示播放';
    final uri = Uri(
      path: '/player/${video.id}',
      queryParameters: <String, String>{
        'title': video.title,
        'url': resolvedUrl,
        'episode': episodeName ?? '演示播放',
      },
    );
    context.push(uri.toString());
  }
}
