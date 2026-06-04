import 'dart:async';

import 'package:audio_service/audio_service.dart';

import '../presentation/providers/player_provider.dart';

typedef BackgroundPlayCallback = Future<void> Function();
typedef BackgroundPauseCallback = Future<void> Function();
typedef BackgroundSeekCallback = Future<void> Function(Duration position);
typedef BackgroundSpeedCallback = Future<void> Function(double speed);
typedef BackgroundSkipCallback = Future<void> Function();

class AppAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  BackgroundPlayCallback? _onPlay;
  BackgroundPauseCallback? _onPause;
  BackgroundSeekCallback? _onSeek;
  BackgroundSpeedCallback? _onSpeed;
  BackgroundSkipCallback? _onSkipNext;

  void bindControls({
    BackgroundPlayCallback? onPlay,
    BackgroundPauseCallback? onPause,
    BackgroundSeekCallback? onSeek,
    BackgroundSpeedCallback? onSpeed,
    BackgroundSkipCallback? onSkipNext,
  }) {
    _onPlay = onPlay;
    _onPause = onPause;
    _onSeek = onSeek;
    _onSpeed = onSpeed;
    _onSkipNext = onSkipNext;
  }

  void clearControls() {
    _onPlay = null;
    _onPause = null;
    _onSeek = null;
    _onSpeed = null;
    _onSkipNext = null;
  }

  void syncSource({
    required PlayerSource source,
    required int queueIndex,
    required List<Map<String, String>> playlist,
  }) {
    mediaItem.add(
      MediaItem(
        id: source.playUrl,
        title: source.title,
        album: source.episode ?? '视频播放',
        artist: 'zyfun_mobile',
      ),
    );

    if (playlist.isEmpty) {
      queue.add(const <MediaItem>[]);
      return;
    }

    queue.add(
      playlist
          .map(
            (item) => MediaItem(
              id: item['url'] ?? '',
              title: item['name'] ?? '未命名选集',
              album: source.title,
            ),
          )
          .toList(growable: false),
    );

    final current = playbackState.value;
    playbackState.add(current.copyWith(queueIndex: queueIndex));
  }

  void syncState(PlayerState state, {required bool canSkipNext, required int queueIndex}) {
    playbackState.add(
      playbackState.value.copyWith(
        controls: <MediaControl>[
          if (canSkipNext) MediaControl.skipToNext,
          state.isPlaying ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
        ],
        systemActions: const <MediaAction>{
          MediaAction.play,
          MediaAction.pause,
          MediaAction.seek,
          MediaAction.setSpeed,
          MediaAction.stop,
          MediaAction.skipToNext,
        },
        androidCompactActionIndices: canSkipNext ? const <int>[0, 1] : const <int>[0],
        processingState: _mapProcessingState(state),
        playing: state.isPlaying,
        updatePosition: state.position,
        bufferedPosition: state.position,
        speed: state.playbackSpeed,
        queueIndex: queueIndex,
      ),
    );
  }

  AudioProcessingState _mapProcessingState(PlayerState state) {
    if (state.isInitializing) {
      return AudioProcessingState.loading;
    }
    if (state.errorMessage != null) {
      return AudioProcessingState.error;
    }
    if (state.isBuffering) {
      return AudioProcessingState.buffering;
    }
    if (state.isCompleted) {
      return AudioProcessingState.completed;
    }
    return AudioProcessingState.ready;
  }

  @override
  Future<void> play() async => _onPlay?.call();

  @override
  Future<void> pause() async => _onPause?.call();

  @override
  Future<void> seek(Duration position) async => _onSeek?.call(position);

  @override
  Future<void> setSpeed(double speed) async => _onSpeed?.call(speed);

  @override
  Future<void> skipToNext() async => _onSkipNext?.call();

  @override
  Future<void> stop() async {
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle,
      ),
    );
  }
}

class BackgroundPlaybackService {
  BackgroundPlaybackService._();

  static final BackgroundPlaybackService instance = BackgroundPlaybackService._();

  final AppAudioHandler _fallbackHandler = AppAudioHandler();
  AppAudioHandler? _initializedHandler;

  AppAudioHandler get handler => _initializedHandler ?? _fallbackHandler;

  Future<AppAudioHandler> initialize() async {
    if (_initializedHandler != null) {
      return _initializedHandler!;
    }

    final initialized = await AudioService.init<AppAudioHandler>(
      builder: () => _fallbackHandler,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.zyfun_mobile.playback',
        androidNotificationChannelName: 'Zyfun Playback',
        androidStopForegroundOnPause: false,
      ),
    );
    _initializedHandler = initialized;
    return _initializedHandler!;
  }
}
