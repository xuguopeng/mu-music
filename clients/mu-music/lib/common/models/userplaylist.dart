import 'package:json_annotation/json_annotation.dart';

part 'userplaylist.g.dart';

@JsonSerializable()
class Userplaylist {
  Userplaylist();

  late bool more;
  late List playlist;
  late num code;
  
  factory Userplaylist.fromJson(Map<String,dynamic> json) => _$UserplaylistFromJson(json);
  Map<String, dynamic> toJson() => _$UserplaylistToJson(this);
}
