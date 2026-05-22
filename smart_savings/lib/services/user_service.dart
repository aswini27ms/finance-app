import 'api_service.dart';

class UserService {
  // Get user details
  static Future<Map<String, dynamic>> getUser(String userId) async {
    return await ApiService.get('/users/$userId');
  }

  // Update user
  static Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String name,
    required String email,
  }) async {
    return await ApiService.put(
      '/users/$userId',
      body: {
        'name': name,
        'email': email,
      },
    );
  }

  // Update user balance
  static Future<Map<String, dynamic>> updateBalance({
    required String userId,
    required double balance,
  }) async {
    return await ApiService.put(
      '/users/$userId/balance',
      body: {
        'balance': balance,
      },
    );
  }
}
