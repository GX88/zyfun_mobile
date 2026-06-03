import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zyfun_mobile/core/constants/constants.dart';
import 'package:zyfun_mobile/core/errors/app_exception.dart';
import 'package:zyfun_mobile/data/datasources/remote/api_client.dart';

void main() {
  group('ApiClient', () {
    test('使用默认超时和请求头配置 Dio', () {
      final client = ApiClient(
        baseUrl: 'https://example.com',
        enableLog: false,
      );

      expect(client.dio.options.baseUrl, 'https://example.com');
      expect(
        client.dio.options.connectTimeout,
        const Duration(milliseconds: ApiConstants.defaultTimeout),
      );
      expect(
        client.dio.options.receiveTimeout,
        const Duration(milliseconds: ApiConstants.defaultTimeout),
      );
      expect(
        client.dio.options.headers['User-Agent'],
        ApiConstants.defaultUserAgent,
      );
      expect(
        client.dio.options.headers['Content-Type'],
        ApiConstants.defaultContentType,
      );
      expect(client.dio.interceptors, isNotEmpty);
      expect(
        client.dio.interceptors.whereType<InterceptorsWrapper>().length,
        1,
      );
    });

    test('合并自定义请求头', () {
      final client = ApiClient(
        baseUrl: 'https://example.com',
        headers: <String, Object?>{
          'Authorization': 'Bearer test-token',
          'X-App-Lang': 'zh-CN',
        },
        enableLog: false,
      );

      expect(
        client.dio.options.headers['Authorization'],
        'Bearer test-token',
      );
      expect(client.dio.options.headers['X-App-Lang'], 'zh-CN');
      expect(
        client.dio.options.headers['User-Agent'],
        ApiConstants.defaultUserAgent,
      );
    });

    test('启用日志时注册两个拦截器', () {
      final client = ApiClient(
        baseUrl: 'https://example.com',
        enableLog: true,
      );

      expect(
        client.dio.interceptors.whereType<LogInterceptor>().length,
        1,
      );
      expect(
        client.dio.interceptors.whereType<InterceptorsWrapper>().length,
        1,
      );
    });

    test('请求超时会映射为 AppException.network', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionTimeout,
                ),
              );
            },
          ),
        );
      final client = ApiClient(dio: dio, enableLog: false);

      await expectLater(
        () => client.get<Object>('/timeout'),
        throwsA(
          isA<AppException>()
              .having((error) => error.type, 'type', AppErrorType.network)
              .having((error) => error.message, 'message', '网络请求超时'),
        ),
      );
    });

    test('服务异常状态码会映射为可读错误', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.badResponse,
                  response: Response<Object>(
                    requestOptions: options,
                    statusCode: 503,
                  ),
                ),
              );
            },
          ),
        );
      final client = ApiClient(dio: dio, enableLog: false);

      await expectLater(
        () => client.get<Object>('/service-unavailable'),
        throwsA(
          isA<AppException>().having(
            (error) => error.message,
            'message',
            '服务响应异常 (503)',
          ),
        ),
      );
    });
  });
}
