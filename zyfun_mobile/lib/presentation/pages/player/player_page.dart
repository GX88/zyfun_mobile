import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../data/models/history.dart';
import '../../components/danmaku_switch.dart';
import '../../components/player_control_bar.dart';
import '../../components/player_danmaku_overlay.dart';
import '../../providers/app_providers.dart';
import '../../providers/danmaku_provider.dart';
import '../../providers/player_provider.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({
    super.key,
    required this.id,
    required this.title,
    required this.playUrl,
    this.episode,
    this.siteId,
    this.playlist = const <Map<String, String>>[],
    this.currentIndex = 0,
    this.httpHeaders,
  });

  final String id;
  final String title;
  final String playUrl;
  final String? episode;
  final String? siteId;
  final List<Map<String, String>> playlist;
  final int currentIndex;
  final Map<String, String>? httpHeaders;

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> with WidgetsBindingObserver {
  late final PlayerSource _source;
  bool _danmakuEnabled = false;
  bool _isFullscreen = false;
  bool _isDraggingProgress = false;
  double? _dragProgressValue;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;
  ProviderSubscription<PlayerState>? _playerStateSubscription;
  Timer? _progressSaveTimer;
  bool _hasRestoredProgress = false;
  bool _isAutoPlayingNext = false;
  bool _isDisposed = false;
  bool _isPipSupported = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _source = PlayerSource(
      id: widget.id,
      title: widget.title,
      playUrl: widget.playUrl,
      episode: widget.episode,
      httpHeaders: widget.httpHeaders,
    );
    _playerStateSubscription = ref.listenManual<PlayerState>(
      playerNotifierProvider(_source),
      _handlePlayerStateChanged,
    );
    _progressSaveTimer = Timer.periodic(
      ref.read(playerProgressSaveIntervalProvider),
      (_) => unawaited(_persistProgress()),
    );
    Future<void>.microtask(() async {
      _isPipSupported = await ref.read(playerPlatformBridgeProvider).isPictureInPictureSupported();
      await ref.read(playerNotifierProvider(_source).notifier).initialize(_source);
      _bindBackgroundPlaybackControls();
      _syncBackgroundPlayback(stateOverride: ref.read(playerNotifierProvider(_source)));
      await _restorePlaybackProgress();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _lifecycleState = state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      unawaited(_persistProgress());
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _playerStateSubscription?.close();
    _progressSaveTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _exitFullscreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final state = ref.watch(playerNotifierProvider(_source));
    final notifier = ref.read(playerNotifierProvider(_source).notifier);
    final danmakuItems = ref.watch(danmakuItemsProvider(_source));
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
                     child: _buildPlayerBody(
                       theme,
                       state,
                       controller,
                       notifier,
                       danmakuItems,
                     ),
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
                       child: _buildPlayerBody(
                         theme,
                         state,
                         controller,
                         notifier,
                         danmakuItems,
                       ),
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
                          const _InfoLine(label: '播放器内核', value: 'media_kit'),
                          _InfoLine(label: '流格式', value: state.formatLabel),
                          _InfoLine(
                            label: '记忆播放',
                            value: _hasRestoredProgress ? '已恢复历史进度' : '当前无历史进度',
                          ),
                          _InfoLine(
                            label: '自动连播',
                            value: _nextEpisode == null
                                ? '当前已是最后一集'
                                : '播放完成后自动切换 ${_nextEpisode!['name'] ?? '下一集'}',
                          ),
                          const _InfoLine(label: '后台播放', value: '已接入 audio_service 状态同步'),
                          _InfoLine(label: 'PIP 画中画', value: _isPipSupported ? '当前设备支持进入画中画' : '当前平台或设备暂不支持'),
                          _InfoLine(
                            label: '弹幕装载',
                            value: danmakuItems.maybeWhen(
                              data: (items) => '已加载 ${items.length} 条',
                              loading: () => '加载中',
                              orElse: () => '加载失败',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ShadCard(
                    title: Text('播放信息', style: theme.textTheme.h4),
                    description: const Text('当前使用 media_kit 作为直播与点播统一播放器实现。'),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('ID: ${widget.id}', style: theme.textTheme.small),
                          const SizedBox(height: 8),
                          if (_nextEpisode != null) ...<Widget>[
                            Text(
                              '下一集：${_nextEpisode!['name'] ?? '未命名'}',
                              style: theme.textTheme.small,
                            ),
                            const SizedBox(height: 8),
                          ],
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
    VideoController? controller,
    PlayerNotifier notifier,
    AsyncValue<List<DanmakuItem>> danmakuItems,
  ) {
    if (state.isInitializing) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null || controller == null || !state.isReady) {
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
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Video(controller: controller),
                  _PlayerGestureLayer(
                    onHorizontalDelta: (deltaRatio) {
                      final delta = state.duration.inMilliseconds * deltaRatio;
                      final target = state.position.inMilliseconds + delta.round();
                      if (state.duration <= Duration.zero) {
                        return;
                      }
                      notifier.seekTo(
                        Duration(
                          milliseconds: target.clamp(0, state.duration.inMilliseconds),
                        ),
                      );
                    },
                    onLeftVerticalDelta: (deltaRatio) {
                      notifier.setBrightness(state.brightness - (deltaRatio * 100));
                    },
                    onRightVerticalDelta: (deltaRatio) {
                      notifier.setVolume(state.volume - (deltaRatio * 100));
                    },
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _GestureBadge(label: '亮度 ${state.brightness.toStringAsFixed(0)}%'),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _GestureBadge(label: '音量 ${state.volume.toStringAsFixed(0)}%'),
                  ),
                  PlayerDanmakuOverlay(
                    enabled: _danmakuEnabled,
                    position: state.position,
                    items: danmakuItems.valueOrNull ?? const <DanmakuItem>[],
                  ),
                ],
              ),
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
              child: Slider(
                value: _dragProgressValue ?? _progressValue(state),
                onChangeStart: (value) {
                  setState(() {
                    _isDraggingProgress = true;
                    _dragProgressValue = value;
                  });
                },
                onChanged: (value) {
                  setState(() => _dragProgressValue = value);
                },
                onChangeEnd: (value) {
                  final duration = Duration(
                    milliseconds: (state.duration.inMilliseconds * value).round(),
                  );
                  setState(() {
                    _isDraggingProgress = false;
                    _dragProgressValue = null;
                  });
                  notifier.seekTo(duration);
                },
              ),
            ),
          ],
        ),
        if (_isDraggingProgress)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '预览定位 ${_previewPositionLabel(state)}',
                style: theme.textTheme.small,
              ),
            ),
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
            if (_isPipSupported) ...<Widget>[
              const SizedBox(width: 12),
              Expanded(
                child: ShadButton.outline(
                  onPressed: _enterPictureInPicture,
                  child: const Text('进入画中画'),
                ),
              ),
            ],
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
          description: danmakuItems.when(
            data: (items) => items.isEmpty ? '当前没有可展示的弹幕。' : '已加载 ${items.length} 条本地演示弹幕，可按播放时间同步显示。',
            loading: () => '正在加载弹幕数据...',
            error: (_, __) => '弹幕加载失败，当前已回退为关闭状态提示。',
          ),
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

  String _previewPositionLabel(PlayerState state) {
    final value = _dragProgressValue ?? _progressValue(state);
    final preview = Duration(
      milliseconds: (state.duration.inMilliseconds * value).round(),
    );
    return _formatDuration(preview);
  }

  double _progressValue(PlayerState state) {
    final total = state.duration.inMilliseconds;
    if (total <= 0) {
      return 0;
    }
    final current = state.position.inMilliseconds.clamp(0, total);
    return current / total;
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

  Map<String, String>? get _nextEpisode {
    final nextIndex = widget.currentIndex + 1;
    if (nextIndex < 0 || nextIndex >= widget.playlist.length) {
      return null;
    }
    return widget.playlist[nextIndex];
  }

  String? get _historyId {
    final siteId = widget.siteId;
    final episode = widget.episode;
    if (siteId == null || siteId.isEmpty || episode == null || episode.isEmpty) {
      return null;
    }
    return '${siteId}_${widget.id}_$episode';
  }

  Future<void> _restorePlaybackProgress() async {
    final historyId = _historyId;
    if (historyId == null) {
      return;
    }

    final history = await ref.read(historyRepositoryProvider).getHistoryById(historyId);
    if (!mounted || history == null || history.progress <= 0) {
      return;
    }

    final almostCompleted = history.duration > 0 && history.progress >= history.duration - 5000;
    if (almostCompleted) {
      return;
    }

    await ref.read(playerNotifierProvider(_source).notifier).seekTo(
      Duration(milliseconds: history.progress),
    );
    if (mounted) {
      setState(() => _hasRestoredProgress = true);
    }
  }

  Future<void> _persistProgress() async {
    if (_isDisposed) {
      return;
    }

    final historyId = _historyId;
    final siteId = widget.siteId;
    if (historyId == null || siteId == null || siteId.isEmpty) {
      return;
    }

    final state = ref.read(playerNotifierProvider(_source));
    if (state.position <= Duration.zero && state.duration <= Duration.zero) {
      return;
    }

    final repository = ref.read(historyRepositoryProvider);
    final existing = await repository.getHistoryById(historyId);
    final now = DateTime.now().millisecondsSinceEpoch;
    final history = History(
      id: historyId,
      siteId: siteId,
      videoId: widget.id,
      title: existing?.title ?? widget.title,
      cover: existing?.cover,
      description: existing?.description,
      episodeUrl: widget.playUrl,
      episodeName: widget.episode,
      progress: state.position.inMilliseconds,
      duration: state.duration.inMilliseconds,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (existing == null) {
      await repository.addHistory(history);
    } else {
      await repository.updateHistory(history);
    }
  }

  void _handlePlayerStateChanged(PlayerState? previous, PlayerState next) {
    _syncBackgroundPlayback(stateOverride: next);
    if (_isAutoPlayingNext || previous?.isCompleted == true || !next.isCompleted) {
      return;
    }
    unawaited(_playNextEpisode());
  }

  void _bindBackgroundPlaybackControls() {
    final handler = ref.read(backgroundPlaybackHandlerProvider);
    final notifier = ref.read(playerNotifierProvider(_source).notifier);
    handler.bindControls(
      onPlay: notifier.togglePlayPause,
      onPause: notifier.togglePlayPause,
      onSeek: notifier.seekTo,
      onSpeed: notifier.setPlaybackSpeed,
      onSkipNext: _playNextEpisode,
    );
    handler.syncSource(
      source: _source,
      queueIndex: widget.currentIndex,
      playlist: widget.playlist,
    );
  }

  void _syncBackgroundPlayback({required PlayerState stateOverride}) {
    ref.read(backgroundPlaybackHandlerProvider).syncState(
          stateOverride,
          canSkipNext: _nextEpisode != null,
          queueIndex: widget.currentIndex,
        );
  }

  Future<void> _playNextEpisode() async {
    final nextEpisode = _nextEpisode;
    if (nextEpisode == null || !mounted) {
      return;
    }

    _isAutoPlayingNext = true;
    await _persistProgress();
    if (!mounted) {
      return;
    }

    final uri = Uri(
      path: '/player/${widget.id}',
      queryParameters: <String, String>{
        'title': widget.title,
        'url': nextEpisode['url'] ?? '',
        'episode': nextEpisode['name'] ?? '下一集',
        if (widget.siteId != null && widget.siteId!.isNotEmpty) 'siteId': widget.siteId!,
        'index': '${widget.currentIndex + 1}',
        if (widget.playlist.isNotEmpty) 'playlist': jsonEncode(widget.playlist),
      },
    );
    context.replace(uri.toString());
  }

  Future<void> _enterPictureInPicture() async {
    await ref.read(playerPlatformBridgeProvider).enterPictureInPicture();
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

final playerProgressSaveIntervalProvider = Provider<Duration>((ref) {
  return const Duration(seconds: 5);
});

class _PlayerGestureLayer extends StatelessWidget {
  const _PlayerGestureLayer({
    required this.onHorizontalDelta,
    required this.onLeftVerticalDelta,
    required this.onRightVerticalDelta,
  });

  final ValueChanged<double> onHorizontalDelta;
  final ValueChanged<double> onLeftVerticalDelta;
  final ValueChanged<double> onRightVerticalDelta;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth <= 0 ? 1.0 : constraints.maxWidth;
        final height = constraints.maxHeight <= 0 ? 1.0 : constraints.maxHeight;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            onHorizontalDelta(details.delta.dx / width);
          },
          onVerticalDragUpdate: (details) {
            final deltaRatio = details.delta.dy / height;
            final isLeftSide = (details.localPosition.dx / width) < 0.5;
            if (isLeftSide) {
              onLeftVerticalDelta(deltaRatio);
            } else {
              onRightVerticalDelta(deltaRatio);
            }
          },
        );
      },
    );
  }
}

class _GestureBadge extends StatelessWidget {
  const _GestureBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
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
