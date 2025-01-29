import 'dart:convert';

import 'package:studentoglasi_mobile/models/Stipendija/stipendija.dart';
import 'package:studentoglasi_mobile/providers/base_provider.dart';
import '../models/search_result.dart';

class StipendijeProvider extends BaseProvider<Stipendije> {
  StipendijeProvider() : super('Stipendije');
  @override
  Stipendije fromJson(data) {
    // TODO: implement fromJson
    return Stipendije.fromJson(data);
  }

  Future<SearchResult<Stipendije>> getRecommended(int studentId) async {
    var url = "${BaseProvider.baseUrl}${endPoint}/recommendations/$studentId";
    var uri = Uri.parse(url);
    var response = await httpClient.get(uri, headers: createHeaders());

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      var result = SearchResult<Stipendije>();

      result.count = data.length;

      for (var item in data) {
        result.result.add(fromJson(item));
      }

      return result;
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<SearchResult<Stipendije>> getAllWithRecommendations(
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

      var result = SearchResult<Stipendije>();
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
