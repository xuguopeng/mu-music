// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topplaylist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Topplaylist _$TopplaylistFromJson(Map<String, dynamic> json) => Topplaylist()
  ..playlists = json['playlists'] as List<dynamic>
  ..code = json['code'] as num
  ..more = json['more'] as bool
  ..lasttime = json['lasttime'] as num
  ..total = json['total'] as num;

Map<String, dynamic> _$TopplaylistToJson(Topplaylist instance) =>
    <String, dynamic>{
      'playlists': instance.playlists,
      'code': instance.code,
      'more': instance.more,
      'lasttime': instance.lasttime,
      'total': instance.total,
    };
