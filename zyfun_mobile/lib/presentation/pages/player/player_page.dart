import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:video_player/video_player.dart';

import '../../components/app_bottom_nav_bar.dart';
import '../../providers/player_provider.dart';

class PlayerPage extends ConsumerStatefulWidget {
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
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  late final PlayerSource _source;
  bool _danmakuEnabled = false;

  @override
  void initState() {
    super.initState();
    _source = PlayerSource(
      id: widget.id,
      title: widget.title,
      playUrl: widget.playUrl,
      episode: widget.episode,
    );
    Future<void>.microtask(
      () => ref.read(playerNotifierProvider(_source).notifier).initialize(_source),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final state = ref.watch(playerNotifierProvider(_source));
    final notifier = ref.read(playerNotifierProvider(_source).notifier);
    final controller = notifier.videoController;

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
              child: _buildPlayerBody(theme, state, controller, notifier),
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

  Widget _buildPlayerBody(
    ShadThemeData theme,
    PlayerState state,
    VideoPlayerController? controller,
    PlayerNotifier notifier,
  ) {
    if (state.isInitializing) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null || controller == null || !controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: Text(
            state.errorMessage ?? '播放器未就绪',
            style: theme.textTheme.muted,
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: state.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: VideoPlayer(controller),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            ShadButton.outline(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('返回'),
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
        const SizedBox(height: 12),
        PlayerControlBar(
          isPlaying: state.isPlaying,
          isCompleted: state.isCompleted,
          isBuffering: state.isBuffering,
          positionLabel:
              '${_formatDuration(state.position)} / ${_formatDuration(state.duration)}',
          volume: state.volume,
          playbackSpeed: state.playbackSpeed,
          onTogglePlayPause: notifier.togglePlayPause,
          onPlaybackSpeedChanged: notifier.setPlaybackSpeed,
          onVolumeChanged: notifier.setVolume,
        ),
        const SizedBox(height: 12),
        DanmakuSwitch(
          value: _danmakuEnabled,
          onChanged: (value) => setState(() => _danmakuEnabled = value),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
