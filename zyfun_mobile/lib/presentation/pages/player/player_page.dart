import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:video_player/video_player.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({
    super.key,
    required this.id,
    required this.title,
    required this.playUrl,
    this.episode,
  });

  final String id;
  final String title;
  final String playUrl;
  final String? episode;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _controller;
  String? _errorMessage;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final uri = Uri.tryParse(widget.playUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      setState(() {
        _errorMessage = '播放地址无效';
        _isInitializing = false;
      });
      return;
    }

    final controller = VideoPlayerController.networkUrl(uri);

    try {
      await controller.initialize();
      await controller.play();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isInitializing = false;
      });
    } catch (_) {
      await controller.dispose();
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = '播放器初始化失败';
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ShadCard(
            title: Text(widget.title, style: theme.textTheme.h4),
            description: Text(widget.episode ?? '视频播放'),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _buildPlayerBody(theme, controller),
            ),
          ),
          const SizedBox(height: 16),
          ShadCard(
            title: Text('播放信息', style: theme.textTheme.h4),
            description: const Text('当前使用 video_player 作为兼容播放器实现。'),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('ID: ${widget.id}', style: theme.textTheme.small),
                  const SizedBox(height: 8),
                  SelectableText(widget.playUrl, style: theme.textTheme.small),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerBody(ShadThemeData theme, VideoPlayerController? controller) {
    if (_isInitializing) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || controller == null || !controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: Text(
            _errorMessage ?? '播放器未就绪',
            style: theme.textTheme.muted,
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: controller.value.aspectRatio == 0
              ? 16 / 9
              : controller.value.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: VideoPlayer(controller),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            ShadButton(
              onPressed: () async {
                if (controller.value.isPlaying) {
                  await controller.pause();
                } else {
                  await controller.play();
                }
                if (mounted) {
                  setState(() {});
                }
              },
              child: Text(controller.value.isPlaying ? '暂停' : '播放'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
