import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zyfun_mobile/presentation/providers/player_provider.dart';
import 'package:zyfun_mobile/services/background_playback_service.dart';

void main() {
  test('AppAudioHandler 会同步媒体信息与播放状态', () {
    final handler = AppAudioHandler();
    const source = PlayerSource(
      id: 'video-1',
      title: '测试视频',
      playUrl: 'https://example.com/1.m3u8',
      episode: '第 1 集',
    );

    handler.syncSource(
      source: source,
      queueIndex: 0,
      playlist: const <Map<String, String>>[
        <String, String>{'name': '第 1 集', 'url': 'https://example.com/1.m3u8'},
        <String, String>{'name': '第 2 集', 'url': 'https://example.com/2.m3u8'},
      ],
    );
    handler.syncState(
      const PlayerState(
        isPlaying: true,
        position: Duration(seconds: 10),
        duration: Duration(minutes: 20),
      ),
      canSkipNext: true,
      queueIndex: 0,
    );

    expect(handler.mediaItem.value?.title, '测试视频');
    expect(handler.queue.value.length, 2);
    expect(handler.playbackState.value.playing, isTrue);
    expect(handler.playbackState.value.processingState, AudioProcessingState.ready);
    expect(handler.playbackState.value.controls, contains(MediaControl.skipToNext));
  });
}
