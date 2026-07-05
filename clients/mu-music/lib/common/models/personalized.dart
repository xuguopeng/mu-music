import 'package:json_annotation/json_annotation.dart';

part 'personalized.g.dart';

@JsonSerializable()
class Personalized {
  Personalized();

  late bool hasTaste;
  late num code;
  late num category;
  late List result;
  
  factory Personalized.fromJson(Map<String,dynamic> json) => _$PersonalizedFromJson(json);
  Map<String, dynamic> toJson() => _$PersonalizedToJson(this);
}
