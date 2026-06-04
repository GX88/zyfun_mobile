import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zyfun_mobile/presentation/pages/player/player_page.dart';
import 'package:zyfun_mobile/presentation/providers/player_provider.dart';
import 'package:zyfun_mobile/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PlayerPage 渲染播放信息并支持全屏切换', (tester) async {
    final fakeController = _FakePlayerController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          playerControllerFactoryProvider.overrideWithValue(
            (uri) async => fakeController,
          ),
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

    await tester.pumpAndSettle();

    expect(find.text('播放状态'), findsOneWidget);
    expect(find.text('页面内嵌'), findsOneWidget);
    expect(find.text('全屏播放'), findsOneWidget);

    await tester.tap(find.text('全屏播放'));
    await tester.pumpAndSettle();

    expect(find.text('退出全屏'), findsOneWidget);
    expect(find.text('切回页面模式'), findsOneWidget);

    await tester.tap(find.text('切回页面模式'));
    await tester.pumpAndSettle();

    expect(find.text('全屏播放'), findsOneWidget);
  });

  testWidgets('PlayerPage 对无效地址展示错误信息', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _TestPlayerApp(
          child: PlayerPage(
            id: 'video-2',
            title: '错误视频',
            playUrl: 'invalid-url',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('播放地址无效'), findsOneWidget);
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

  void _notify() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      listener();
    }
  }
}
