import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite.freezed.dart';
part 'favorite.g.dart';

/// 收藏数据模型
@freezed
class Favorite with _$Favorite {
  const Favorite._();

  const factory Favorite({
    required String id,
    required String siteId,
    required String videoId,
    required String title,
    String? cover,
    required int createdAt,
  }) = _Favorite;

  factory Favorite.fromJson(Map<String, dynamic> json) => _$FavoriteFromJson(json);
  
  /// 空收藏
  static const empty = Favorite(
    id: '',
    siteId: '',
    videoId: '',
    title: '',
    createdAt: 0,
  );
  
  /// 验证收藏是否有效
  bool get isValid => id.isNotEmpty && videoId.isNotEmpty;
  
  /// 是否有封面图
  bool get hasCover => cover != null && cover!.isNotEmpty;
}
