import 'package:json_annotation/json_annotation.dart';

part 'songersing.g.dart';

@JsonSerializable()
class Songersing {
  Songersing();

  List? songs;
  late bool more;
  num? total;
  num? code;

  factory Songersing.fromJson(Map<String, dynamic> json) =>
      _$SongersingFromJson(json);
  Map<String, dynamic> toJson() => _$SongersingToJson(this);
}
