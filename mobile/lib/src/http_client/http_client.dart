import 'package:http/http.dart' as http;
import 'package:mobile/src/env_variables/env_variables.dart';

class HttpClient {
  static late http.Client client;
  static late Uri photoUri;
  static late Uri badgesUri;
  static late Uri badgeUri;

  static void initHttpClient() {
    client = http.Client();
    photoUri = Uri.parse("${API_URL}photo");
    badgesUri = Uri.parse("${API_URL}badges");
    badgeUri = Uri.parse("${API_URL}badge");
  }
}
