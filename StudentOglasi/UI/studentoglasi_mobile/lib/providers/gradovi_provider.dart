import 'package:studentoglasi_mobile/models/Grad/grad.dart';
import 'package:studentoglasi_mobile/providers/base_provider.dart';

class GradoviProvider extends BaseProvider<Grad> {
  GradoviProvider() : super('Gradovi');
 @override
  Grad fromJson(data) {
    // TODO: implement fromJson
    return Grad.fromJson(data);
  }
}