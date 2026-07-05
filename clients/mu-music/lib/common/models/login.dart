import 'package:json_annotation/json_annotation.dart';

part 'login.g.dart';

@JsonSerializable()
class Login {
  Login();

  late Map<String, dynamic> data;

  // 获取profile字段，用于判断是否已登录
  Map<String, dynamic>? get profile => data['profile'];

  // 判断是否已登录
  bool get isLoggedIn => profile != null;

  factory Login.fromJson(Map<String, dynamic> json) => _$LoginFromJson(json);
  Map<String, dynamic> toJson() => _$LoginToJson(this);
}
