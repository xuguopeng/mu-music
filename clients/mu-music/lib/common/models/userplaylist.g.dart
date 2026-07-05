// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userplaylist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Userplaylist _$UserplaylistFromJson(Map<String, dynamic> json) => Userplaylist()
  ..more = json['more'] as bool
  ..playlist = json['playlist'] as List<dynamic>
  ..code = json['code'] as num;

Map<String, dynamic> _$UserplaylistToJson(Userplaylist instance) =>
    <String, dynamic>{
      'more': instance.more,
      'playlist': instance.playlist,
      'code': instance.code,
    };
