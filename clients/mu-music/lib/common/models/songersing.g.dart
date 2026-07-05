// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'songersing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Songersing _$SongersingFromJson(Map<String, dynamic> json) => Songersing()
  ..songs = json['songs'] as List<dynamic>?
  ..more = json['more'] as bool
  ..total = json['total'] as num?
  ..code = json['code'] as num?;

Map<String, dynamic> _$SongersingToJson(Songersing instance) =>
    <String, dynamic>{
      'songs': instance.songs,
      'more': instance.more,
      'total': instance.total,
      'code': instance.code,
    };
