import 'package:studentoglasi_mobile/models/TipSmjestaja/tip_smjestaja.dart';
import 'package:studentoglasi_mobile/providers/base_provider.dart';

class TipSmjestajaProvider extends BaseProvider<TipSmjestaja> {
  TipSmjestajaProvider() : super('TipSmjestaja');
 @override
  TipSmjestaja fromJson(data) {
    // TODO: implement fromJson
    return TipSmjestaja.fromJson(data);
  }
}