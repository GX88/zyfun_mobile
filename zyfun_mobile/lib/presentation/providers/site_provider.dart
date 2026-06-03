import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/site.dart';
import '../../data/models/video.dart';
import '../../domain/repositories/site_repository.dart';
import 'app_providers.dart';

class SiteNotifier extends StateNotifier<SiteListState> {
  SiteNotifier(this._repository) : super(const SiteListState());

  final SiteRepository _repository;

  Future<void> loadSites() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final sites = await _repository.getAllSites();
      if (sites.isEmpty) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final demoSite = Site(
          id: 'demo-site',
          key: 'demo-site',
          name: '演示站点',
          api: 'https://example.com/api.php/provide/vod/',
          group: '默认',
          categories: '电影,电视剧,综艺,动漫',
          createdAt: now,
          updatedAt: now,
        );
        await _repository.addSite(demoSite);
      }

      final refreshedSites = await _repository.getAllSites();
      final defaultId = await _repository.getDefaultSite();
      final selected = refreshedSites.cast<Site?>().firstWhere(
            (site) => site?.id == defaultId,
            orElse: () => refreshedSites.isNotEmpty ? refreshedSites.first : null,
          );

      state = state.copyWith(
        isLoading: false,
        sites: refreshedSites,
        selectedSite: selected,
        clearError: true,
      );

      if (selected != null) {
        await loadCategories(selected.id);
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> selectSite(Site site) async {
    await _repository.setDefaultSite(site.id);
    state = state.copyWith(
      selectedSite: site,
      categories: const <Category>[],
      videos: const <Video>[],
      searchResults: const <Video>[],
      searchKeyword: '',
      clearSelectedCategory: true,
      clearError: true,
    );
    await loadCategories(site.id);
  }

  Future<void> loadCategories(String siteId) async {
    state = state.copyWith(isCategoryLoading: true, clearError: true);
    try {
      final categories = await _repository.getCategories(siteId);
      final selectedCategory = categories.isNotEmpty ? categories.first : null;
      state = state.copyWith(
        categories: categories,
        selectedCategory: selectedCategory,
        isCategoryLoading: false,
      );

      if (selectedCategory != null) {
        await loadVideosByCategory(selectedCategory.id);
      } else {
        state = state.copyWith(videos: const <Video>[]);
      }
    } catch (error) {
      state = state.copyWith(
        isCategoryLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadVideosByCategory(String categoryId, {int page = 1}) async {
    final selectedSite = state.selectedSite;
    if (selectedSite == null) {
      return;
    }

    final selectedCategory = state.categories.cast<Category?>().firstWhere(
          (item) => item?.id == categoryId,
          orElse: () => state.categories.isNotEmpty ? state.categories.first : null,
        );
    if (selectedCategory == null) {
      return;
    }

    state = state.copyWith(
      isCategoryLoading: true,
      selectedCategory: selectedCategory,
      clearError: true,
    );

    try {
      final videos = await _repository.getVideosByCategory(
        selectedSite.id,
        categoryId,
        page,
      );
      state = state.copyWith(
        videos: videos,
        isCategoryLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isCategoryLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> search(String keyword) async {
    final selectedSite = state.selectedSite;
    final normalized = keyword.trim();
    if (selectedSite == null) {
      return;
    }

    state = state.copyWith(
      isSearching: true,
      searchKeyword: normalized,
      clearError: true,
    );

    try {
      final results = await _repository.searchVideos(selectedSite.id, normalized);
      state = state.copyWith(
        searchResults: results,
        isSearching: false,
      );
    } catch (error) {
      state = state.copyWith(
        isSearching: false,
        errorMessage: error.toString(),
      );
    }
  }

  void clearSearch() {
    state = state.copyWith(
      searchKeyword: '',
      searchResults: const <Video>[],
      isSearching: false,
      clearError: true,
    );
  }
}

final siteNotifierProvider =
    StateNotifierProvider<SiteNotifier, SiteListState>((ref) {
  return SiteNotifier(ref.watch(siteRepositoryProvider));
});
