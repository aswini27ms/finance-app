import '../features/folders/folder_model.dart';
import '../features/wishlist/wishlist_model.dart';
import '../features/analytics/expense_model.dart';

class MockData {
  static const double initialBalance = 50000;

  static List<Folder> folders() => [
        Folder(id: 'f1', name: 'Emergency', icon: 'shield', budget: 10000, spent: 0, color: 0xFF22C55E),
        Folder(id: 'f2', name: 'Food', icon: 'restaurant', budget: 5000, spent: 1250, color: 0xFFF59E0B),
        Folder(id: 'f3', name: 'Travel', icon: 'flight', budget: 2000, spent: 600, color: 0xFF06B6D4),
        Folder(id: 'f4', name: 'Rent', icon: 'home', budget: 15000, spent: 15000, color: 0xFF6366F1),
        Folder(id: 'f5', name: 'Investments', icon: 'trending_up', budget: 7500, spent: 7500, color: 0xFFEC4899),
        Folder(id: 'f6', name: 'Fun', icon: 'sports_esports', budget: 3000, spent: 800, color: 0xFFF43F5E),
      ];

  static List<WishlistItem> wishlist() => [
        WishlistItem(
          id: 'w1',
          name: 'MacBook Pro 14"',
          price: 180000,
          saved: 42000,
          dailySaving: 400,
          imageEmoji: '💻',
        ),
        WishlistItem(
          id: 'w2',
          name: 'Sony WH-1000XM5',
          price: 28000,
          saved: 12000,
          dailySaving: 150,
          imageEmoji: '🎧',
        ),
        WishlistItem(
          id: 'w3',
          name: 'Weekend in Goa',
          price: 22000,
          saved: 6000,
          dailySaving: 200,
          imageEmoji: '🏖️',
        ),
      ];

  static List<Expense> expenses() => [
        Expense(
            id: 'e1',
            folderId: 'f2',
            amount: 250,
            label: 'Lunch',
            date: DateTime.now(),
            daysAgo: 0),
        Expense(
            id: 'e2',
            folderId: 'f3',
            amount: 600,
            label: 'Uber',
            date: DateTime.now().subtract(const Duration(days: 1)),
            daysAgo: 1),
        Expense(
            id: 'e3',
            folderId: 'f2',
            amount: 1000,
            label: 'Groceries',
            date: DateTime.now().subtract(const Duration(days: 2)),
            daysAgo: 2),
        Expense(
            id: 'e4',
            folderId: 'f6',
            amount: 800,
            label: 'Steam game',
            date: DateTime.now().subtract(const Duration(days: 3)),
            daysAgo: 3),
        Expense(
            id: 'e5',
            folderId: 'f4',
            amount: 15000,
            label: 'Rent',
            date: DateTime.now().subtract(const Duration(days: 5)),
            daysAgo: 5),
      ];

  // 7-day savings trend in rupees.
  static const List<double> savingsTrend = [200, 350, 280, 500, 420, 620, 700];
}
