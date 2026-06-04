import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zyfun_mobile/presentation/providers/danmaku_provider.dart';
import 'package:zyfun_mobile/presentation/providers/player_provider.dart';

void main() {
  group('danmakuItemsProvider', () {
    test('会为播放器源生成按时间排序的本地演示弹幕', () async {
      const source = PlayerSource(
        id: 'video-1',
        title: '测试视频',
        playUrl: 'https://example.com/video.mp4',
        episode: '第 3 集',
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = await container.read(danmakuItemsProvider(source).future);

      expect(items, isNotEmpty);
      expect(items.any((item) => item.text.contains('测试视频')), isTrue);
      expect(items.any((item) => item.text.contains('第 3 集')), isTrue);
      expect(items.map((item) => item.time), orderedEquals(items.map((item) => item.time).toList()..sort()));
    });
  });
}
