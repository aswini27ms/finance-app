import 'api_service.dart';

class ExpenseService {
  // Get all expenses
  static Future<List<Map<String, dynamic>>> getExpenses() async {
    final response = await ApiService.get('/expenses');
    final expenses = response['expenses'] as List;
    return expenses.cast<Map<String, dynamic>>();
  }

  // Get expenses by folder
  static Future<List<Map<String, dynamic>>> getExpensesByFolder(String folderId) async {
    final response = await ApiService.get('/expenses/folder/$folderId');
    final expenses = response['expenses'] as List;
    return expenses.cast<Map<String, dynamic>>();
  }

  // Get single expense
  static Future<Map<String, dynamic>> getExpense(String expenseId) async {
    final response = await ApiService.get('/expenses/$expenseId');
    return response['expense'];
  }

  // Create expense
  static Future<Map<String, dynamic>> createExpense({
    required String folderId,
    required double amount,
    required String label,
    required String description,
    required String category,
  }) async {
    final response = await ApiService.post(
      '/expenses',
      body: {
        'folderId': folderId,
        'amount': amount,
        'label': label,
        'description': description,
        'category': category,
        'date': DateTime.now().toIso8601String(),
      },
    );
    return response['expense'];
  }

  // Update expense
  static Future<Map<String, dynamic>> updateExpense({
    required String expenseId,
    required double amount,
    required String label,
    required String description,
    required String category,
  }) async {
    final response = await ApiService.put(
      '/expenses/$expenseId',
      body: {
        'amount': amount,
        'label': label,
        'description': description,
        'category': category,
      },
    );
    return response['expense'];
  }

  // Delete expense
  static Future<void> deleteExpense(String expenseId) async {
    await ApiService.delete('/expenses/$expenseId');
  }
}
