import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences storage;

  static Future<void> initLocalStorage() async {
    storage = await SharedPreferences.getInstance();
  }
}
