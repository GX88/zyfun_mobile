import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zyfun_mobile/core/errors/app_exception.dart';
import 'package:zyfun_mobile/data/datasources/remote/api_client.dart';
import 'package:zyfun_mobile/data/datasources/remote/parse_api.dart';
import 'package:zyfun_mobile/data/models/analyze.dart';

void main() {
  group('ParseApi', () {
    test('Web 型解析会拼接解析地址', () async {
      final api = ParseApi(
        apiClient: ApiClient(dio: Dio(), enableLog: false),
      );

      const analyze = Analyze(
        id: 'analyze-1',
        key: 'web',
        name: '网页解析',
        api: 'https://jx.example.com/?url=',
        createdAt: 1,
        updatedAt: 2,
      );

      final url = await api.resolvePlayUrl(
        analyze: analyze,
        episodeUrl: 'https://video.example.com/play?id=1',
      );

      expect(
        url,
        'https://jx.example.com/?url=https%3A%2F%2Fvideo.example.com%2Fplay%3Fid%3D1',
      );
    });

    test('JSON 型解析会提取真实播放地址', () async {
      final api = ParseApi(
        apiClient: ApiClient(
          dio: _buildJsonDio(<String, dynamic>{
            'data': <String, dynamic>{
              'url': 'https://cdn.example.com/video.m3u8',
            },
          }),
          enableLog: false,
        ),
      );

      const analyze = Analyze(
        id: 'analyze-2',
        key: 'json',
        name: 'JSON解析',
        api: '/parse',
        type: 2,
        createdAt: 1,
        updatedAt: 2,
      );

      final url = await api.resolvePlayUrl(
        analyze: analyze,
        episodeUrl: 'https://video.example.com/play?id=1',
      );

      expect(url, 'https://cdn.example.com/video.m3u8');
    });

    test('JSON 型解析缺少结果会抛出解析错误', () async {
      final api = ParseApi(
        apiClient: ApiClient(
          dio: _buildJsonDio(<String, dynamic>{'code': 500}),
          enableLog: false,
        ),
      );

      const analyze = Analyze(
        id: 'analyze-3',
        key: 'json',
        name: 'JSON解析',
        api: '/parse',
        type: 2,
        createdAt: 1,
        updatedAt: 2,
      );

      await expectLater(
        () => api.resolvePlayUrl(
          analyze: analyze,
          episodeUrl: 'https://video.example.com/play?id=1',
        ),
        throwsA(
          isA<AppException>().having(
            (error) => error.type,
            'type',
            AppErrorType.parse,
          ),
        ),
      );
    });
  });
}

Dio _buildJsonDio(Map<String, dynamic> responseData) {
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
