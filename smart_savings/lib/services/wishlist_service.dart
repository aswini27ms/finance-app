import 'api_service.dart';

class WishlistService {
  // Get all wishlist items
  static Future<List<Map<String, dynamic>>> getWishlistItems() async {
    final response = await ApiService.get('/wishlist');
    final items = response['items'] as List;
    return items.cast<Map<String, dynamic>>();
  }

  // Get single wishlist item
  static Future<Map<String, dynamic>> getWishlistItem(String itemId) async {
    final response = await ApiService.get('/wishlist/$itemId');
    return response['item'];
  }

  // Create wishlist item
  static Future<Map<String, dynamic>> createWishlistItem({
    required String name,
    required double price,
    required String imageEmoji,
    required String imageUrl,
    required String merchantUrl,
    required String merchantName,
    required String category,
    required String priority,
    required String description,
    required double dailySaving,
    required double monthlySaving,
    required DateTime? expectedPurchaseDate,
  }) async {
    final response = await ApiService.post(
      '/wishlist',
      body: {
        'name': name,
        'price': price,
        'imageEmoji': imageEmoji,
        'imageUrl': imageUrl,
        'merchantUrl': merchantUrl,
        'merchantName': merchantName,
        'category': category,
        'priority': priority,
        'description': description,
        'dailySaving': dailySaving,
        'monthlySaving': monthlySaving,
        'expectedPurchaseDate': expectedPurchaseDate?.toIso8601String(),
      },
    );
    return response['item'];
  }

  // Update wishlist item
  static Future<Map<String, dynamic>> updateWishlistItem({
    required String itemId,
    required String name,
    required double price,
    required double saved,
    required double dailySaving,
    required double monthlySaving,
    required String imageEmoji,
    required String imageUrl,
    required String merchantUrl,
    required String merchantName,
    required String category,
    required String priority,
    required String description,
    required DateTime? expectedPurchaseDate,
    required bool completed,
  }) async {
    final response = await ApiService.put(
      '/wishlist/$itemId',
      body: {
        'name': name,
        'price': price,
        'saved': saved,
        'dailySaving': dailySaving,
        'monthlySaving': monthlySaving,
        'imageEmoji': imageEmoji,
        'imageUrl': imageUrl,
        'merchantUrl': merchantUrl,
        'merchantName': merchantName,
        'category': category,
        'priority': priority,
        'description': description,
        'expectedPurchaseDate': expectedPurchaseDate?.toIso8601String(),
        'completed': completed,
      },
    );
    return response['item'];
  }

  // Delete wishlist item
  static Future<void> deleteWishlistItem(String itemId) async {
    await ApiService.delete('/wishlist/$itemId');
  }

  // Add savings to wishlist item
  static Future<Map<String, dynamic>> addSavings({
    required String itemId,
    required double amount,
    String note = '',
  }) async {
    final response = await ApiService.put(
      '/wishlist/$itemId/add-savings',
      body: {
        'amount': amount,
        'note': note,
      },
    );
    return response['item'];
  }
}
