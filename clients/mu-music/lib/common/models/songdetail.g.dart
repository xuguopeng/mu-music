// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'songdetail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Songdetail _$SongdetailFromJson(Map<String, dynamic> json) => Songdetail()
  ..songs = json['songs'] as List<dynamic>
  ..privileges = json['privileges'] as List<dynamic>
  ..code = json['code'] as num;

Map<String, dynamic> _$SongdetailToJson(Songdetail instance) =>
    <String, dynamic>{
      'songs': instance.songs,
      'privileges': instance.privileges,
      'code': instance.code,
    };
