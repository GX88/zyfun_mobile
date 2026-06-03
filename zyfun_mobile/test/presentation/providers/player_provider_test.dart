import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zyfun_mobile/presentation/providers/player_provider.dart';

void main() {
  group('PlayerNotifier', () {
    const source = PlayerSource(
      id: 'video-1',
      title: '测试视频',
      playUrl: 'https://example.com/video.mp4',
      episode: '第 1 集',
    );

    test('初始化后进入播放状态并同步基础参数', () async {
      final fakeController = FakePlayerController();
      final container = ProviderContainer(
        overrides: <Override>[
          playerControllerFactoryProvider.overrideWithValue(
            (uri) async => fakeController,
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(playerNotifierProvider(source).notifier);
      await notifier.initialize(source);

      final state = container.read(playerNotifierProvider(source));
      expect(state.isInitializing, isFalse);
      expect(state.isPlaying, isTrue);
      expect(state.duration, const Duration(minutes: 20));
      expect(state.playbackSpeed, 1);
      expect(state.volume, 1);
    });

    test('切换播放、调节倍速音量和拖动进度会更新状态', () async {
      final fakeController = FakePlayerController();
      final container = ProviderContainer(
        overrides: <Override>[
          playerControllerFactoryProvider.overrideWithValue(
            (uri) async => fakeController,
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(playerNotifierProvider(source).notifier);
      await notifier.initialize(source);

      await notifier.togglePlayPause();
      expect(container.read(playerNotifierProvider(source)).isPlaying, isFalse);

      await notifier.setPlaybackSpeed(1.5);
      expect(container.read(playerNotifierProvider(source)).playbackSpeed, 1.5);

      await notifier.setVolume(0.4);
      expect(container.read(playerNotifierProvider(source)).volume, 0.4);

      await notifier.seekTo(const Duration(minutes: 5));
      expect(container.read(playerNotifierProvider(source)).position, const Duration(minutes: 5));
    });

    test('无效地址会给出错误状态', () async {
      const invalidSource = PlayerSource(
        id: 'video-2',
        title: '无效地址',
        playUrl: 'invalid-url',
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playerNotifierProvider(invalidSource).notifier);
      await notifier.initialize(invalidSource);

      final state = container.read(playerNotifierProvider(invalidSource));
      expect(state.isInitializing, isFalse);
      expect(state.errorMessage, '播放地址无效');
    });
  });
}

class FakePlayerController implements PlayerControllerAdapter {
  PlayerControllerValue _value = const PlayerControllerValue(
    isInitialized: false,
    isPlaying: false,
    isBuffering: false,
    position: Duration.zero,
    duration: Duration.zero,
    playbackSpeed: 1,
    volume: 1,
    aspectRatio: 16 / 9,
  );

  final List<void Function()> _listeners = <void Function()>[];

  @override
  get videoController => null;

  @override
  PlayerControllerValue get value => _value;

  @override
  Future<void> initialize() async {
    _value = const PlayerControllerValue(
      isInitialized: true,
      isPlaying: false,
      isBuffering: false,
      position: Duration.zero,
      duration: Duration(minutes: 20),
      playbackSpeed: 1,
      volume: 1,
      aspectRatio: 16 / 9,
    );
    _notify();
  }

  @override
  Future<void> play() async {
    _value = PlayerControllerValue(
      isInitialized: _value.isInitialized,
      isPlaying: true,
      isBuffering: false,
      position: _value.position,
      duration: _value.duration,
      playbackSpeed: _value.playbackSpeed,
      volume: _value.volume,
      aspectRatio: _value.aspectRatio,
    );
    _notify();
  }

  @override
  Future<void> pause() async {
    _value = PlayerControllerValue(
      isInitialized: _value.isInitialized,
      isPlaying: false,
      isBuffering: false,
      position: _value.position,
      duration: _value.duration,
      playbackSpeed: _value.playbackSpeed,
      volume: _value.volume,
      aspectRatio: _value.aspectRatio,
    );
    _notify();
  }

  @override
  Future<void> seekTo(Duration position) async {
    _value = PlayerControllerValue(
      isInitialized: _value.isInitialized,
      isPlaying: _value.isPlaying,
      isBuffering: false,
      position: position,
      duration: _value.duration,
      playbackSpeed: _value.playbackSpeed,
      volume: _value.volume,
      aspectRatio: _value.aspectRatio,
    );
    _notify();
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    _value = PlayerControllerValue(
      isInitialized: _value.isInitialized,
      isPlaying: _value.isPlaying,
      isBuffering: false,
      position: _value.position,
      duration: _value.duration,
      playbackSpeed: speed,
      volume: _value.volume,
      aspectRatio: _value.aspectRatio,
    );
    _notify();
  }

  @override
  Future<void> setVolume(double volume) async {
    _value = PlayerControllerValue(
      isInitialized: _value.isInitialized,
      isPlaying: _value.isPlaying,
      isBuffering: false,
      position: _value.position,
      duration: _value.duration,
      playbackSpeed: _value.playbackSpeed,
      volume: volume,
      aspectRatio: _value.aspectRatio,
    );
    _notify();
  }

  @override
  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  @override
  Future<void> dispose() async {}

  void _notify() {
    for (final listener in List<void Function()>.from(_listeners)) {
      listener();
    }
  }
}
