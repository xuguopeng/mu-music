import 'data.songs.model.dart';

class Recommend {
  int? code;
  Data? data;

  Recommend({this.code, this.data});

  factory Recommend.fromJson(Map<String, dynamic> json) => Recommend(
        code: json['code'] as int?,
        data: json['data'] == null
            ? null
            : Data.fromJson(json['data'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'data': data?.toJson(),
      };
}
