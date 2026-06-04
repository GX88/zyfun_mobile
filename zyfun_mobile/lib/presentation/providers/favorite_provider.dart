import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import 'app_providers.dart';

class FavoriteListNotifier extends AsyncNotifier<List<Favorite>> {
  FavoriteRepository get _repository => ref.read(favoriteRepositoryProvider);

  @override
  Future<List<Favorite>> build() {
    return _repository.getAllFavorites();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getAllFavorites);
  }

  Future<void> deleteFavorite(String id) async {
    await _repository.deleteFavorite(id);
    await refresh();
  }
}

final favoriteListProvider =
    AsyncNotifierProvider<FavoriteListNotifier, List<Favorite>>(
  FavoriteListNotifier.new,
);
