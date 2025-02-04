import 'package:json_annotation/json_annotation.dart';
import 'package:studentoglasi_mobile/models/Grad/grad.dart';
import 'package:studentoglasi_mobile/models/Slike/slike.dart';
import 'package:studentoglasi_mobile/models/SmjestajnaJedinica/smjestajna_jedinica.dart';
import 'package:studentoglasi_mobile/models/TipSmjestaja/tip_smjestaja.dart';

part 'smjestaj.g.dart';

@JsonSerializable()
class Smjestaj {
  int? id;
  String? naziv;
  String? adresa;
  String? dodatneUsluge;
  String? opis;
  bool? wiFi;
  bool? parking;
  bool? fitnessCentar;
  bool? restoran;
  bool? uslugePrijevoza;
  Grad? grad;
  TipSmjestaja? tipSmjestaja;
  List<SmjestajnaJedinica>? smjestajnaJedinicas;
  List<String>? slike;
  List<Slike>? slikes;
  bool? isRecommended;

  Smjestaj(
      this.id,
      this.dodatneUsluge,
      this.naziv,
      this.adresa,
      this.opis,
      this.wiFi,
      this.parking,
      this.fitnessCentar,
      this.restoran,
      this.uslugePrijevoza,
      this.grad,
      this.tipSmjestaja,
      this.smjestajnaJedinicas,
      this.slike,
      this.slikes,
      this.isRecommended);

  factory Smjestaj.fromJson(Map<String, dynamic> json) =>
      _$SmjestajFromJson(json);

  Map<String, dynamic> toJson() => _$SmjestajToJson(this);
}
