import 'package:dio/dio.dart';

import '../../../core/constants/constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/logger.dart';

class ApiClient {
  ApiClient({
    Dio? dio,
    String baseUrl = ApiConstants.defaultBaseUrl,
    Map<String, Object?>? headers,
    bool enableLog = true,
    int maxRetries = ApiConstants.maxRetries,
    Duration retryDelay = const Duration(milliseconds: ApiConstants.retryDelay),
  })  : _dio = dio ?? Dio(_buildOptions(baseUrl: baseUrl, headers: headers)),
        _maxRetries = maxRetries,
        _retryDelay = retryDelay {
    _dio.interceptors.addAll(<Interceptor>[
      InterceptorsWrapper(
        onRequest: (options, handler) {
          logger.d(
            'HTTP ${options.method} ${options.uri}',
          );
          handler.next(options);
        },
        onError: (error, handler) {
          logger.e(
            'HTTP ERROR ${error.requestOptions.method} ${error.requestOptions.uri}',
            error: error,
            stackTrace: error.stackTrace,
          );
          handler.next(error);
        },
      ),
      if (enableLog)
        LogInterceptor(
          requestBody: true,
          responseBody: false,
          logPrint: (message) => logger.d(message),
        ),
    ]);
  }

  final Dio _dio;
  final int _maxRetries;
  final Duration _retryDelay;

  Dio get dio => _dio;

  static BaseOptions _buildOptions({
    required String baseUrl,
    Map<String, Object?>? headers,
  }) {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.defaultTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.defaultTimeout),
      sendTimeout: const Duration(milliseconds: ApiConstants.defaultTimeout),
      responseType: ResponseType.json,
      contentType: ApiConstants.defaultContentType,
      headers: <String, Object?>{
        'Accept': ApiConstants.defaultAccept,
        'Content-Type': ApiConstants.defaultContentType,
        'User-Agent': ApiConstants.defaultUserAgent,
        ...?headers,
      },
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _requestWithRetry(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _requestWithRetry(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> _requestWithRetry<T>(
    Future<Response<T>> Function() request,
  ) async {
    DioException? lastError;
    StackTrace? lastStackTrace;

    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        return await request();
      } on DioException catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;

        if (attempt >= _maxRetries || !_shouldRetry(error)) {
          throw _mapDioException(error, stackTrace);
        }

        await Future<void>.delayed(_retryDelay);
      }
    }

    throw _mapDioException(lastError!, lastStackTrace ?? StackTrace.current);
  }

  bool _shouldRetry(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse =>
        (error.response?.statusCode ?? 0) >= 500,
      _ => false,
    };
  }

  AppException _mapDioException(DioException error, StackTrace stackTrace) {
    final message = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => '网络请求超时',
      DioExceptionType.cancel => '请求已取消',
      DioExceptionType.badCertificate => '证书校验失败',
      DioExceptionType.badResponse =>
        '服务响应异常 (${error.response?.statusCode ?? 'unknown'})',
      DioExceptionType.connectionError => '网络连接失败',
      DioExceptionType.unknown => error.message ?? '网络请求失败',
    };

    return AppException(
      type: AppErrorType.network,
      message: message,
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}
