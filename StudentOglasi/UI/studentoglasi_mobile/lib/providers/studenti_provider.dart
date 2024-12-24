import 'dart:convert';
import 'package:studentoglasi_mobile/models/Student/student.dart';
import 'package:studentoglasi_mobile/providers/base_provider.dart';

class StudentiProvider extends BaseProvider<Student> {
  StudentiProvider() : super('Studenti');

  Student? _currentStudent;
  Student? get currentStudent => _currentStudent;

  @override
  Student fromJson(data) {
    // TODO: implement fromJson
    return Student.fromJson(data);
  }

  Future<Student> getCurrentStudent() async {
    var url = "${BaseProvider.baseUrl}${endPoint}/currentStudent";
    var uri = Uri.parse(url);

    var response = await httpClient.get(uri, headers: createHeaders());

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      _currentStudent = fromJson(data);
      return _currentStudent!;
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<bool> changePassword(int id, dynamic request) async {
    var url = "${BaseProvider.baseUrl}${endPoint}/$id/change-Password";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request, toEncodable: myDateSerializer);
    var response = await httpClient.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    var url = "${BaseProvider.baseUrl}${endPoint}/check-username/$username";
    var uri = Uri.parse(url);

    var response = await httpClient.get(uri, headers: createHeaders());

    if (response.statusCode == 200) {
      return false;
    } else {
      return true;
    }
  }
}
