import '../../../domain/repositories/site_repository.dart';
import '../../models/site.dart';
import '../../models/video.dart';
import 'api_client.dart';

class SiteApi {
  SiteApi({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Category>> getCategories(Site site) async {
    _ensureSupported(site);

    final response = await _apiClient.get<Map<String, dynamic>>(
      site.api,
      queryParameters: <String, dynamic>{'ac': 'list'},
    );
    final data = response.data ?? <String, dynamic>{};
    final classes = _asList(data['class']);

    return classes.asMap().entries.map((entry) {
      final item = _asMap(entry.value);
      return Category(
        id: _readString(item, <String>['type_id', 'typeId', 'id']),
        name: _readString(item, <String>['type_name', 'typeName', 'name']),
        isHome: entry.key == 0,
      );
    }).where((item) => item.id.isNotEmpty && item.name.isNotEmpty).toList();
  }

  Future<List<Video>> getVideosByCategory(
    Site site,
    String categoryId,
    int page,
  ) async {
    _ensureSupported(site);

    final response = await _apiClient.get<Map<String, dynamic>>(
      site.api,
      queryParameters: <String, dynamic>{
        'ac': 'list',
        't': categoryId,
        'pg': page,
      },
    );
    final data = response.data ?? <String, dynamic>{};
    return _parseVideoList(site, _asList(data['list']));
  }

  Future<List<Video>> searchVideos(Site site, String keyword) async {
    _ensureSupported(site);

    final normalized = keyword.trim();
    if (normalized.isEmpty) {
      return const <Video>[];
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      site.api,
      queryParameters: <String, dynamic>{'ac': 'list', 'wd': normalized},
    );
    final data = response.data ?? <String, dynamic>{};
    return _parseVideoList(site, _asList(data['list']));
  }

  Future<VideoDetail?> getVideoDetail(Site site, String videoId) async {
    _ensureSupported(site);

    final response = await _apiClient.get<Map<String, dynamic>>(
      site.api,
      queryParameters: <String, dynamic>{'ac': 'detail', 'ids': videoId},
    );
    final data = response.data ?? <String, dynamic>{};
    final videos = _parseVideoList(site, _asList(data['list']));
    if (videos.isEmpty) {
      return null;
    }

    final video = videos.first;
    return VideoDetail(
      video: video,
      episodes: video.episodes,
      playUrls: video.playUrls,
      detailUrl: video.detailUrl,
    );
  }

  void _ensureSupported(Site site) {
    if (site.type != 1) {
      throw UnsupportedError('当前仅支持 T1_JSON 站点接口');
    }
  }

  List<Video> _parseVideoList(Site site, List<dynamic> rows) {
    return rows.map((item) => _parseVideo(site, _asMap(item))).toList();
  }

  Video _parseVideo(Site site, Map<String, dynamic> item) {
    final playSource = _readString(
      item,
      <String>['vod_play_from', 'play_from'],
    );
    final playUrl = _readString(
      item,
      <String>['vod_play_url', 'play_url'],
    );
    final parsedPlayUrls = _parsePlayUrls(playUrl);

    return Video(
      id: _readString(item, <String>['vod_id', 'id']),
      title: _readString(item, <String>['vod_name', 'title', 'name']),
      cover: _readNullableString(item, <String>['vod_pic', 'cover', 'pic']),
      description: _readNullableString(
        item,
        <String>['vod_remarks', 'vod_blurb', 'remarks', 'description'],
      ),
      year: _readNullableString(item, <String>['vod_year', 'year']),
      area: _readNullableString(item, <String>['vod_area', 'area']),
      type: _readNullableString(
            item,
            <String>['type_name', 'vod_class', 'type'],
          ) ??
          playSource,
      actor: _readNullableString(item, <String>['vod_actor', 'actor']),
      director: _readNullableString(item, <String>['vod_director', 'director']),
      content: _readNullableString(item, <String>['vod_content', 'content']),
      siteId: site.id,
      detailUrl: _readNullableString(item, <String>['vod_play_url']) ?? site.api,
      episodes: parsedPlayUrls.map((item) => item['name'] ?? '').toList(),
      playUrls: parsedPlayUrls,
    );
  }

  List<Map<String, String>> _parsePlayUrls(String playUrl) {
    if (playUrl.isEmpty) {
      return const <Map<String, String>>[];
    }

    return playUrl
        .split('#')
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .map((segment) {
          final index = segment.indexOf(r'$');
          if (index == -1) {
            return <String, String>{'name': segment, 'url': segment};
          }

          return <String, String>{
            'name': segment.substring(0, index),
            'url': segment.substring(index + 1),
          };
        })
        .toList();
  }

  List<dynamic> _asList(Object? value) {
    if (value is List<dynamic>) {
      return value;
    }
    return const <dynamic>[];
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), item),
      );
    }
    return <String, dynamic>{};
  }

  String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }
      final stringValue = value.toString().trim();
      if (stringValue.isNotEmpty) {
        return stringValue;
      }
    }
    return '';
  }

  String? _readNullableString(Map<String, dynamic> json, List<String> keys) {
    final value = _readString(json, keys);
    return value.isEmpty ? null : value;
  }
}
