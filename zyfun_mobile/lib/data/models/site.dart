import 'package:freezed_annotation/freezed_annotation.dart';

part 'site.freezed.dart';
part 'site.g.dart';

/// 站点数据模型
@freezed
class Site with _$Site {
  const Site._();

  const factory Site({
    required String id,
    required String key,
    required String name,
    required String api,
    String? playUrl,
    @Default(0) int search,
    @Default('') String group,
    @Default(1) int type,
    @Default('') String ext,
    @Default('') String categories,
    @Default(true) bool isActive,
    required int createdAt,
    required int updatedAt,
  }) = _Site;

  factory Site.fromJson(Map<String, dynamic> json) => _$SiteFromJson(json);
  
  /// 空站点
  static const empty = Site(
    id: '',
    key: '',
    name: '',
    api: '',
    createdAt: 0,
    updatedAt: 0,
  );
  
  /// 验证站点是否有效
  bool get isValid => id.isNotEmpty && api.isNotEmpty;
  
  /// 是否为聚合搜索站点
  bool get isSearchSite => search == 1 || search == 2;
  
  /// 站点类型名称
  String get typeName {
    switch (type) {
      case 0: return 'T0_XML';
      case 1: return 'T1_JSON';
      case 6: return 'T4_DRPYS';
      case 7: return 'T3_DRPY';
      case 8: return 'T4_CATVOD';
      case 9: return 'T3_XBPQ';
      case 10: return 'T3_XYQ';
      case 11: return 'T3_APPYSV2';
      case 12: return 'T3_PY';
      case 13: return 'T3_ALIST';
      default: return '未知';
    }
  }
}
