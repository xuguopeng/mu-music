// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Playlist _$PlaylistFromJson(Map<String, dynamic> json) => Playlist()
  ..code = json['code'] as num
  ..relatedVideos = json['relatedVideos'] as String?
  ..playlist = json['playlist'] as Map<String, dynamic>;

Map<String, dynamic> _$PlaylistToJson(Playlist instance) => <String, dynamic>{
      'code': instance.code,
      'relatedVideos': instance.relatedVideos,
      'playlist': instance.playlist,
    };
