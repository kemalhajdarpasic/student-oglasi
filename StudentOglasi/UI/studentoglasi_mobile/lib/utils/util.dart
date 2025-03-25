import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/firebase_options.dart';
import 'package:studentoglasi_mobile/providers/studenti_provider.dart';
import 'package:studentoglasi_mobile/services/database_service.dart';
import 'package:studentoglasi_mobile/services/media_service.dart';

import '../firebase_api.dart';

class Authorization {
  static String? username;
  static String? password;
}

void logout(BuildContext context) {
  final studentiProvider = Provider.of<StudentiProvider>(context, listen: false);
  
  Authorization.username = null;
  Authorization.password = null;
  studentiProvider.logout();

  Navigator.pop(context); 
  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
}

String formatNumber(dynamic) {
  var f = NumberFormat();

  if (dynamic == null) {
    return "";
  }
  return f.format(dynamic);
}

class FilePathManager {
  static String baseUrl =
      "https://studentoglasirs2.blob.core.windows.net/files/";

  static String constructUrl(String fileName) {
    return baseUrl + fileName;
  }
}

Future<void> setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
}

Future<void> registerServices() async {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<DatabaseService>(
    DatabaseService(),
  );
   getIt.registerSingleton<MediaService>(
    MediaService(),
  );
}

String generateChatID({required String id1, required String id2}) {
  List ids = [id1, id2];
  ids.sort();
  String chatID = ids.fold("", (prevId, id) => "$prevId$id");
  return chatID;
}
