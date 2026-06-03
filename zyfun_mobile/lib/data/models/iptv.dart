import 'package:freezed_annotation/freezed_annotation.dart';

part 'iptv.freezed.dart';
part 'iptv.g.dart';

/// 直播源数据模型
@freezed
class Iptv with _$Iptv {
  const Iptv._();

  const factory Iptv({
    required String id,
    required String key,
    required String name,
    required String api,
    @Default(1) int type, // 1=远程，2=本地，3=文本
    String? epg,
    String? logo,
    Map<String, dynamic>? headers,
    @Default(true) bool isActive,
    required int createdAt,
    required int updatedAt,
  }) = _Iptv;

  factory Iptv.fromJson(Map<String, dynamic> json) => _$IptvFromJson(json);
  
  /// 空直播源
  static const empty = Iptv(
    id: '',
    key: '',
    name: '',
    api: '',
    createdAt: 0,
    updatedAt: 0,
  );
  
  /// 验证直播源是否有效
  bool get isValid => id.isNotEmpty && api.isNotEmpty;
  
  /// 是否为远程源
  bool get isRemote => type == 1;
  
  /// 是否为本地源
  bool get isLocal => type == 2;
  
  /// 是否为文本源
  bool get isText => type == 3;
}

/// 频道数据模型
@freezed
class Channel with _$Channel {
  const Channel._();

  const factory Channel({
    required String id,
    required String name,
    required String url,
    String? logo,
    String? group,
    Map<String, String>? headers,
  }) = _Channel;

  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);
}
