/*
 * @Author: 新西兰的肉夹馍
 * @Date: 2025-09-25 21:37:39
 * @LastEditTime: 2025-09-25 23:51:01
 * @FilePath: /mu-music/lib/common/models/playlist.dart
 * @Description:  歌单
 * 在这个虚拟的空间里，我试图捕捉真实的自我，与世界分享。
 */
import 'package:json_annotation/json_annotation.dart';

part 'playlist.g.dart';

@JsonSerializable()
class Playlist {
  Playlist();

  late num code;
  String? relatedVideos;
  late Map<String, dynamic> playlist;

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);
  Map<String, dynamic> toJson() => _$PlaylistToJson(this);
}
