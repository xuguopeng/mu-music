import 'package:json_annotation/json_annotation.dart';

part 'topplaylist.g.dart';

@JsonSerializable()
class Topplaylist {
  Topplaylist();

  late List playlists;
  late num code;
  late bool more;
  late num lasttime;
  late num total;
  
  factory Topplaylist.fromJson(Map<String,dynamic> json) => _$TopplaylistFromJson(json);
  Map<String, dynamic> toJson() => _$TopplaylistToJson(this);
}
