import 'package:flutter/material.dart';
import 'package:mobile/src/storage/local_storage.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode() async {
    final themeString = LocalStorage.storage.getString("themeMode");

    switch (themeString) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    final String themeString;

    switch (theme) {
      case ThemeMode.light:
        themeString = "light";
        break;
      case ThemeMode.dark:
        themeString = "dark";
        break;
      default:
        themeString = "system";
        break;
    }

    await LocalStorage.storage.setString("themeMode", themeString);
  }
}
