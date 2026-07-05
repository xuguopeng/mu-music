import 'package:json_annotation/json_annotation.dart';

part 'scrobble.g.dart';

@JsonSerializable()
class Scrobble {
  Scrobble();

  late num code;
  late String data;
  late String message;
  
  factory Scrobble.fromJson(Map<String,dynamic> json) => _$ScrobbleFromJson(json);
  Map<String, dynamic> toJson() => _$ScrobbleToJson(this);
}
