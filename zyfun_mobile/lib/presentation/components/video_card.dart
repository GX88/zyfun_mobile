import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/constants/constants.dart';
import '../../data/models/video.dart';
import 'buttons/app_buttons.dart';
import 'cards/app_cards.dart';
import 'texts.dart';

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
    final isDark = ShadTheme.of(context).brightness == Brightness.dark;
    final progress = video.playUrls.isNotEmpty ? 0.4 : 0.0;

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
          Stack(
            children: <Widget>[
              SizedBox(
                height: 180,
                width: double.infinity,
                child: HeroBannerCard(
                  title: video.title,
                  description: video.description ?? '暂无简介',
                  imageUrl: video.cover,
                  badge: video.type ?? '影视',
                  onTap: () => _openDetail(context),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: progress <= 0 ? null : progress,
                  minHeight: 3,
                  backgroundColor: Colors.black.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: AppSpacing.cardInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PrimaryText(
                  video.title,
                  style: AppTypography.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                SecondaryText(
                  video.description ?? '暂无简介',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    SecondaryText(video.type ?? '未分类'),
                    const Spacer(),
                    if (showPlayButton) ...<Widget>[
                      PrimaryButton(
                        label: '播放',
                        size: AppButtonSize.small,
                        onPressed: () => _playVideo(context),
                      ),
                      if (showDetailButton)
                        const SizedBox(width: AppSpacing.sm),
                    ],
                    if (showDetailButton)
                      OutlineActionButton(
                        label: showPlayButton ? '详情' : '查看详情',
                        size: AppButtonSize.small,
                        onPressed: () => _openDetail(context),
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

  void _openDetail(BuildContext context) {
    context.push(
      Uri(
        path: '/detail/${video.id}',
        queryParameters: <String, String>{
          'siteId': video.siteId,
          'title': video.title,
        },
      ).toString(),
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
