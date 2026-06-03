import 'package:dio/dio.dart';

import '../../../core/constants/constants.dart';
import '../../../core/errors/app_exception.dart';

class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? Dio(_buildOptions()) {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false,
      ),
    );
  }

  final Dio _dio;

  static BaseOptions _buildOptions() {
    return BaseOptions(
      connectTimeout: const Duration(milliseconds: ApiConstants.defaultTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.defaultTimeout),
      sendTimeout: const Duration(milliseconds: ApiConstants.defaultTimeout),
      responseType: ResponseType.json,
      headers: <String, Object>{
        'User-Agent': 'zyfun-mobile/1.0.0',
      },
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error, stackTrace) {
      throw _mapDioException(error, stackTrace);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error, stackTrace) {
      throw _mapDioException(error, stackTrace);
    }
  }

  AppException _mapDioException(DioException error, StackTrace stackTrace) {
    return AppException(
      type: AppErrorType.network,
      message: error.message ?? '网络请求失败',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}
