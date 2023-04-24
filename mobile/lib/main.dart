import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/src/http_client/http_client.dart';
import 'package:mobile/src/sign_in/google_sign_in_controller.dart';
import 'package:mobile/src/storage/local_storage.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await LocalStorage.initLocalStorage();

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  HttpClient.initHttpClient();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => settingsController),
      Provider(create: (context) => GoogleSingInController()),
    ],
    child: const MyApp(),
  ));
}
