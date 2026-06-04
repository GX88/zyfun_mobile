import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:video_player/video_player.dart';

import '../../components/player_control_bar.dart';
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

class _PlayerPageState extends ConsumerState<PlayerPage> with WidgetsBindingObserver {
  late final PlayerSource _source;
  bool _danmakuEnabled = false;
  bool _isFullscreen = false;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _lifecycleState = state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _exitFullscreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final state = ref.watch(playerNotifierProvider(_source));
    final notifier = ref.read(playerNotifierProvider(_source).notifier);
    final controller = notifier.videoController;

    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isFullscreen) {
          _toggleFullscreen();
        }
      },
      child: Scaffold(
        backgroundColor: _isFullscreen ? Colors.black : null,
        appBar: _isFullscreen
            ? null
            : AppBar(
                title: Text(widget.title),
              ),
        body: _isFullscreen
            ? SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildPlayerBody(theme, state, controller, notifier),
                  ),
                ),
              )
            : ListView(
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
                    title: Text('播放状态', style: theme.textTheme.h4),
                    description: const Text('全屏与横屏已接入，后台播放与画中画等待播放器内核升级。'),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _InfoLine(label: '显示模式', value: _isFullscreen ? '全屏横屏' : '页面内嵌'),
                          _InfoLine(label: '应用状态', value: _lifecycleLabel),
                          _InfoLine(label: '播放器内核', value: 'video_player'),
                          _InfoLine(label: '后台播放', value: '待第 13.6 阶段接入 audio_service'),
                          _InfoLine(label: 'PIP 画中画', value: '待第 13.6 阶段接入原生 PIP'),
                        ],
                      ),
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
            borderRadius: BorderRadius.circular(_isFullscreen ? 0 : 12),
            child: ColoredBox(
              color: Colors.black,
              child: VideoPlayer(controller),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            ShadButton.outline(
              onPressed: _isFullscreen
                  ? _toggleFullscreen
                  : () => Navigator.of(context).maybePop(),
              child: Text(_isFullscreen ? '退出全屏' : '返回'),
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
        Row(
          children: <Widget>[
            Expanded(
              child: ShadButton.secondary(
                onPressed: _toggleFullscreen,
                child: Text(_isFullscreen ? '切回页面模式' : '全屏播放'),
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

  String get _lifecycleLabel {
    switch (_lifecycleState) {
      case AppLifecycleState.resumed:
        return '前台播放';
      case AppLifecycleState.inactive:
        return '切换中';
      case AppLifecycleState.paused:
        return '后台挂起';
      case AppLifecycleState.hidden:
        return '界面隐藏';
      case AppLifecycleState.detached:
        return '已分离';
    }
  }

  Future<void> _toggleFullscreen() async {
    if (_isFullscreen) {
      await _exitFullscreen();
      return;
    }

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (mounted) {
      setState(() => _isFullscreen = true);
    }
  }

  Future<void> _exitFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (mounted && _isFullscreen) {
      setState(() => _isFullscreen = false);
    }
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label：$value', style: theme.textTheme.small),
    );
  }
}
