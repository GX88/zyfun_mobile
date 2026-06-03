import '../../data/models/iptv.dart';

/// 直播源数据仓库接口
abstract class IptvRepository {
  /// 获取所有直播源
  Future<List<Iptv>> getAllIptvs();
  
  /// 根据 ID 获取直播源
  Future<Iptv?> getIptvById(String id);
  
  /// 添加直播源
  Future<void> addIptv(Iptv iptv);
  
  /// 更新直播源
  Future<void> updateIptv(Iptv iptv);
  
  /// 删除直播源
  Future<void> deleteIptv(String id);
  
  /// 设置默认直播源
  Future<void> setDefaultIptv(String id);
  
  /// 获取默认直播源
  Future<String?> getDefaultIptv();
  
  /// 解析 M3U 文件
  Future<List<Channel>> parseM3u(String content);
  
  /// 获取频道列表
  Future<List<Channel>> getChannels(String iptvId);
}
