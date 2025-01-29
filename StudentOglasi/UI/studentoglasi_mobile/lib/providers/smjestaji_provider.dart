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

  Future<SearchResult<Smjestaj>> getAllWithRecommendations({
    int studentId = 0,
    dynamic filter
  }) async {
    var url = "${BaseProvider.baseUrl}${endPoint}/with-recommendations/$studentId";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);

    var response = await httpClient.get(uri, headers: createHeaders());

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<Smjestaj>();
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
