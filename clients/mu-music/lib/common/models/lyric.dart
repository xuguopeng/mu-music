/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-27 13:57:31
 * @LastEditTime: 2025-09-27 17:35:05
 * @FilePath: /mu-music/lib/common/models/lyric.dart
 * @Description: 歌词
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:json_annotation/json_annotation.dart';

part 'lyric.g.dart';

@JsonSerializable()
class Lyric {
  Lyric();

  bool? sgc;
  bool? sfy;
  bool? qfy;
  Map<String, dynamic>? transUser;
  Map<String, dynamic>? lyricUser;
  Map<String, dynamic>? lrc;
  Map<String, dynamic>? klyric;
  Map<String, dynamic>? tlyric;
  Map<String, dynamic>? romalrc;
  num? code;

  factory Lyric.fromJson(Map<String, dynamic> json) => _$LyricFromJson(json);
  Map<String, dynamic> toJson() => _$LyricToJson(this);
}

// 歌词数据模型
class LyricData {
  final int time; // 歌词对应的时间（毫秒）
  final String text; // 歌词内容

  LyricData({required this.time, required this.text});
}
