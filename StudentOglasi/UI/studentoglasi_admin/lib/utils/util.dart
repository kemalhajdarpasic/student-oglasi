import 'package:intl/intl.dart';
class Authorization {
  static String? username;
  static String? password;
}

String formatNumber(dynamic) {
  var f = NumberFormat('###,00');

  if (dynamic == null) {
    return "";
  }
  return f.format(dynamic);
}