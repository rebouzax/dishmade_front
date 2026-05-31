import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class Env {
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:5280';
  }
}

abstract final class EnvMenu {
  static String get apiBaseUrlMenu {
    return dotenv.env['API_BASE_URL_MENU'] ?? 'http://localhost:3000';
  }
}
