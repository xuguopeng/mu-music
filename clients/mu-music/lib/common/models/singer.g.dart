// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'singer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Singer _$SingerFromJson(Map<String, dynamic> json) => Singer()
  ..code = json['code'] as num
  ..message = json['message'] as String
  ..data = json['data'] as Map<String, dynamic>;

Map<String, dynamic> _$SingerToJson(Singer instance) => <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
