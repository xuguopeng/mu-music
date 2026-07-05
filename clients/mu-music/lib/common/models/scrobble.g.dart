// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrobble.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Scrobble _$ScrobbleFromJson(Map<String, dynamic> json) => Scrobble()
  ..code = json['code'] as num
  ..data = json['data'] as String
  ..message = json['message'] as String;

Map<String, dynamic> _$ScrobbleToJson(Scrobble instance) => <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'message': instance.message,
    };
