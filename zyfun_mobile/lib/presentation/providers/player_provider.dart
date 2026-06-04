import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class PlayerSource {
  const PlayerSource({
    required this.id,
    required this.title,
    required this.playUrl,
    this.episode,
    this.httpHeaders,
  });

  final String id;
  final String title;
  final String playUrl;
  final String? episode;
  final Map<String, String>? httpHeaders;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlayerSource &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            title == other.title &&
            playUrl == other.playUrl &&
            episode == other.episode &&
            mapEquals(httpHeaders, other.httpHeaders);
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        playUrl,
        episode,
        Object.hashAll([
          ...?httpHeaders?.entries.map((entry) => Object.hash(entry.key, entry.value)),
        ]),
      );
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
    this.volume = 100,
    this.brightness = 50,
    this.aspectRatio = 16 / 9,
    this.formatLabel = '未知格式',
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
  final double brightness;
  final double aspectRatio;
  final String formatLabel;
  final String? errorMessage;

  bool get isReady => errorMessage == null && !isInitializing;

  PlayerState copyWith({
    bool? isInitializing,
    bool? isPlaying,
    bool? isBuffering,
    bool? isCompleted,
    Duration? position,
    Duration? duration,
    double? playbackSpeed,
    double? volume,
    double? brightness,
    double? aspectRatio,
    String? formatLabel,
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
      brightness: brightness ?? this.brightness,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      formatLabel: formatLabel ?? this.formatLabel,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
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

abstract class PlayerControllerAdapter {
  VideoController? get videoController;
  PlayerControllerValue get value;
  Stream<String> get errorStream;
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

class MediaKitControllerAdapter implements PlayerControllerAdapter {
  MediaKitControllerAdapter(this._player) : _videoController = VideoController(_player);

  final Player _player;
  final VideoController _videoController;
  final StreamController<String> _errorController = StreamController<String>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = <StreamSubscription<dynamic>>[];
  final List<VoidCallback> _listeners = <VoidCallback>[];

  bool _isInitialized = false;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _rate = 1;
  double _volume = 100;
  double _aspectRatio = 16 / 9;

  @override
  VideoController get videoController => _videoController;

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  PlayerControllerValue get value => PlayerControllerValue(
        isInitialized: _isInitialized,
        isPlaying: _player.state.playing,
        isBuffering: _isBuffering,
        position: _position,
        duration: _duration,
        playbackSpeed: _rate,
        volume: _volume,
        aspectRatio: _aspectRatio > 0 ? _aspectRatio : 16 / 9,
      );

  @override
  Future<void> initialize() async {
    _subscriptions.addAll(<StreamSubscription<dynamic>>[
      _player.stream.position.listen((value) {
        _position = value;
        _notifyListeners();
      }),
      _player.stream.duration.listen((value) {
        _duration = value;
        _notifyListeners();
      }),
      _player.stream.buffering.listen((value) {
        _isBuffering = value;
        _notifyListeners();
      }),
      _player.stream.rate.listen((value) {
        _rate = value;
        _notifyListeners();
      }),
      _player.stream.volume.listen((value) {
        _volume = value;
        _notifyListeners();
      }),
      _player.stream.width.listen((width) {
        final height = _player.state.height;
        if (width != null && height != null && width > 0 && height > 0) {
          _aspectRatio = width / height;
        }
        _notifyListeners();
      }),
      _player.stream.height.listen((height) {
        final width = _player.state.width;
        if (width != null && height != null && width > 0 && height > 0) {
          _aspectRatio = width / height;
        }
        _notifyListeners();
      }),
      _player.stream.error.listen((message) {
        if (!_errorController.isClosed) {
          _errorController.add(message);
        }
        _notifyListeners();
      }),
      _player.stream.playing.listen((_) => _notifyListeners()),
      _player.stream.completed.listen((_) => _notifyListeners()),
    ]);

    _isInitialized = true;
    _notifyListeners();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seekTo(Duration position) => _player.seek(position);

  @override
  Future<void> setPlaybackSpeed(double speed) => _player.setRate(speed);

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @override
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _errorController.close();
    await _player.dispose();
  }

  void _notifyListeners() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      listener();
    }
  }
}

typedef PlayerControllerFactory = Future<PlayerControllerAdapter> Function(
  Uri uri,
  Map<String, String> headers,
);

final playerControllerFactoryProvider = Provider<PlayerControllerFactory>((ref) {
  return (Uri uri, Map<String, String> headers) async {
    final player = Player();
    await player.open(
      Media(uri.toString(), httpHeaders: headers),
      play: false,
    );
    return MediaKitControllerAdapter(player);
  };
});

class PlayerNotifier extends StateNotifier<PlayerState> {
  PlayerNotifier(this._createController) : super(const PlayerState(isInitializing: true));

  final PlayerControllerFactory _createController;
  PlayerControllerAdapter? _controller;
  VoidCallback? _controllerListener;
  StreamSubscription<String>? _errorSubscription;

  VideoController? get videoController => _controller?.videoController;

  Future<void> initialize(PlayerSource source) async {
    final trimmedPlayUrl = source.playUrl.trim();
    final uri = Uri.tryParse(trimmedPlayUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      state = state.copyWith(
        isInitializing: false,
        errorMessage: '播放地址无效',
      );
      return;
    }

    state = PlayerState(
      isInitializing: true,
      formatLabel: _detectFormatLabel(uri),
    );
    await _disposeController();

    try {
      final controller = await _createController(
        uri,
        source.httpHeaders ?? const <String, String>{},
      );
      _attachController(controller);
      await controller.initialize();
      await controller.play();
      _syncState();
    } catch (error) {
      await _disposeController();
      final message = error.toString().trim();
      state = state.copyWith(
        isInitializing: false,
        errorMessage: message.isEmpty ? '播放器初始化失败' : message,
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

    final normalizedSpeed = speed.clamp(0.5, 3.0).toDouble();
    await controller.setPlaybackSpeed(normalizedSpeed);
    _syncState();
  }

  Future<void> setVolume(double volume) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    final normalizedVolume = volume.clamp(0, 100).toDouble();
    await controller.setVolume(normalizedVolume);
    _syncState();
  }

  void setBrightness(double brightness) {
    state = state.copyWith(brightness: brightness.clamp(0, 100).toDouble());
  }

  void _attachController(PlayerControllerAdapter controller) {
    _controller = controller;
    _controllerListener = _syncState;
    _errorSubscription = controller.errorStream.listen((message) {
      state = state.copyWith(
        isInitializing: false,
        errorMessage: message.isEmpty ? '播放器初始化失败' : message,
      );
    });
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
    await _errorSubscription?.cancel();
    _errorSubscription = null;

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

  String _detectFormatLabel(Uri uri) {
    final path = uri.path.toLowerCase();
    if (path.endsWith('.m3u8')) {
      return 'HLS';
    }
    if (path.endsWith('.mpd')) {
      return 'DASH';
    }
    if (path.endsWith('.mp4')) {
      return 'MP4';
    }
    if (path.endsWith('.flv')) {
      return 'FLV';
    }
    return '自动识别';
  }
}

final playerNotifierProvider = StateNotifierProvider.autoDispose
    .family<PlayerNotifier, PlayerState, PlayerSource>((ref, source) {
  return PlayerNotifier(ref.watch(playerControllerFactoryProvider));
});
