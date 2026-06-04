import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'player_provider.dart';

class DanmakuItem {
  const DanmakuItem({
    required this.text,
    required this.time,
    this.colorHex = 0xFFFFFFFF,
  });

  final String text;
  final Duration time;
  final int colorHex;
}

typedef DanmakuLoader = Future<List<DanmakuItem>> Function(PlayerSource source);

final danmakuLoaderProvider = Provider<DanmakuLoader>((ref) {
  return (PlayerSource source) async {
    final title = source.title.trim().isEmpty ? '当前视频' : source.title.trim();
    final episode = source.episode?.trim();

    return <DanmakuItem>[
      const DanmakuItem(text: '媒体信息准备中', time: Duration(seconds: 1)),
      DanmakuItem(text: '正在播放：$title', time: const Duration(seconds: 2)),
      if (episode != null && episode.isNotEmpty)
        DanmakuItem(text: '已切换到 $episode', time: const Duration(seconds: 8)),
      const DanmakuItem(text: 'media_kit 播放器已接入弹幕时间轴', time: Duration(seconds: 14)),
      const DanmakuItem(text: '左侧上下滑调亮度，右侧上下滑调音量', time: Duration(seconds: 20)),
      const DanmakuItem(text: '水平滑动可快速调整播放进度', time: Duration(seconds: 28)),
      const DanmakuItem(text: '当前为本地演示弹幕，后续可替换真实弹幕源', time: Duration(seconds: 36)),
    ];
  };
});

final danmakuItemsProvider = FutureProvider.autoDispose
    .family<List<DanmakuItem>, PlayerSource>((ref, source) async {
  return ref.watch(danmakuLoaderProvider)(source);
});
