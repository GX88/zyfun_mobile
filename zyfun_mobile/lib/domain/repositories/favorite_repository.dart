import '../../data/models/favorite.dart';

abstract class FavoriteRepository {
  Future<List<Favorite>> getAllFavorites();

  Future<Favorite?> getFavoriteById(String id);

  Future<Favorite?> getFavoriteByVideo(String siteId, String videoId);

  Future<void> addFavorite(Favorite favorite);

  Future<void> deleteFavorite(String id);
}
