export 'colors.dart';
export 'icons.dart';
export 'radius.dart';
export 'shadows.dart';
export 'spacing.dart';
export 'typography.dart';

/// 常量定义
/// API 接口相关常量
class ApiConstants {
  /// 默认 API 基础地址
  static const String defaultBaseUrl = '';

  /// 默认超时时间 (毫秒)
  static const int defaultTimeout = 5000;

  /// 默认 User-Agent
  static const String defaultUserAgent = 'zyfun-mobile/1.0.0';

  /// 默认内容类型
  static const String defaultContentType = 'application/json; charset=utf-8';

  /// 默认接收类型
  static const String defaultAccept = 'application/json, text/plain, */*';
  
  /// 最大重试次数
  static const int maxRetries = 3;
  
  /// 重试延迟 (毫秒)
  static const int retryDelay = 1000;
}

/// 数据库相关常量
class DatabaseConstants {
  /// 数据库名称
  static const String dbName = 'zyfun.db';
  
  /// 数据库版本
  static const int dbVersion = 1;
}

/// 存储键名常量
class StorageKeys {
  /// 设置
  static const String setting = 'setting';
  
  /// 默认站点
  static const String defaultSite = 'default_site';
  
  /// 默认直播源
  static const String defaultIptv = 'default_iptv';
  
  /// 默认解析
  static const String defaultAnalyze = 'default_analyze';
  
  /// 主题
  static const String theme = 'theme';
  
  /// 语言
  static const String language = 'language';

  /// 是否已接受免责声明
  static const String disclaimerAccepted = 'disclaimer_accepted';

  /// 是否已完成首次启动初始化
  static const String appInitialized = 'app_initialized';
}

/// 路由相关常量
class RouteConstants {
  /// 启动页
  static const String splash = '/splash';

  /// 免责声明页
  static const String disclaimer = '/disclaimer';

  /// 首页
  static const String home = '/';
  
  /// 影视
  static const String film = '/film';
  
  /// 直播
  static const String live = '/live';
  
  /// 播放器
  static const String player = '/player';
  
  /// 详情
  static const String detail = '/detail';
  
  /// 搜索
  static const String search = '/search';
  
  /// 历史
  static const String history = '/history';
  
  /// 收藏
  static const String favorite = '/favorite';
  
  /// 设置
  static const String setting = '/setting';
  
  /// 解析
  static const String parse = '/parse';

  /// 嗅探
  static const String sniffer = '/sniffer';
}
