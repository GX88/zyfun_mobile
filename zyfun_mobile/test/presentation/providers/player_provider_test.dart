import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
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
      Uri? capturedUri;
      Map<String, String>? capturedHeaders;
      final container = ProviderContainer(
        overrides: <Override>[
          playerControllerFactoryProvider.overrideWithValue(
            (uri, headers) async {
              capturedUri = uri;
              capturedHeaders = headers;
              return fakeController;
            },
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
      expect(state.volume, 100);
      expect(state.brightness, 50);
      expect(state.formatLabel, 'MP4');
      expect(capturedUri.toString(), 'https://example.com/video.mp4');
      expect(capturedHeaders, isEmpty);
    });

    test('切换播放、调节倍速音量和拖动进度会更新状态', () async {
      final fakeController = FakePlayerController();
      final container = ProviderContainer(
        overrides: <Override>[
          playerControllerFactoryProvider.overrideWithValue(
            (uri, headers) async => fakeController,
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

      await notifier.setVolume(40);
      expect(container.read(playerNotifierProvider(source)).volume, 40);

      notifier.setBrightness(70);
      expect(container.read(playerNotifierProvider(source)).brightness, 70);

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

    test('初始化异常会透出底层错误信息', () async {
      final container = ProviderContainer(
        overrides: <Override>[
          playerControllerFactoryProvider.overrideWithValue(
            (uri, headers) async => throw Exception('HTTP 403 Forbidden'),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(playerNotifierProvider(source).notifier);
      await notifier.initialize(source);

      final state = container.read(playerNotifierProvider(source));
      expect(state.isInitializing, isFalse);
      expect(state.errorMessage, contains('HTTP 403 Forbidden'));
    });

    test('初始化时会透传直播流请求头', () async {
      const sourceWithHeaders = PlayerSource(
        id: 'live-1',
        title: '直播测试',
        playUrl: ' https://example.com/live.m3u8 ',
        httpHeaders: <String, String>{
          'User-Agent': 'ZYFun/1.0',
          'Referer': 'https://example.com',
        },
      );
      final fakeController = FakePlayerController();
      Uri? capturedUri;
      Map<String, String>? capturedHeaders;
      final container = ProviderContainer(
        overrides: <Override>[
          playerControllerFactoryProvider.overrideWithValue(
            (uri, headers) async {
              capturedUri = uri;
              capturedHeaders = headers;
              return fakeController;
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(playerNotifierProvider(sourceWithHeaders).notifier);
      await notifier.initialize(sourceWithHeaders);

      expect(capturedUri.toString(), 'https://example.com/live.m3u8');
      expect(capturedHeaders, sourceWithHeaders.httpHeaders);
      expect(container.read(playerNotifierProvider(sourceWithHeaders)).formatLabel, 'HLS');
    });

    test('倍速和音量会被限制在允许范围内', () async {
      final fakeController = FakePlayerController();
      final container = ProviderContainer(
        overrides: <Override>[
          playerControllerFactoryProvider.overrideWithValue(
            (uri, headers) async => fakeController,
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(playerNotifierProvider(source).notifier);
      await notifier.initialize(source);

      await notifier.setPlaybackSpeed(10);
      await notifier.setVolume(200);
      notifier.setBrightness(-5);

      final state = container.read(playerNotifierProvider(source));
      expect(state.playbackSpeed, 3);
      expect(state.volume, 100);
      expect(state.brightness, 0);
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
    volume: 100,
    aspectRatio: 16 / 9,
  );

  final List<void Function()> _listeners = <void Function()>[];

  @override
  VideoController? get videoController => null;

  @override
  Stream<String> get errorStream => const Stream<String>.empty();

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
      volume: 100,
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
