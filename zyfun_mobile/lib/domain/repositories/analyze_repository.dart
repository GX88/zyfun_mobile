import '../../data/models/analyze.dart';

/// 解析接口数据仓库接口
abstract class AnalyzeRepository {
  /// 获取所有解析接口
  Future<List<Analyze>> getAllAnalyzes();
  
  /// 根据 ID 获取解析接口
  Future<Analyze?> getAnalyzeById(String id);
  
  /// 添加解析接口
  Future<void> addAnalyze(Analyze analyze);
  
  /// 更新解析接口
  Future<void> updateAnalyze(Analyze analyze);
  
  /// 删除解析接口
  Future<void> deleteAnalyze(String id);
  
  /// 设置默认解析接口
  Future<void> setDefaultAnalyze(String id);
  
  /// 获取默认解析接口
  Future<String?> getDefaultAnalyze();
}
