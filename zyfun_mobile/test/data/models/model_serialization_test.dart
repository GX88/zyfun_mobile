import 'package:flutter_test/flutter_test.dart';
import 'package:zyfun_mobile/data/models/analyze.dart';
import 'package:zyfun_mobile/data/models/favorite.dart';
import 'package:zyfun_mobile/data/models/history.dart';
import 'package:zyfun_mobile/data/models/iptv.dart';
import 'package:zyfun_mobile/data/models/setting.dart';
import 'package:zyfun_mobile/data/models/site.dart';
import 'package:zyfun_mobile/data/models/video.dart';

void main() {
  group('Site', () {
    test('JSON 序列化和 getter 正确', () {
      const site = Site(
        id: 'site-1',
        key: 'key-1',
        name: '测试站点',
        api: 'https://example.com/api',
        search: 1,
        type: 6,
        createdAt: 1,
        updatedAt: 2,
      );

      final json = site.toJson();
      final restored = Site.fromJson(json);

      expect(restored, site);
      expect(site.isValid, isTrue);
      expect(site.isSearchSite, isTrue);
      expect(site.typeName, 'T4_DRPYS');
      expect(Site.empty.isValid, isFalse);
    });
  });

  group('Iptv 和 Channel', () {
    test('JSON 序列化和类型判断正确', () {
      const iptv = Iptv(
        id: 'iptv-1',
        key: 'iptv-key',
        name: '直播源',
        api: 'https://example.com/live.m3u',
        type: 2,
        createdAt: 1,
        updatedAt: 2,
      );

      final json = iptv.toJson();
      final restored = Iptv.fromJson(json);

      expect(restored, iptv);
      expect(iptv.isValid, isTrue);
      expect(iptv.isLocal, isTrue);
      expect(iptv.isRemote, isFalse);
      expect(Iptv.empty.isValid, isFalse);

      const channel = Channel(id: 'c1', name: 'CCTV-1', url: 'https://example.com');
      expect(Channel.fromJson(channel.toJson()), channel);
    });
  });

  group('Analyze', () {
    test('JSON 序列化和类型判断正确', () {
      const analyze = Analyze(
        id: 'analyze-1',
        key: 'jx',
        name: '解析一号',
        api: 'https://example.com/jx',
        type: 2,
        createdAt: 1,
        updatedAt: 2,
      );

      final json = analyze.toJson();
      final restored = Analyze.fromJson(json);

      expect(restored, analyze);
      expect(analyze.isValid, isTrue);
      expect(analyze.isJsonType, isTrue);
      expect(analyze.isWebType, isFalse);
      expect(Analyze.empty.isValid, isFalse);
    });
  });

  group('Setting', () {
    test('默认值和嵌套配置序列化正确', () {
      const setting = Setting(
        theme: 'dark',
        proxy: ProxyConfig(type: 'custom', url: 'http://127.0.0.1:7890'),
        site: SiteConfig(searchMode: 'global', filterMode: true),
        player: PlayerConfig(type: 'media_kit', external: 'vlc'),
        timeout: 8000,
      );

      final json = setting.toJson();
      final restored = Setting.fromJson(json);

      expect(restored, setting);
      expect(const Setting().theme, 'system');
      expect(const Setting().hardwareAcceleration, isTrue);
      expect(const Setting().timeout, 5000);
    });
  });

  group('Video 和 VideoDetail', () {
    test('序列化与 getter 正确', () {
      const video = Video(
        id: 'video-1',
        title: '测试视频',
        cover: 'https://example.com/cover.jpg',
        description: '简介',
        siteId: 'site-1',
        episodes: <String>['第1集'],
        playUrls: <Map<String, String>>[
          <String, String>{'name': '第1集', 'url': 'https://example.com/play/1'},
        ],
      );

      final restored = Video.fromJson(video.toJson());
      expect(restored, video);
      expect(video.isValid, isTrue);
      expect(video.hasCover, isTrue);
      expect(video.hasEpisodes, isTrue);
      expect(Video.empty.isValid, isFalse);

      const detail = VideoDetail(
        video: video,
        episodes: <String>['第1集'],
        playUrls: <Map<String, String>>[
          <String, String>{'name': '第1集', 'url': 'https://example.com/play/1'},
        ],
      );
      expect(VideoDetail.fromJson(detail.toJson()), detail);
    });
  });

  group('History', () {
    test('序列化和进度计算正确', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final expiredTime = now - (31 * 24 * 60 * 60 * 1000);
      final history = History(
        id: 'history-1',
        siteId: 'site-1',
        videoId: 'video-1',
        title: '测试历史',
        episodeUrl: 'https://example.com/play/1',
        progress: 90 * 1000,
        duration: 120 * 1000,
        createdAt: now,
        updatedAt: expiredTime,
      );

      final restored = History.fromJson(history.toJson());

      expect(restored, history);
      expect(history.isValid, isTrue);
      expect(history.hasProgress, isTrue);
      expect(history.progressPercent, closeTo(0.75, 0.001));
      expect(history.progressText, '01:30');
      expect(history.durationText, '02:00');
      expect(history.isExpired, isTrue);
      expect(History.empty.isValid, isFalse);
    });
  });

  group('Favorite', () {
    test('序列化和封面判断正确', () {
      const favorite = Favorite(
        id: 'favorite-1',
        siteId: 'site-1',
        videoId: 'video-1',
        title: '收藏项',
        cover: 'https://example.com/cover.jpg',
        createdAt: 1,
      );

      final restored = Favorite.fromJson(favorite.toJson());

      expect(restored, favorite);
      expect(favorite.isValid, isTrue);
      expect(favorite.hasCover, isTrue);
      expect(Favorite.empty.isValid, isFalse);
    });
  });
}
