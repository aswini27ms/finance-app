import 'api_service.dart';

class FolderService {
  // Get all folders
  static Future<List<Map<String, dynamic>>> getFolders() async {
    final response = await ApiService.get('/folders');
    final folders = response['folders'] as List;
    return folders.cast<Map<String, dynamic>>();
  }

  // Get single folder
  static Future<Map<String, dynamic>> getFolder(String folderId) async {
    final response = await ApiService.get('/folders/$folderId');
    return response['folder'];
  }

  // Create folder
  static Future<Map<String, dynamic>> createFolder({
    required String name,
    required String icon,
    required double budget,
    required int color,
  }) async {
    final response = await ApiService.post(
      '/folders',
      body: {
        'name': name,
        'icon': icon,
        'budget': budget,
        'color': color,
      },
    );
    return response['folder'];
  }

  // Update folder
  static Future<Map<String, dynamic>> updateFolder({
    required String folderId,
    required String name,
    required String icon,
    required double budget,
    required double spent,
    required int color,
  }) async {
    final response = await ApiService.put(
      '/folders/$folderId',
      body: {
        'name': name,
        'icon': icon,
        'budget': budget,
        'spent': spent,
        'color': color,
      },
    );
    return response['folder'];
  }

  // Delete folder
  static Future<void> deleteFolder(String folderId) async {
    await ApiService.delete('/folders/$folderId');
  }

  // Add expense to folder
  static Future<Map<String, dynamic>> addExpense({
    required String folderId,
    required double amount,
  }) async {
    final response = await ApiService.put(
      '/folders/$folderId/add-expense',
      body: {
        'amount': amount,
      },
    );
    return response['folder'];
  }

  // Set budget for folder
  static Future<Map<String, dynamic>> setBudget({
    required String folderId,
    required double budget,
  }) async {
    final response = await ApiService.put(
      '/folders/$folderId/set-budget',
      body: {
        'budget': budget,
      },
    );
    return response['folder'];
  }
}
