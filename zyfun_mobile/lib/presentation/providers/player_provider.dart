import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class PlayerSource {
  const PlayerSource({
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
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlayerSource &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            title == other.title &&
            playUrl == other.playUrl &&
            episode == other.episode;
  }

  @override
  int get hashCode => Object.hash(id, title, playUrl, episode);
}

class PlayerState {
  const PlayerState({
    this.isInitializing = false,
    this.isPlaying = false,
    this.isBuffering = false,
    this.isCompleted = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playbackSpeed = 1,
    this.volume = 1,
    this.aspectRatio = 16 / 9,
    this.errorMessage,
  });

  final bool isInitializing;
  final bool isPlaying;
  final bool isBuffering;
  final bool isCompleted;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final double volume;
  final double aspectRatio;
  final String? errorMessage;

  bool get isReady => errorMessage == null && !isInitializing && duration > Duration.zero;

  PlayerState copyWith({
    bool? isInitializing,
    bool? isPlaying,
    bool? isBuffering,
    bool? isCompleted,
    Duration? position,
    Duration? duration,
    double? playbackSpeed,
    double? volume,
    double? aspectRatio,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PlayerState(
      isInitializing: isInitializing ?? this.isInitializing,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      isCompleted: isCompleted ?? this.isCompleted,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      volume: volume ?? this.volume,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

abstract class PlayerControllerAdapter {
  VideoPlayerController? get videoController;
  PlayerControllerValue get value;
  Future<void> initialize();
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration position);
  Future<void> setPlaybackSpeed(double speed);
  Future<void> setVolume(double volume);
  void addListener(VoidCallback listener);
  void removeListener(VoidCallback listener);
  Future<void> dispose();
}

class PlayerControllerValue {
  const PlayerControllerValue({
    required this.isInitialized,
    required this.isPlaying,
    required this.isBuffering,
    required this.position,
    required this.duration,
    required this.playbackSpeed,
    required this.volume,
    required this.aspectRatio,
  });

  final bool isInitialized;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final double volume;
  final double aspectRatio;
}

class VideoPlayerControllerAdapter implements PlayerControllerAdapter {
  VideoPlayerControllerAdapter(this._controller);

  final VideoPlayerController _controller;

  @override
  VideoPlayerController get videoController => _controller;

  @override
  PlayerControllerValue get value {
    final value = _controller.value;
    return PlayerControllerValue(
      isInitialized: value.isInitialized,
      isPlaying: value.isPlaying,
      isBuffering: value.isBuffering,
      position: value.position,
      duration: value.duration,
      playbackSpeed: value.playbackSpeed,
      volume: value.volume,
      aspectRatio: value.isInitialized && value.aspectRatio > 0
          ? value.aspectRatio
          : 16 / 9,
    );
  }

  @override
  Future<void> initialize() => _controller.initialize();

  @override
  Future<void> play() => _controller.play();

  @override
  Future<void> pause() => _controller.pause();

  @override
  Future<void> seekTo(Duration position) => _controller.seekTo(position);

  @override
  Future<void> setPlaybackSpeed(double speed) => _controller.setPlaybackSpeed(speed);

  @override
  Future<void> setVolume(double volume) => _controller.setVolume(volume);

  @override
  void addListener(VoidCallback listener) => _controller.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _controller.removeListener(listener);

  @override
  Future<void> dispose() => _controller.dispose();
}

typedef PlayerControllerFactory = Future<PlayerControllerAdapter> Function(Uri uri);

final playerControllerFactoryProvider = Provider<PlayerControllerFactory>((ref) {
  return (Uri uri) async {
    final controller = VideoPlayerController.networkUrl(uri);
    return VideoPlayerControllerAdapter(controller);
  };
});

class PlayerNotifier extends StateNotifier<PlayerState> {
  PlayerNotifier(this._createController)
      : super(const PlayerState(isInitializing: true));

  final PlayerControllerFactory _createController;
  PlayerControllerAdapter? _controller;
  VoidCallback? _controllerListener;

  VideoPlayerController? get videoController => _controller?.videoController;

  Future<void> initialize(PlayerSource source) async {
    final uri = Uri.tryParse(source.playUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      state = state.copyWith(
        isInitializing: false,
        errorMessage: '播放地址无效',
      );
      return;
    }

    state = const PlayerState(isInitializing: true);
    await _disposeController();

    try {
      final controller = await _createController(uri);
      _attachController(controller);
      await controller.initialize();
      await controller.play();
      _syncState();
    } catch (_) {
      await _disposeController();
      state = state.copyWith(
        isInitializing: false,
        errorMessage: '播放器初始化失败',
      );
    }
  }

  Future<void> togglePlayPause() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    if (state.isPlaying) {
      await controller.pause();
    } else {
      if (state.isCompleted && state.duration > Duration.zero) {
        await controller.seekTo(Duration.zero);
      }
      await controller.play();
    }
    _syncState();
  }

  Future<void> seekTo(Duration position) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    await controller.seekTo(position);
    _syncState();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    await controller.setPlaybackSpeed(speed);
    _syncState();
  }

  Future<void> setVolume(double volume) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    await controller.setVolume(volume);
    _syncState();
  }

  void _attachController(PlayerControllerAdapter controller) {
    _controller = controller;
    _controllerListener = _syncState;
    controller.addListener(_syncState);
  }

  void _syncState() {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    final value = controller.value;
    final duration = value.duration;
    final position = value.position;
    final isCompleted =
        duration > Duration.zero && position >= duration && !value.isPlaying;

    state = state.copyWith(
      isInitializing: false,
      isPlaying: value.isPlaying,
      isBuffering: value.isBuffering,
      isCompleted: isCompleted,
      position: position,
      duration: duration,
      playbackSpeed: value.playbackSpeed,
      volume: value.volume,
      aspectRatio: value.aspectRatio,
      clearError: true,
    );
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    final listener = _controllerListener;
    if (listener != null) {
      controller.removeListener(listener);
    }
    _controller = null;
    _controllerListener = null;
    await controller.dispose();
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }
}

final playerNotifierProvider = StateNotifierProvider.autoDispose
    .family<PlayerNotifier, PlayerState, PlayerSource>((ref, source) {
  return PlayerNotifier(ref.watch(playerControllerFactoryProvider));
});
