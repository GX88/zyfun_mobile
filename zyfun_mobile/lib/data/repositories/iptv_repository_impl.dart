import '../../domain/repositories/iptv_repository.dart';
import '../datasources/local/dao/iptv_dao.dart';
import '../datasources/local/key_value_storage.dart';
import '../../core/constants/constants.dart';
import '../models/iptv.dart';

class IptvRepositoryImpl implements IptvRepository {
  IptvRepositoryImpl({
    required IptvDao iptvDao,
    required KeyValueStorage storage,
  })  : _iptvDao = iptvDao,
        _storage = storage;

  final IptvDao _iptvDao;
  final KeyValueStorage _storage;

  @override
  Future<void> addIptv(Iptv iptv) async {
    await _iptvDao.insert(iptv);
  }

  @override
  Future<void> deleteIptv(String id) async {
    await _iptvDao.deleteById(id);
  }

  @override
  Future<List<Iptv>> getAllIptvs() async {
    return _iptvDao.findAll();
  }

  @override
  Future<List<Channel>> getChannels(String iptvId) async {
    return const <Channel>[];
  }

  @override
  Future<String?> getDefaultIptv() async {
    return _storage.getString(StorageKeys.defaultIptv);
  }

  @override
  Future<Iptv?> getIptvById(String id) async {
    return _iptvDao.findById(id);
  }

  @override
  Future<List<Channel>> parseM3u(String content) async {
    return const <Channel>[];
  }

  @override
  Future<void> setDefaultIptv(String id) async {
    await _storage.setString(StorageKeys.defaultIptv, id);
  }

  @override
  Future<void> updateIptv(Iptv iptv) async {
    await _iptvDao.update(iptv);
  }
}
