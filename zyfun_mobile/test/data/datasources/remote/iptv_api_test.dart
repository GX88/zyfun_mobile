import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zyfun_mobile/data/datasources/remote/api_client.dart';
import 'package:zyfun_mobile/data/datasources/remote/iptv_api.dart';
import 'package:zyfun_mobile/data/models/iptv.dart';

void main() {
  group('IptvApi', () {
    test('解析 M3U 频道列表', () {
      final api = IptvApi(
        apiClient: ApiClient(dio: Dio(), enableLog: false),
      );

      final channels = api.parseM3u(_sampleM3u);
      expect(channels, hasLength(2));
      expect(channels.first.name, 'CCTV-1');
      expect(channels.first.logo, 'https://image.example.com/cctv1.png');
      expect(channels.first.group, '央视');
      expect(channels.first.headers?['http-user-agent'], 'ZYFun/1.0');
      expect(channels.first.url, 'https://live.example.com/cctv1.m3u8');
      expect(channels.last.name, '湖南卫视');
    });

    test('远程直播源可以下载并解析 M3U', () async {
      final api = IptvApi(
        apiClient: ApiClient(
          dio: _buildTextDio(_sampleM3u),
          enableLog: false,
        ),
      );

      const iptv = Iptv(
        id: 'iptv-1',
        key: 'remote',
        name: '远程直播源',
        api: 'https://example.com/live.m3u',
        createdAt: 1,
        updatedAt: 2,
      );

      final channels = await api.getChannels(iptv);
      expect(channels, hasLength(2));
      expect(channels.first.name, 'CCTV-1');
    });

    test('本地文本源直接使用 api 字段内容', () async {
      final api = IptvApi(
        apiClient: ApiClient(dio: Dio(), enableLog: false),
      );

      const iptv = Iptv(
        id: 'iptv-2',
        key: 'text',
        name: '文本直播源',
        api: _sampleM3u,
        type: 3,
        createdAt: 1,
        updatedAt: 2,
      );

      final channels = await api.getChannels(iptv);
      expect(channels, hasLength(2));
      expect(channels.last.name, '湖南卫视');
    });
  });
}

Dio _buildTextDio(String content) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response<String>(
            requestOptions: options,
            data: content,
            statusCode: 200,
          ),
        );
      },
    ),
  );
  return dio;
}

const String _sampleM3u = '''
#EXTM3U
#EXTINF:-1 tvg-logo="https://image.example.com/cctv1.png" group-title="央视",CCTV-1
#EXTVLCOPT:http-user-agent=ZYFun/1.0
https://live.example.com/cctv1.m3u8
#EXTINF:-1 group-title="卫视",湖南卫视
https://live.example.com/hunan.m3u8
''';
