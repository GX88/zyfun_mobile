import '../../data/models/site.dart';
import '../../data/models/video.dart';

/// 站点数据仓库接口
abstract class SiteRepository {
  /// 获取所有站点
  Future<List<Site>> getAllSites();
  
  /// 根据 ID 获取站点
  Future<Site?> getSiteById(String id);
  
  /// 添加站点
  Future<void> addSite(Site site);
  
  /// 更新站点
  Future<void> updateSite(Site site);
  
  /// 删除站点
  Future<void> deleteSite(String id);
  
  /// 设置默认站点
  Future<void> setDefaultSite(String id);
  
  /// 获取默认站点
  Future<String?> getDefaultSite();
  
  /// 搜索视频
  Future<List<Video>> searchVideos(String siteId, String keyword);
  
  /// 获取分类列表
  Future<List<Category>> getCategories(String siteId);
  
  /// 获取分类下的视频列表
  Future<List<Video>> getVideosByCategory(
    String siteId,
    String categoryId,
    int page,
  );
  
  /// 获取视频详情
  Future<VideoDetail> getVideoDetail(String siteId, String videoId);
  
  /// 获取播放地址
  Future<String> getPlayUrl(String siteId, String episodeUrl);
}

/// 分类数据模型
class Category {
  final String id;
  final String name;
  final bool isHome;
  
  const Category({
    required this.id,
    required this.name,
    this.isHome = false,
  });
}

class SiteListState {
  const SiteListState({
    this.sites = const <Site>[],
    this.categories = const <Category>[],
    this.videos = const <Video>[],
    this.searchResults = const <Video>[],
    this.selectedSite,
    this.selectedCategory,
    this.isLoading = false,
    this.isCategoryLoading = false,
    this.isSearching = false,
    this.searchKeyword = '',
    this.errorMessage,
  });

  final List<Site> sites;
  final List<Category> categories;
  final List<Video> videos;
  final List<Video> searchResults;
  final Site? selectedSite;
  final Category? selectedCategory;
  final bool isLoading;
  final bool isCategoryLoading;
  final bool isSearching;
  final String searchKeyword;
  final String? errorMessage;

  SiteListState copyWith({
    List<Site>? sites,
    List<Category>? categories,
    List<Video>? videos,
    List<Video>? searchResults,
    Site? selectedSite,
    Category? selectedCategory,
    bool? isLoading,
    bool? isCategoryLoading,
    bool? isSearching,
    String? searchKeyword,
    String? errorMessage,
    bool clearSelectedCategory = false,
    bool clearError = false,
  }) {
    return SiteListState(
      sites: sites ?? this.sites,
      categories: categories ?? this.categories,
      videos: videos ?? this.videos,
      searchResults: searchResults ?? this.searchResults,
      selectedSite: selectedSite ?? this.selectedSite,
      selectedCategory: clearSelectedCategory
          ? null
          : selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      isCategoryLoading: isCategoryLoading ?? this.isCategoryLoading,
      isSearching: isSearching ?? this.isSearching,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
