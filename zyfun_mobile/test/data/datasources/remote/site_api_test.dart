import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zyfun_mobile/data/datasources/remote/api_client.dart';
import 'package:zyfun_mobile/data/datasources/remote/site_api.dart';
import 'package:zyfun_mobile/data/models/site.dart';

void main() {
  const site = Site(
    id: 'site-1',
    key: 'demo',
    name: '演示站点',
    api: '/api.php/provide/vod/',
    type: 1,
    createdAt: 1,
    updatedAt: 2,
  );

  group('SiteApi', () {
    test('解析分类列表', () async {
      final siteApi = SiteApi(
        apiClient: ApiClient(
          dio: _buildDioWithResponse(<String, dynamic>{
            'class': <Map<String, Object?>>[
              <String, Object?>{'type_id': 1, 'type_name': '电影'},
              <String, Object?>{'type_id': 2, 'type_name': '电视剧'},
            ],
          }),
          enableLog: false,
        ),
      );

      final categories = await siteApi.getCategories(site);
      expect(categories, hasLength(2));
      expect(categories.first.id, '1');
      expect(categories.first.name, '电影');
      expect(categories.first.isHome, isTrue);
    });

    test('解析分类视频列表', () async {
      final siteApi = SiteApi(
        apiClient: ApiClient(
          dio: _buildDioWithResponse(_mockVodListResponse()),
          enableLog: false,
        ),
      );

      final videos = await siteApi.getVideosByCategory(site, '1', 1);
      expect(videos, hasLength(1));
      expect(videos.first.id, '100');
      expect(videos.first.title, '三体');
      expect(videos.first.episodes, <String>['第1集', '第2集']);
      expect(videos.first.playUrls.first['url'], 'https://play.example.com/1.m3u8');
    });

    test('解析搜索结果', () async {
      final siteApi = SiteApi(
        apiClient: ApiClient(
          dio: _buildDioWithResponse(_mockVodListResponse()),
          enableLog: false,
        ),
      );

      final videos = await siteApi.searchVideos(site, '三体');
      expect(videos, hasLength(1));
      expect(videos.first.title, '三体');
    });

    test('解析详情结果', () async {
      final siteApi = SiteApi(
        apiClient: ApiClient(
          dio: _buildDioWithResponse(_mockVodListResponse()),
          enableLog: false,
        ),
      );

      final detail = await siteApi.getVideoDetail(site, '100');
      expect(detail, isNotNull);
      expect(detail?.video.id, '100');
      expect(detail?.episodes, <String>['第1集', '第2集']);
    });

    test('非 T1_JSON 站点会抛出不支持错误', () async {
      final siteApi = SiteApi(
        apiClient: ApiClient(
          dio: _buildDioWithResponse(<String, dynamic>{}),
          enableLog: false,
        ),
      );
      const unsupportedSite = Site(
        id: 'site-2',
        key: 'xml',
        name: 'XML站点',
        api: '/xml',
        type: 0,
        createdAt: 1,
        updatedAt: 2,
      );

      await expectLater(
        () => siteApi.getCategories(unsupportedSite),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}

Dio _buildDioWithResponse(Map<String, dynamic> responseData) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: options,
            data: responseData,
            statusCode: 200,
          ),
        );
      },
    ),
  );
  return dio;
}

Map<String, dynamic> _mockVodListResponse() {
  return <String, dynamic>{
    'list': <Map<String, Object?>>[
      <String, Object?>{
        'vod_id': '100',
        'vod_name': '三体',
        'vod_pic': 'https://image.example.com/100.jpg',
        'vod_remarks': '更新至第2集',
        'vod_year': '2025',
        'vod_area': '中国大陆',
        'type_name': '科幻',
        'vod_actor': '张鲁一',
        'vod_director': '杨磊',
        'vod_content': '文明的碰撞。',
        'vod_play_from': '在线播放',
        'vod_play_url': r'第1集$https://play.example.com/1.m3u8#第2集$https://play.example.com/2.m3u8',
      },
    ],
  };
}
