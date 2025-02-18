// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prijava_dokumenti.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrijavaDokumenti _$PrijavaDokumentiFromJson(Map<String, dynamic> json) =>
    PrijavaDokumenti(
      (json['id'] as num?)?.toInt(),
      json['naziv'] as String?,
      json['originalniNaziv'] as String?,
    );

Map<String, dynamic> _$PrijavaDokumentiToJson(PrijavaDokumenti instance) =>
    <String, dynamic>{
      'id': instance.id,
      'naziv': instance.naziv,
      'originalniNaziv': instance.originalniNaziv,
    };
