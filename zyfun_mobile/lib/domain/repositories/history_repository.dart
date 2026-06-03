import '../../data/models/history.dart';

/// 历史记录数据仓库接口
abstract class HistoryRepository {
  /// 获取所有历史记录
  Future<List<History>> getAllHistories();
  
  /// 根据 ID 获取历史记录
  Future<History?> getHistoryById(String id);
  
  /// 添加历史记录
  Future<void> addHistory(History history);
  
  /// 更新历史记录
  Future<void> updateHistory(History history);
  
  /// 删除历史记录
  Future<void> deleteHistory(String id);
  
  /// 清空所有历史记录
  Future<void> clearAllHistories();
  
  /// 获取最新的 N 条记录
  Future<List<History>> getRecentHistories({int limit = 50});
}
