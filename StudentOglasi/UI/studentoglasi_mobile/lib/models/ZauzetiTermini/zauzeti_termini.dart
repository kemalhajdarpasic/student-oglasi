import 'package:json_annotation/json_annotation.dart';

part 'zauzeti_termini.g.dart';

@JsonSerializable()
class ZauzetiTermini {
  DateTime? datumPrijave;
  DateTime? datumOdjave;

  ZauzetiTermini(this.datumPrijave, this.datumOdjave);

  factory ZauzetiTermini.fromJson(Map<String, dynamic> json) =>
      _$ZauzetiTerminiFromJson(json);

  Map<String, dynamic> toJson() => _$ZauzetiTerminiToJson(this);
}
