import 'package:json_annotation/json_annotation.dart';

part 'singers.g.dart';

@JsonSerializable()
class Singers {
  Singers();

  late num code;
  late bool more;
  late List artists;
  
  factory Singers.fromJson(Map<String,dynamic> json) => _$SingersFromJson(json);
  Map<String, dynamic> toJson() => _$SingersToJson(this);
}
