// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personalized.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Personalized _$PersonalizedFromJson(Map<String, dynamic> json) => Personalized()
  ..hasTaste = json['hasTaste'] as bool
  ..code = json['code'] as num
  ..category = json['category'] as num
  ..result = json['result'] as List<dynamic>;

Map<String, dynamic> _$PersonalizedToJson(Personalized instance) =>
    <String, dynamic>{
      'hasTaste': instance.hasTaste,
      'code': instance.code,
      'category': instance.category,
      'result': instance.result,
    };
