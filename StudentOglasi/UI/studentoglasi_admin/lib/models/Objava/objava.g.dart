// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'objava.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Objava _$ObjavaFromJson(Map<String, dynamic> json) => Objava(
      json['id'] as int?,
      json['naslov'] as String?,
      json['sadrzaj'] as String?,
      json['vrijemeObjave'] == null
          ? null
          : DateTime.parse(json['vrijemeObjave'] as String),
      json['kategorija'] == null
          ? null
          : Kategorija.fromJson(json['kategorija'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ObjavaToJson(Objava instance) => <String, dynamic>{
      'id': instance.id,
      'naslov': instance.naslov,
      'sadrzaj': instance.sadrzaj,
      'vrijemeObjave': instance.vrijemeObjave?.toIso8601String(),
      'kategorija': instance.kategorija,
    };
