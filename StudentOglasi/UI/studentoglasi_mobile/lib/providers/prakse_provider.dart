import 'dart:convert';

import 'package:studentoglasi_mobile/models/Praksa/praksa.dart';
import 'package:studentoglasi_mobile/providers/base_provider.dart';
import '../models/search_result.dart';

class PraksaProvider extends BaseProvider<Praksa> {
  PraksaProvider() : super('Prakse');
  @override
  Praksa fromJson(data) {
    // TODO: implement fromJson
    return Praksa.fromJson(data);
  }

  Future<SearchResult<Praksa>> getRecommended(int studentId) async {
    var url = "${BaseProvider.baseUrl}${endPoint}/recommendations/$studentId";
    var uri = Uri.parse(url);
    var response = await httpClient.get(uri, headers: createHeaders());

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      var result = SearchResult<Praksa>();

      result.count = data.length;

      for (var item in data) {
        result.result.add(fromJson(item));
      }

      return result;
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<SearchResult<Praksa>> getAllWithRecommendations(
      {int studentId = 0, dynamic filter}) async {
    var url =
        "${BaseProvider.baseUrl}${endPoint}/with-recommendations/$studentId";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);

    var response = await httpClient.get(uri, headers: createHeaders());

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<Praksa>();
      result.count = data['count'];

      for (var item in data['result']) {
        result.result.add(fromJson(item));
      }

      return result;
    } else {
      throw Exception("Failed to fetch recommendations");
    }
  }
}
