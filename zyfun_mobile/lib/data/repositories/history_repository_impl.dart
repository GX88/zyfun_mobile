import '../../domain/repositories/history_repository.dart';
import '../datasources/local/dao/history_dao.dart';
import '../models/history.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl({required HistoryDao historyDao}) : _historyDao = historyDao;

  final HistoryDao _historyDao;

  @override
  Future<void> addHistory(History history) async {
    await _historyDao.insertOrReplace(history);
  }

  @override
  Future<void> clearAllHistories() async {
    await _historyDao.clear();
  }

  @override
  Future<void> deleteHistory(String id) async {
    await _historyDao.deleteById(id);
  }

  @override
  Future<List<History>> getAllHistories() async {
    return _historyDao.findAll();
  }

  @override
  Future<History?> getHistoryById(String id) async {
    return _historyDao.findById(id);
  }

  @override
  Future<List<History>> getRecentHistories({int limit = 50}) async {
    return _historyDao.findRecent(limit: limit);
  }

  @override
  Future<void> updateHistory(History history) async {
    await _historyDao.update(history);
  }
}
