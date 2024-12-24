import 'dart:convert';

import 'package:studentoglasi_mobile/models/Smjestaj/smjestaj.dart';
import 'package:studentoglasi_mobile/providers/base_provider.dart';
import '../models/search_result.dart';

class SmjestajiProvider extends BaseProvider<Smjestaj> {
  SmjestajiProvider() : super('Smjestaji');
 @override
  Smjestaj fromJson(data) {
    // TODO: implement fromJson
    return Smjestaj.fromJson(data);
  }

    Future<SearchResult<Smjestaj>> getRecommended(int studentId) async {
    var url = "${BaseProvider.baseUrl}${endPoint}/recommendations/$studentId";
    var uri = Uri.parse(url);
    var response = await httpClient.get(uri, headers: createHeaders());

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      var result = SearchResult<Smjestaj>();

      result.count = data.length;

      for (var item in data) {
        result.result.add(fromJson(item));
      }

      return result;
    } else {
      throw Exception("Unknown error");
    }
  }
}
