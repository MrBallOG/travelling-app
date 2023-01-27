import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/src/camera/cameras_controller.dart';
import 'package:mobile/src/sign_in/google_sign_in_controller.dart';
import 'package:mobile/src/storage/local_storage.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await LocalStorage.initLocalStorage();
  await settingsController.loadSettings();
  await CamerasController.loadCameras();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => settingsController),
      Provider(create: (context) => GoogleSingInController()),
    ],
    child: const MyApp(),
  ));
}
