import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    return Platform.isIOS
        ? dotenv.env['BACKEND_URL_IOS'] ?? ''
        : dotenv.env['BACKEND_URL_ANDROID'] ?? '';
  }
}
