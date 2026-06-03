import 'package:freezed_annotation/freezed_annotation.dart';

part 'analyze.freezed.dart';
part 'analyze.g.dart';

/// 解析接口数据模型
@freezed
class Analyze with _$Analyze {
  const Analyze._();

  const factory Analyze({
    required String id,
    required String key,
    required String name,
    required String api,
    @Default(1) int type, // 1=web, 2=json
    @Default([]) List<String> flag,
    Map<String, dynamic>? headers,
    @Default('') String script,
    @Default(true) bool isActive,
    required int createdAt,
    required int updatedAt,
  }) = _Analyze;

  factory Analyze.fromJson(Map<String, dynamic> json) => _$AnalyzeFromJson(json);
  
  /// 空解析
  static const empty = Analyze(
    id: '',
    key: '',
    name: '',
    api: '',
    createdAt: 0,
    updatedAt: 0,
  );
  
  /// 验证解析是否有效
  bool get isValid => id.isNotEmpty && api.isNotEmpty;
  
  /// 是否为 Web 型解析
  bool get isWebType => type == 1;
  
  /// 是否为 JSON 型解析
  bool get isJsonType => type == 2;
}
