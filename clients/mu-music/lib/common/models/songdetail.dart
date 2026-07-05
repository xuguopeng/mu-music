import 'package:json_annotation/json_annotation.dart';

part 'songdetail.g.dart';

@JsonSerializable()
class Songdetail {
  Songdetail();

  late List songs;
  late List privileges;
  late num code;
  
  factory Songdetail.fromJson(Map<String,dynamic> json) => _$SongdetailFromJson(json);
  Map<String, dynamic> toJson() => _$SongdetailToJson(this);
}
