import '../../core/constants/constants.dart';
import '../../domain/repositories/analyze_repository.dart';
import '../datasources/local/dao/analyze_dao.dart';
import '../datasources/local/key_value_storage.dart';
import '../models/analyze.dart';

class AnalyzeRepositoryImpl implements AnalyzeRepository {
  AnalyzeRepositoryImpl({
    required AnalyzeDao analyzeDao,
    required KeyValueStorage storage,
  })  : _analyzeDao = analyzeDao,
        _storage = storage;

  final AnalyzeDao _analyzeDao;
  final KeyValueStorage _storage;

  @override
  Future<void> addAnalyze(Analyze analyze) async {
    await _analyzeDao.insert(analyze);
  }

  @override
  Future<void> deleteAnalyze(String id) async {
    await _analyzeDao.deleteById(id);
  }

  @override
  Future<List<Analyze>> getAllAnalyzes() async {
    return _analyzeDao.findAll();
  }

  @override
  Future<Analyze?> getAnalyzeById(String id) async {
    return _analyzeDao.findById(id);
  }

  @override
  Future<String?> getDefaultAnalyze() async {
    return _storage.getString(StorageKeys.defaultAnalyze);
  }

  @override
  Future<void> setDefaultAnalyze(String id) async {
    await _storage.setString(StorageKeys.defaultAnalyze, id);
  }

  @override
  Future<void> updateAnalyze(Analyze analyze) async {
    await _analyzeDao.update(analyze);
  }
}
