import 'package:freezed_annotation/freezed_annotation.dart';

part 'video.freezed.dart';
part 'video.g.dart';

/// 视频数据模型
@freezed
class Video with _$Video {
  const Video._();

  @JsonSerializable(explicitToJson: true)
  const factory Video({
    required String id,
    required String title,
    String? cover,
    String? description,
    String? year,
    String? area,
    String? type,
    String? actor,
    String? director,
    String? content,
    required String siteId,
    String? detailUrl,
    @Default([]) List<String> episodes,
    @Default([]) List<Map<String, String>> playUrls,
  }) = _Video;

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
  
  /// 空视频
  static const empty = Video(
    id: '',
    title: '',
    siteId: '',
    episodes: [],
    playUrls: [],
  );
  
  /// 验证视频是否有效
  bool get isValid => id.isNotEmpty && title.isNotEmpty;
  
  /// 是否有封面图
  bool get hasCover => cover != null && cover!.isNotEmpty;
  
  /// 是否有播放地址
  bool get hasEpisodes => episodes.isNotEmpty || playUrls.isNotEmpty;
}

/// 视频详情模型
@freezed
class VideoDetail with _$VideoDetail {
  const VideoDetail._();

  @JsonSerializable(explicitToJson: true)
  const factory VideoDetail({
    required Video video,
    required List<String> episodes,
    required List<Map<String, String>> playUrls,
    String? detailUrl,
  }) = _VideoDetail;

  factory VideoDetail.fromJson(Map<String, dynamic> json) => _$VideoDetailFromJson(json);
}
