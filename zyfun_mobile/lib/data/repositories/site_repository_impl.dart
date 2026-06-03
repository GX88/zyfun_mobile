import '../../core/constants/constants.dart';
import '../../domain/repositories/analyze_repository.dart';
import '../../domain/repositories/site_repository.dart';
import '../datasources/local/dao/site_dao.dart';
import '../datasources/local/key_value_storage.dart';
import '../datasources/remote/parse_api.dart';
import '../datasources/remote/site_api.dart';
import '../models/analyze.dart';
import '../models/site.dart';
import '../models/video.dart';

class SiteRepositoryImpl implements SiteRepository {
  SiteRepositoryImpl({
    required SiteDao siteDao,
    required KeyValueStorage storage,
    SiteApi? siteApi,
    AnalyzeRepository? analyzeRepository,
    ParseApi? parseApi,
  })  : _siteDao = siteDao,
        _storage = storage,
        _siteApi = siteApi,
        _analyzeRepository = analyzeRepository,
        _parseApi = parseApi;

  final SiteDao _siteDao;
  final KeyValueStorage _storage;
  final SiteApi? _siteApi;
  final AnalyzeRepository? _analyzeRepository;
  final ParseApi? _parseApi;

  @override
  Future<void> addSite(Site site) async {
    await _siteDao.insert(site);
  }

  @override
  Future<void> deleteSite(String id) async {
    await _siteDao.deleteById(id);
  }

  @override
  Future<List<Site>> getAllSites() async {
    return _siteDao.findAll();
  }

  @override
  Future<List<Category>> getCategories(String siteId) async {
    final site = await getSiteById(siteId);
    if (site == null) {
      return const <Category>[];
    }

    if (_siteApi != null) {
      try {
        final categories = await _siteApi.getCategories(site);
        if (categories.isNotEmpty) {
          return categories;
        }
      } catch (_) {
        // Keep demo fallback for unfinished API adapters.
      }
    }

    final names = site.categories
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (names.isEmpty) {
      return const <Category>[];
    }

    return names
        .asMap()
        .entries
        .map(
          (entry) => Category(
            id: 'category-${entry.key}',
            name: entry.value,
            isHome: entry.key == 0,
          ),
        )
        .toList();
  }

  @override
  Future<String?> getDefaultSite() async {
    return _storage.getString(StorageKeys.defaultSite);
  }

  @override
  Future<VideoDetail> getVideoDetail(String siteId, String videoId) async {
    final site = await getSiteById(siteId);
    if (site == null) {
      return const VideoDetail(
        video: Video.empty,
        episodes: <String>[],
        playUrls: <Map<String, String>>[],
      );
    }

    if (_siteApi != null) {
      try {
        final detail = await _siteApi.getVideoDetail(site, videoId);
        if (detail != null) {
          return detail;
        }
      } catch (_) {
        // Keep demo fallback for unfinished API adapters.
      }
    }

    final videos = await searchVideos(siteId, videoId);
    final matched = videos.cast<Video?>().firstWhere(
          (video) => video?.id == videoId,
          orElse: () => null,
        );

    if (matched == null) {
      final fallbackVideo = _buildDemoVideo(
        site: site,
        seed: 'detail-$videoId',
        title: '视频详情',
        description: '根据视频 ID 生成的演示详情数据。',
        categoryName: '详情',
      );

      return VideoDetail(
        video: fallbackVideo.copyWith(id: videoId),
        episodes: fallbackVideo.episodes,
        playUrls: fallbackVideo.playUrls,
        detailUrl: fallbackVideo.detailUrl,
      );
    }

    return VideoDetail(
      video: matched,
      episodes: matched.episodes,
      playUrls: matched.playUrls,
      detailUrl: matched.detailUrl,
    );
  }

  @override
  Future<String> getPlayUrl(String siteId, String episodeUrl) async {
    if (_analyzeRepository == null || _parseApi == null) {
      return episodeUrl;
    }

    final analyzes = await _analyzeRepository.getAllAnalyzes();
    final activeAnalyzes = analyzes.where((item) => item.isActive).toList();
    if (activeAnalyzes.isEmpty) {
      return episodeUrl;
    }

    final defaultAnalyzeId = await _analyzeRepository.getDefaultAnalyze();
    final analyze = _pickAnalyze(
      analyzes: activeAnalyzes,
      defaultAnalyzeId: defaultAnalyzeId,
      episodeUrl: episodeUrl,
    );
    if (analyze == null) {
      return episodeUrl;
    }

    return _parseApi.resolvePlayUrl(
      analyze: analyze,
      episodeUrl: episodeUrl,
    );
  }

  Analyze? _pickAnalyze({
    required List<Analyze> analyzes,
    required String? defaultAnalyzeId,
    required String episodeUrl,
  }) {
    final defaultAnalyze = analyzes.cast<Analyze?>().firstWhere(
          (item) => item?.id == defaultAnalyzeId,
          orElse: () => null,
        );
    if (defaultAnalyze != null && _matchesFlag(defaultAnalyze, episodeUrl)) {
      return defaultAnalyze;
    }

    return analyzes.cast<Analyze?>().firstWhere(
      (item) => item != null && _matchesFlag(item, episodeUrl),
      orElse: () => analyzes.first,
    );
  }

  bool _matchesFlag(Analyze analyze, String episodeUrl) {
    if (analyze.flag.isEmpty) {
      return true;
    }

    final normalizedUrl = episodeUrl.toLowerCase();
    return analyze.flag.any(
      (flag) => normalizedUrl.contains(flag.toLowerCase()),
    );
  }

  @override
  Future<Site?> getSiteById(String id) async {
    return _siteDao.findById(id);
  }

  @override
  Future<List<Video>> getVideosByCategory(String siteId, String categoryId, int page) async {
    final site = await getSiteById(siteId);
    if (site != null && _siteApi != null) {
      try {
        final remoteVideos = await _siteApi.getVideosByCategory(site, categoryId, page);
        if (remoteVideos.isNotEmpty) {
          return remoteVideos;
        }
      } catch (_) {
        // Keep demo fallback for unfinished API adapters.
      }
    }

    final categories = await getCategories(siteId);
    final category = categories.cast<Category?>().firstWhere(
          (item) => item?.id == categoryId,
          orElse: () => categories.isNotEmpty ? categories.first : null,
        );

    if (site == null || category == null) {
      return const <Video>[];
    }

    return List<Video>.generate(
      12,
      (index) => _buildDemoVideo(
        site: site,
        seed: '${category.id}-$page-$index',
        title: '${category.name} 推荐 ${index + 1 + ((page - 1) * 12)}',
        description: '来自 ${site.name} 的 ${category.name} 演示数据。',
        categoryName: category.name,
      ),
    );
  }

  @override
  Future<List<Video>> searchVideos(String siteId, String keyword) async {
    final site = await getSiteById(siteId);
    if (site == null || keyword.trim().isEmpty) {
      return const <Video>[];
    }

    if (_siteApi != null) {
      try {
        final remoteVideos = await _siteApi.searchVideos(site, keyword);
        if (remoteVideos.isNotEmpty) {
          return remoteVideos;
        }
      } catch (_) {
        // Keep demo fallback for unfinished API adapters.
      }
    }

    final normalized = keyword.trim();
    return List<Video>.generate(
      8,
      (index) => _buildDemoVideo(
        site: site,
        seed: 'search-$normalized-$index',
        title: '$normalized 结果 ${index + 1}',
        description: '匹配关键字“$normalized”的演示搜索结果。',
        categoryName: '搜索',
      ),
    );
  }

  @override
  Future<void> setDefaultSite(String id) async {
    await _storage.setString(StorageKeys.defaultSite, id);
  }

  @override
  Future<void> updateSite(Site site) async {
    await _siteDao.update(site);
  }

  Video _buildDemoVideo({
    required Site site,
    required String seed,
    required String title,
    required String description,
    required String categoryName,
  }) {
    return Video(
      id: '${site.id}-$seed',
      title: title,
      siteId: site.id,
      cover: 'https://placehold.co/480x720/png?text=${Uri.encodeComponent(title)}',
      description: description,
      type: categoryName,
      year: '2026',
      area: '移动端',
      actor: '演示数据',
      director: site.name,
      content: '$description 当前内容用于页面联调，后续替换为真实站点接口。',
      detailUrl: 'https://example.com/detail/$seed',
      episodes: const <String>['第1集', '第2集', '第3集'],
      playUrls: const <Map<String, String>>[
        <String, String>{'name': '第1集', 'url': 'https://example.com/play/1'},
        <String, String>{'name': '第2集', 'url': 'https://example.com/play/2'},
        <String, String>{'name': '第3集', 'url': 'https://example.com/play/3'},
      ],
    );
  }
}
