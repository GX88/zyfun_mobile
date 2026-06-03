import 'package:freezed_annotation/freezed_annotation.dart';

part 'setting.freezed.dart';
part 'setting.g.dart';

/// 设置数据模型
@freezed
class Setting with _$Setting {
  @JsonSerializable(explicitToJson: true)
  const factory Setting({
    @Default('1.0.0') String version,
    @Default('system') String theme, // system, light, dark
    @Default('zh_CN') String lang,
    @Default(1.0) double zoom,
    ProxyConfig? proxy,
    @Default('kylive') String hot,
    @Default('douban') String association,
    SiteConfig? site,
    LiveConfig? live,
    @Default('') String defaultSite,
    @Default('') String defaultIptv,
    @Default('') String defaultAnalyze,
    DanmakuConfig? barrage,
    PlayerConfig? player,
    SnifferConfig? sniffer,
    @Default(false) bool autoStart,
    @Default(true) bool hardwareAcceleration,
    @Default('') String ua,
    @Default('') String dns,
    CloudConfig? cloud,
    AiConfig? aigc,
    @Default(5000) int timeout,
    @Default(false) bool debug,
  }) = _Setting;

  factory Setting.fromJson(Map<String, dynamic> json) => _$SettingFromJson(json);
}

@freezed
class ProxyConfig with _$ProxyConfig {
  @JsonSerializable(explicitToJson: true)
  const factory ProxyConfig({
    @Default('system') String type,
    @Default('') String url,
    @Default('') String bypass,
  }) = _ProxyConfig;

  factory ProxyConfig.fromJson(Map<String, dynamic> json) => _$ProxyConfigFromJson(json);
}

@freezed
class SiteConfig with _$SiteConfig {
  @JsonSerializable(explicitToJson: true)
  const factory SiteConfig({
    @Default('site') String searchMode,
    @Default(false) bool filterMode,
  }) = _SiteConfig;

  factory SiteConfig.fromJson(Map<String, dynamic> json) => _$SiteConfigFromJson(json);
}

@freezed
class LiveConfig with _$LiveConfig {
  @JsonSerializable(explicitToJson: true)
  const factory LiveConfig({
    @Default(true) bool ipMark,
    @Default(false) bool thumbnail,
    @Default(false) bool delay,
    @Default('') String epg,
    @Default('') String logo,
  }) = _LiveConfig;

  factory LiveConfig.fromJson(Map<String, dynamic> json) => _$LiveConfigFromJson(json);
}

@freezed
class DanmakuConfig with _$DanmakuConfig {
  @JsonSerializable(explicitToJson: true)
  const factory DanmakuConfig({
    @Default('') String url,
    @Default('name') String id,
    @Default('danmuku') String key,
    @Default(['qq', 'qiyi', 'youku', 'mgtv']) List<String> support,
    @Default(0) int time,
    @Default(1) int type,
    @Default(2) int color,
    @Default(4) int text,
  }) = _DanmakuConfig;

  factory DanmakuConfig.fromJson(Map<String, dynamic> json) => _$DanmakuConfigFromJson(json);
}

@freezed
class PlayerConfig with _$PlayerConfig {
  @JsonSerializable(explicitToJson: true)
  const factory PlayerConfig({
    @Default('xgplayer') String type,
    @Default('') String external,
  }) = _PlayerConfig;

  factory PlayerConfig.fromJson(Map<String, dynamic> json) => _$PlayerConfigFromJson(json);
}

@freezed
class SnifferConfig with _$SnifferConfig {
  @JsonSerializable(explicitToJson: true)
  const factory SnifferConfig({
    @Default('cdp') String type,
    @Default('') String url,
  }) = _SnifferConfig;

  factory SnifferConfig.fromJson(Map<String, dynamic> json) => _$SnifferConfigFromJson(json);
}

@freezed
class CloudConfig with _$CloudConfig {
  @JsonSerializable(explicitToJson: true)
  const factory CloudConfig({
    @Default(false) bool sync,
    @Default('webdav') String type,
    CloudData? data,
  }) = _CloudConfig;

  factory CloudConfig.fromJson(Map<String, dynamic> json) => _$CloudConfigFromJson(json);
}

@freezed
class CloudData with _$CloudData {
  @JsonSerializable(explicitToJson: true)
  const factory CloudData({
    @Default('') String url,
    @Default('') String user,
    @Default('') String password,
  }) = _CloudData;

  factory CloudData.fromJson(Map<String, dynamic> json) => _$CloudDataFromJson(json);
}

@freezed
class AiConfig with _$AiConfig {
  @JsonSerializable(explicitToJson: true)
  const factory AiConfig({
    @Default('openai') String type,
    @Default('') String server,
    @Default('') String key,
    @Default('gpt-3.5-turbo') String model,
  }) = _AiConfig;

  factory AiConfig.fromJson(Map<String, dynamic> json) => _$AiConfigFromJson(json);
}
