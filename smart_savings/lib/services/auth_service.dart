import 'api_service.dart';

class AuthService {
  // Register a new user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    if (response['success'] == true && response['token'] != null) {
      await ApiService.saveToken(response['token']);
    }

    return response;
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response['success'] == true && response['token'] != null) {
      await ApiService.saveToken(response['token']);
    }

    return response;
  }

  // Get current user
  static Future<Map<String, dynamic>> getCurrentUser() async {
    return await ApiService.get('/auth/me');
  }

  // Logout
  static Future<void> logout() async {
    await ApiService.clearToken();
  }
}
