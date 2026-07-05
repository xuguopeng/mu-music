import 'package:json_annotation/json_annotation.dart';

part 'singer.g.dart';

@JsonSerializable()
class Singer {
  Singer();

  late num code;
  late String message;
  late Map<String,dynamic> data;
  
  factory Singer.fromJson(Map<String,dynamic> json) => _$SingerFromJson(json);
  Map<String, dynamic> toJson() => _$SingerToJson(this);
}
