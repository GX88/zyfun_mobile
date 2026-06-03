import 'package:freezed_annotation/freezed_annotation.dart';

part 'history.freezed.dart';
part 'history.g.dart';

/// 播放历史数据模型
@freezed
class History with _$History {
  const History._();

  const factory History({
    required String id,
    required String siteId,
    required String videoId,
    required String title,
    String? cover,
    String? description,
    required String episodeUrl,
    String? episodeName,
    @Default(0) int progress,
    @Default(0) int duration,
    required int createdAt,
    required int updatedAt,
  }) = _History;

  factory History.fromJson(Map<String, dynamic> json) => _$HistoryFromJson(json);
  
  /// 空历史
  static const empty = History(
    id: '',
    siteId: '',
    videoId: '',
    title: '',
    episodeUrl: '',
    createdAt: 0,
    updatedAt: 0,
  );
  
  /// 验证历史是否有效
  bool get isValid => id.isNotEmpty && videoId.isNotEmpty;
  
  /// 是否有进度
  bool get hasProgress => progress > 0;
  
  /// 播放进度百分比
  double get progressPercent => duration > 0 ? progress / duration : 0.0;
  
  /// 格式化进度时间
  String get progressText {
    return _formatDuration(progress);
  }
  
  /// 格式化总时长
  String get durationText {
    return _formatDuration(duration);
  }
  
  String _formatDuration(int ms) {
    final seconds = ms ~/ 1000;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }
  
  /// 是否超过 30 天
  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch;
    final thirtyDaysAgo = now - (30 * 24 * 60 * 60 * 1000);
    return updatedAt < thirtyDaysAgo;
  }
}
