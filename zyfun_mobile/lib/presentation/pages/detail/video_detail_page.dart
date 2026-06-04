import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../data/models/favorite.dart';
import '../../../data/models/history.dart';
import '../../../data/models/video.dart';
import '../../providers/app_providers.dart';

class VideoDetailPage extends ConsumerStatefulWidget {
  const VideoDetailPage({
    super.key,
    required this.siteId,
    required this.videoId,
    this.title,
  });

  final String siteId;
  final String videoId;
  final String? title;

  @override
  ConsumerState<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends ConsumerState<VideoDetailPage> {
  VideoDetail? _detail;
  bool _isLoading = true;
  bool _isFavorite = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadDetail);
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await ref
          .read(siteRepositoryProvider)
          .getVideoDetail(widget.siteId, widget.videoId);
      final favorite = await ref
          .read(favoriteRepositoryProvider)
          .getFavoriteByVideo(widget.siteId, widget.videoId);
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = detail;
        _isFavorite = favorite != null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final detail = _detail;
    if (detail == null) {
      return;
    }

    final repository = ref.read(favoriteRepositoryProvider);
    if (_isFavorite) {
      final favorite = await repository.getFavoriteByVideo(widget.siteId, widget.videoId);
      if (favorite != null) {
        await repository.deleteFavorite(favorite.id);
      }
    } else {
      final now = DateTime.now().millisecondsSinceEpoch;
      await repository.addFavorite(
        Favorite(
          id: '${widget.siteId}_${widget.videoId}',
          siteId: widget.siteId,
          videoId: widget.videoId,
          title: detail.video.title,
          cover: detail.video.cover,
          createdAt: now,
        ),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(_isFavorite ? '已加入收藏' : '已取消收藏')),
    );
  }

  Future<void> _shareDetail() async {
    final detail = _detail;
    if (detail == null) {
      return;
    }

    final shareText = StringBuffer()
      ..writeln(detail.video.title)
      ..writeln(detail.detailUrl ?? '暂无详情链接')
      ..write(detail.video.description ?? '暂无简介');
    await Clipboard.setData(ClipboardData(text: shareText.toString()));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('分享信息已复制到剪贴板')),
    );
  }

  Future<void> _playEpisode(String episodeName, String episodeUrl, int currentIndex) async {
    final detail = _detail;
    if (detail == null) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    await ref.read(historyRepositoryProvider).addHistory(
          History(
            id: '${widget.siteId}_${widget.videoId}_$episodeName',
            siteId: widget.siteId,
            videoId: widget.videoId,
            title: detail.video.title,
            cover: detail.video.cover,
            description: detail.video.description,
            episodeUrl: episodeUrl,
            episodeName: episodeName,
            createdAt: now,
            updatedAt: now,
          ),
        );

    if (!mounted) {
      return;
    }

    final uri = Uri(
      path: '/player/${detail.video.id}',
      queryParameters: <String, String>{
        'title': detail.video.title,
        'url': episodeUrl,
        'episode': episodeName,
        'siteId': widget.siteId,
        'index': '$currentIndex',
        'playlist': jsonEncode(detail.playUrls),
      },
    );
    context.push(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? _detail?.video.title ?? '详情页'),
        actions: <Widget>[
          IconButton(
            tooltip: _isFavorite ? '取消收藏' : '收藏',
            onPressed: _detail == null ? null : _toggleFavorite,
            icon: Icon(_isFavorite ? LucideIcons.heartCrack : LucideIcons.heart),
          ),
          IconButton(
            tooltip: '分享',
            onPressed: _detail == null ? null : _shareDetail,
            icon: const Icon(LucideIcons.share2),
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ShadThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: theme.textTheme.muted));
    }

    final detail = _detail;
    if (detail == null || !detail.video.isValid) {
      return Center(child: Text('未获取到详情数据', style: theme.textTheme.muted));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        ShadCard(
          child: _HeaderSection(detail: detail),
        ),
        const SizedBox(height: 16),
        ShadCard(
          title: Text('剧情简介', style: theme.textTheme.h4),
          description: Text(detail.video.type ?? '影视详情'),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              detail.video.content ?? detail.video.description ?? '暂无剧情简介',
              style: theme.textTheme.large,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ShadCard(
          title: Text('播放列表', style: theme.textTheme.h4),
          description: Text('共 ${detail.playUrls.length} 个选集/线路'),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: detail.playUrls.isEmpty
                ? Text('当前暂无可用播放源', style: theme.textTheme.muted)
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: detail.playUrls
                        .asMap()
                        .entries
                        .map(
                          (entry) => ShadButton.outline(
                            onPressed: () => _playEpisode(
                              entry.value['name'] ?? '立即播放',
                              entry.value['url'] ?? '',
                              entry.key,
                            ),
                            child: Text(entry.value['name'] ?? '立即播放'),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.detail});

  final VideoDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: detail.video.hasCover
              ? Image.network(
                  detail.video.cover!,
                  width: 112,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _PosterPlaceholder(
                    title: detail.video.title,
                  ),
                )
              : _PosterPlaceholder(title: detail.video.title),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(detail.video.title, style: theme.textTheme.h3),
              const SizedBox(height: 8),
              _MetaLine(label: '年份', value: detail.video.year),
              _MetaLine(label: '地区', value: detail.video.area),
              _MetaLine(label: '类型', value: detail.video.type),
              _MetaLine(label: '导演', value: detail.video.director),
              _MetaLine(label: '演员', value: detail.video.actor),
              const SizedBox(height: 12),
              Text('选集数：${detail.playUrls.length}', style: theme.textTheme.small),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label：${(value == null || value!.isEmpty) ? '暂无' : value!}',
        style: theme.textTheme.small,
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      width: 112,
      height: 160,
      color: theme.colorScheme.secondary,
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(
          title,
          style: theme.textTheme.small,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
