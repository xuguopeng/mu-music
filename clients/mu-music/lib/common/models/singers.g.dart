// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'singers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Singers _$SingersFromJson(Map<String, dynamic> json) => Singers()
  ..code = json['code'] as num
  ..more = json['more'] as bool
  ..artists = json['artists'] as List<dynamic>;

Map<String, dynamic> _$SingersToJson(Singers instance) => <String, dynamic>{
      'code': instance.code,
      'more': instance.more,
      'artists': instance.artists,
    };
