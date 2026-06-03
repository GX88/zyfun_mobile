import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../models/analyze.dart';
import 'api_client.dart';

class ParseApi {
  ParseApi({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<String> resolvePlayUrl({
    required Analyze analyze,
    required String episodeUrl,
  }) async {
    if (episodeUrl.trim().isEmpty) {
      throw const AppException(
        type: AppErrorType.parse,
        message: '播放地址为空',
      );
    }

    if (analyze.isWebType) {
      final resolved = _buildWebParseUrl(analyze.api, episodeUrl);
      _ensureValidUrl(resolved);
      return resolved;
    }

    if (analyze.isJsonType) {
      final response = await _apiClient.get<Map<String, dynamic>>(
        analyze.api,
        queryParameters: <String, dynamic>{'url': episodeUrl},
        options: Options(headers: analyze.headers),
      );
      final resolved = _extractJsonPlayUrl(response.data);
      _ensureValidUrl(resolved);
      return resolved;
    }

    throw AppException(
      type: AppErrorType.parse,
      message: '不支持的解析类型: ${analyze.type}',
    );
  }

  String _buildWebParseUrl(String baseUrl, String episodeUrl) {
    if (baseUrl.contains('{url}')) {
      return baseUrl.replaceFirst('{url}', Uri.encodeComponent(episodeUrl));
    }

    final encodedUrl = Uri.encodeComponent(episodeUrl);
    if (baseUrl.endsWith('=')) {
      return '$baseUrl$encodedUrl';
    }

    if (baseUrl.contains('?')) {
      final suffix = baseUrl.endsWith('?') || baseUrl.endsWith('&') ? '' : '&';
      return '$baseUrl${suffix}url=$encodedUrl';
    }

    return '$baseUrl$encodedUrl';
  }

  String _extractJsonPlayUrl(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      throw const AppException(
        type: AppErrorType.parse,
        message: '解析服务返回为空',
      );
    }

    final candidates = <Object?>[
      data['url'],
      data['playUrl'],
      data['play_url'],
      data['data'] is Map<String, dynamic>
          ? (data['data'] as Map<String, dynamic>)['url']
          : null,
      data['data'] is Map<String, dynamic>
          ? (data['data'] as Map<String, dynamic>)['playUrl']
          : null,
      data['data'] is Map<String, dynamic>
          ? (data['data'] as Map<String, dynamic>)['play_url']
          : null,
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    throw const AppException(
      type: AppErrorType.parse,
      message: '未找到可用播放地址',
    );
  }

  void _ensureValidUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const AppException(
        type: AppErrorType.parse,
        message: '解析结果不是有效链接',
      );
    }
  }
}
