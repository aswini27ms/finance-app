import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Your live Render backend
  static const String _prodUrl =
      'https://smart-savings-api-wjit.onrender.com/api';

  // Override at build time if needed:
  // --dart-define=API_BASE_URL=http://192.168.1.5:5000/api
  static const String _envUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envUrl.isNotEmpty) return _envUrl;
    return _prodUrl;
  }
}
