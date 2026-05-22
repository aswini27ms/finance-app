import 'api_service.dart';

class GoalService {
  static Future<List<Map<String, dynamic>>> getGoals() async {
    final response = await ApiService.get('/goals');
    return (response['goals'] as List).cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> createGoal({
    required String name,
    required double targetAmount,
    required double savedAmount,
    required DateTime? deadline,
    required String category,
    required String icon,
    required int color,
  }) async {
    final response = await ApiService.post(
      '/goals',
      body: {
        'name': name,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'deadline': deadline?.toIso8601String(),
        'category': category,
        'icon': icon,
        'color': color,
      },
    );
    return response['goal'];
  }

  static Future<Map<String, dynamic>> updateGoal({
    required String goalId,
    required String name,
    required double targetAmount,
    required double savedAmount,
    required DateTime? deadline,
    required String category,
    required String icon,
    required int color,
  }) async {
    final response = await ApiService.put(
      '/goals/$goalId',
      body: {
        'name': name,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'deadline': deadline?.toIso8601String(),
        'category': category,
        'icon': icon,
        'color': color,
      },
    );
    return response['goal'];
  }

  static Future<Map<String, dynamic>> addSavings({
    required String goalId,
    required double amount,
    String note = '',
  }) async {
    final response = await ApiService.put(
      '/goals/$goalId/add-savings',
      body: {'amount': amount, 'note': note},
    );
    return response['goal'];
  }

  static Future<void> deleteGoal(String goalId) async {
    await ApiService.delete('/goals/$goalId');
  }
}
