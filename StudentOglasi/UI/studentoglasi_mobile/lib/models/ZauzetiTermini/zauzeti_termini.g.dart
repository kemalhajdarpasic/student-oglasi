// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zauzeti_termini.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZauzetiTermini _$ZauzetiTerminiFromJson(Map<String, dynamic> json) =>
    ZauzetiTermini(
      json['datumPrijave'] == null
          ? null
          : DateTime.parse(json['datumPrijave'] as String),
      json['datumOdjave'] == null
          ? null
          : DateTime.parse(json['datumOdjave'] as String),
    );

Map<String, dynamic> _$ZauzetiTerminiToJson(ZauzetiTermini instance) =>
    <String, dynamic>{
      'datumPrijave': instance.datumPrijave?.toIso8601String(),
      'datumOdjave': instance.datumOdjave?.toIso8601String(),
    };
