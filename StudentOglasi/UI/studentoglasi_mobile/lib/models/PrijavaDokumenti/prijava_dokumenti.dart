import 'package:json_annotation/json_annotation.dart';

part 'prijava_dokumenti.g.dart';

@JsonSerializable()
class PrijavaDokumenti {
  int? id;
  String? naziv;
  String? originalniNaziv;

  PrijavaDokumenti(this.id, this.naziv, this.originalniNaziv);

  factory PrijavaDokumenti.fromJson(Map<String, dynamic> json) => _$PrijavaDokumentiFromJson(json);

  Map<String, dynamic> toJson() => _$PrijavaDokumentiToJson(this);
}
