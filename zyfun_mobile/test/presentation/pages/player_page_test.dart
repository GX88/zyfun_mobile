import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zyfun_mobile/data/models/history.dart';
import 'package:zyfun_mobile/domain/repositories/history_repository.dart';
import 'package:zyfun_mobile/presentation/pages/player/player_page.dart';
import 'package:zyfun_mobile/presentation/providers/app_providers.dart';
import 'package:zyfun_mobile/presentation/providers/player_provider.dart';
import 'package:zyfun_mobile/services/background_playback_service.dart';
import 'package:zyfun_mobile/services/player_platform_bridge.dart';
import 'package:zyfun_mobile/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PlayerPage 渲染基础信息和控制入口', (tester) async {
    final fakeController = _FakePlayerController();
    final fakeAudioHandler = AppAudioHandler();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          playerControllerFactoryProvider.overrideWithValue(
            (uri, headers) async => fakeController,
          ),
          backgroundPlaybackHandlerProvider.overrideWithValue(fakeAudioHandler),
          playerPlatformBridgeProvider.overrideWithValue(_FakePlayerPlatformBridge()),
          playerProgressSaveIntervalProvider.overrideWithValue(const Duration(days: 1)),
        ],
        child: const _TestPlayerApp(
          child: PlayerPage(
            id: 'video-1',
            title: '测试视频',
            playUrl: 'https://example.com/video.mp4',
            episode: '第 1 集',
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('测试视频'), findsWidgets);
    expect(find.text('第 1 集'), findsOneWidget);
    expect(find.text('播放器未就绪'), findsOneWidget);
  });

  testWidgets('PlayerPage 对无效地址展示错误信息', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          backgroundPlaybackHandlerProvider.overrideWithValue(AppAudioHandler()),
          playerPlatformBridgeProvider.overrideWithValue(_FakePlayerPlatformBridge()),
          playerProgressSaveIntervalProvider.overrideWithValue(const Duration(days: 1)),
        ],
        child: const _TestPlayerApp(
          child: PlayerPage(
            id: 'video-2',
            title: '错误视频',
            playUrl: 'invalid-url',
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('播放地址无效'), findsOneWidget);
  });

  testWidgets('PlayerPage 初始化时会探测 PIP 支持状态', (tester) async {
    final fakeController = _FakePlayerController();
    final pipBridge = _RecordingPlayerPlatformBridge(isSupported: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          playerControllerFactoryProvider.overrideWithValue(
            (uri, headers) async => fakeController,
          ),
          backgroundPlaybackHandlerProvider.overrideWithValue(AppAudioHandler()),
          playerPlatformBridgeProvider.overrideWithValue(pipBridge),
          playerProgressSaveIntervalProvider.overrideWithValue(const Duration(days: 1)),
        ],
        child: const _TestPlayerApp(
          child: PlayerPage(
            id: 'video-3',
            title: 'PIP 视频',
            playUrl: 'https://example.com/video.mp4',
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(pipBridge.supportCheckCalls, 1);
  });

  testWidgets('PlayerPage 会恢复历史进度并定时回写', (tester) async {
    final fakeController = _FakePlayerController();
    final historyRepository = _FakeHistoryRepository(
      existing: const History(
        id: 'site-1_video-1_第 1 集',
        siteId: 'site-1',
        videoId: 'video-1',
        title: '测试视频',
        episodeUrl: 'https://example.com/video.mp4',
        episodeName: '第 1 集',
        progress: 30000,
        duration: 120000,
        createdAt: 1,
        updatedAt: 1,
      ),
    );
    final fakeAudioHandler = AppAudioHandler();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          playerControllerFactoryProvider.overrideWithValue(
            (uri, headers) async => fakeController,
          ),
          historyRepositoryProvider.overrideWithValue(historyRepository),
          backgroundPlaybackHandlerProvider.overrideWithValue(fakeAudioHandler),
          playerPlatformBridgeProvider.overrideWithValue(_FakePlayerPlatformBridge()),
          playerProgressSaveIntervalProvider.overrideWithValue(const Duration(milliseconds: 10)),
        ],
        child: const _TestPlayerApp(
          child: PlayerPage(
            id: 'video-1',
            title: '测试视频',
            playUrl: 'https://example.com/video.mp4',
            episode: '第 1 集',
            siteId: 'site-1',
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(fakeController.seekCalls, contains(const Duration(seconds: 30)));

    fakeController.setPosition(const Duration(seconds: 42));
    await tester.pump(const Duration(milliseconds: 30));

    expect(historyRepository.saved.last.progress, 42000);
  });

  testWidgets('PlayerPage 播放完成后会自动连播下一集', (tester) async {
    final fakeController = _FakePlayerController();
    String? routedEpisode;
    final fakeAudioHandler = AppAudioHandler();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          playerControllerFactoryProvider.overrideWithValue(
            (uri, headers) async => fakeController,
          ),
          historyRepositoryProvider.overrideWithValue(_FakeHistoryRepository()),
          backgroundPlaybackHandlerProvider.overrideWithValue(fakeAudioHandler),
          playerPlatformBridgeProvider.overrideWithValue(_FakePlayerPlatformBridge()),
          playerProgressSaveIntervalProvider.overrideWithValue(const Duration(days: 1)),
        ],
        child: _TestPlayerRouterApp(
          onPlayerRoute: (state) => routedEpisode = state.uri.queryParameters['episode'],
          child: const PlayerPage(
            id: 'video-1',
            title: '测试视频',
            playUrl: 'https://example.com/1.m3u8',
            episode: '第 1 集',
            siteId: 'site-1',
            currentIndex: 0,
            playlist: <Map<String, String>>[
              <String, String>{'name': '第 1 集', 'url': 'https://example.com/1.m3u8'},
              <String, String>{'name': '第 2 集', 'url': 'https://example.com/2.m3u8'},
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    fakeController.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(routedEpisode, '第 2 集');
  });
}

class _TestPlayerApp extends StatelessWidget {
  const _TestPlayerApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: child,
    );
  }
}

class _TestPlayerRouterApp extends StatelessWidget {
  const _TestPlayerRouterApp({required this.child, this.onPlayerRoute});

  final Widget child;
  final void Function(GoRouterState state)? onPlayerRoute;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/player/video-1',
      routes: <RouteBase>[
        GoRoute(
          path: '/player/:id',
          builder: (context, state) {
            onPlayerRoute?.call(state);
            return child;
          },
        ),
      ],
    );

    return ShadApp.router(
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}

class _FakePlayerPlatformBridge extends PlayerPlatformBridge {
  _FakePlayerPlatformBridge() : super(channel: const MethodChannel('zyfun_mobile/player_test'));

  @override
  Future<bool> isPictureInPictureSupported() async => false;

  @override
  Future<bool> enterPictureInPicture() async => false;
}

class _RecordingPlayerPlatformBridge extends PlayerPlatformBridge {
  _RecordingPlayerPlatformBridge({required this.isSupported})
      : super(channel: const MethodChannel('zyfun_mobile/player_test_recording'));

  final bool isSupported;
  int supportCheckCalls = 0;

  @override
  Future<bool> isPictureInPictureSupported() async {
    supportCheckCalls += 1;
    return isSupported;
  }
}

class _FakePlayerController implements PlayerControllerAdapter {
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

  final List<VoidCallback> _listeners = <VoidCallback>[];
  final List<Duration> seekCalls = <Duration>[];

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
      duration: Duration(minutes: 24),
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
    seekCalls.add(position);
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
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @override
  Future<void> dispose() async {}

  void setPosition(Duration position) {
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

  void complete() {
    _value = PlayerControllerValue(
      isInitialized: _value.isInitialized,
      isPlaying: false,
      isBuffering: false,
      position: _value.duration,
      duration: _value.duration,
      playbackSpeed: _value.playbackSpeed,
      volume: _value.volume,
      aspectRatio: _value.aspectRatio,
    );
    _notify();
  }

  void _notify() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      listener();
    }
  }
}

class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository({History? existing}) {
    if (existing != null) {
      _items[existing.id] = existing;
    }
  }

  final Map<String, History> _items = <String, History>{};
  final List<History> saved = <History>[];

  @override
  Future<void> addHistory(History history) async {
    _items[history.id] = history;
    saved.add(history);
  }

  @override
  Future<void> clearAllHistories() async {
    _items.clear();
  }

  @override
  Future<void> deleteHistory(String id) async {
    _items.remove(id);
  }

  @override
  Future<List<History>> getAllHistories() async => _items.values.toList(growable: false);

  @override
  Future<History?> getHistoryById(String id) async => _items[id];

  @override
  Future<List<History>> getRecentHistories({int limit = 50}) async {
    return _items.values.take(limit).toList(growable: false);
  }

  @override
  Future<void> updateHistory(History history) async {
    _items[history.id] = history;
    saved.add(history);
  }
}
