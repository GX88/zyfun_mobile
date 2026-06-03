import '../../domain/repositories/favorite_repository.dart';
import '../datasources/local/dao/favorite_dao.dart';
import '../models/favorite.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  FavoriteRepositoryImpl({required FavoriteDao favoriteDao}) : _favoriteDao = favoriteDao;

  final FavoriteDao _favoriteDao;

  @override
  Future<void> addFavorite(Favorite favorite) async {
    await _favoriteDao.insertOrReplace(favorite);
  }

  @override
  Future<void> deleteFavorite(String id) async {
    await _favoriteDao.deleteById(id);
  }

  @override
  Future<List<Favorite>> getAllFavorites() async {
    return _favoriteDao.findAll();
  }

  @override
  Future<Favorite?> getFavoriteById(String id) async {
    return _favoriteDao.findById(id);
  }

  @override
  Future<Favorite?> getFavoriteByVideo(String siteId, String videoId) async {
    return _favoriteDao.findByVideo(siteId, videoId);
  }
}
