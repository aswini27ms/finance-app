import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Resolves API base URL for the current platform.
/// Override at build time: --dart-define=API_BASE_URL=http://192.168.1.5:5000/api
class ApiConfig {
  static const String _envUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envUrl.isNotEmpty) return _envUrl;
    if (kIsWeb) return 'http://localhost:5000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
      if (Platform.isIOS) return 'http://127.0.0.1:5000/api';
    } catch (_) {}
    return 'http://localhost:5000/api';
  }
}
