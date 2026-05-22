import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/analytics/expense_model.dart';
import '../features/folders/folder_model.dart';
import '../features/goals/goal_model.dart';
import '../features/wishlist/wishlist_model.dart';
import 'auth_provider.dart';
import 'folder_service.dart';
import 'expense_service.dart';
import 'goal_service.dart';
import 'wishlist_service.dart';
import 'local_storage_service.dart';

/// True when data is served from local storage (backend unreachable).
final useLocalDataProvider = StateProvider<bool>((ref) => false);

/// Balance visibility (session-scoped).
/// When `false`, all money amounts derived from balance should be masked in UI.
final balanceVisibleProvider =
    StateNotifierProvider<BalanceVisibilityNotifier, bool>((ref) {
  return BalanceVisibilityNotifier(ref);
});

class BalanceVisibilityNotifier extends StateNotifier<bool> {
  final Ref _ref;
  BalanceVisibilityNotifier(this._ref) : super(false) {
    _ref.listen<bool>(isAuthenticatedProvider, (prev, isAuth) {
      if (!isAuth) state = false;
    }, fireImmediately: true);
  }

  void unlock() => state = true;
  void lock() => state = false;
}

// Balance provider
final balanceProvider = StateProvider<double>((ref) {
  return ref.watch(userBalanceProvider);
});

// ── Folders ───────────────────────────────────────────────────────────────────
// The notifier is created ONCE and lives for the app lifetime.
// It watches auth internally via a ref listener so it never gets recreated.
final foldersProvider =
    StateNotifierProvider<FoldersNotifier, AsyncValue<List<Folder>>>((ref) {
  final notifier = FoldersNotifier(ref);
  return notifier;
});

class FoldersNotifier extends StateNotifier<AsyncValue<List<Folder>>> {
  final Ref _ref;

  FoldersNotifier(this._ref) : super(const AsyncValue.data([])) {
    // Listen to auth changes — fetch when user logs in, clear when logs out
    _ref.listen<bool>(isAuthenticatedProvider, (prev, isAuth) {
      if (isAuth) {
        refresh();
      } else {
        state = const AsyncValue.data([]);
      }
    }, fireImmediately: true);
  }

  Future<void> refresh() async {
    try {
      state = const AsyncValue.loading();
      final data = await FolderService.getFolders();
      _ref.read(useLocalDataProvider.notifier).state = false;
      final folders = data
          .map((f) => Folder(
                id: f['_id'] as String,
                name: f['name'] as String,
                icon: f['icon'] as String? ?? 'folder',
                budget: (f['budget'] as num).toDouble(),
                spent: (f['spent'] as num).toDouble(),
                color: f['color'] as int? ?? 0xFF6366F1,
              ))
          .toList();
      await LocalStorageService.saveFolders(data);
      state = AsyncValue.data(folders);
    } catch (e, st) {
      try {
        final local = await LocalStorageService.getFolders();
        if (local.isNotEmpty) {
          _ref.read(useLocalDataProvider.notifier).state = true;
          state = AsyncValue.data(local.map(_folderFromMap).toList());
          return;
        }
      } catch (_) {}
      state = AsyncValue.error(e, st);
    }
  }

  Folder _folderFromMap(Map<String, dynamic> f) => Folder(
        id: f['_id']?.toString() ?? f['id']?.toString() ?? '',
        name: f['name'] as String,
        icon: f['icon'] as String? ?? 'folder',
        budget: (f['budget'] as num).toDouble(),
        spent: (f['spent'] as num).toDouble(),
        color: f['color'] as int? ?? 0xFF6366F1,
      );

  Future<void> add(Folder f) async {
    // Optimistic insert so UI feels instant
    final prev = state.maybeWhen(data: (l) => l, orElse: () => <Folder>[]);
    final temp = Folder(
      id: '__temp__',
      name: f.name,
      icon: f.icon,
      budget: f.budget,
      spent: 0,
      color: f.color,
    );
    state = AsyncValue.data([...prev, temp]);

    try {
      await FolderService.createFolder(
        name: f.name,
        icon: f.icon,
        budget: f.budget,
        color: f.color,
      );
      await refresh();
    } catch (e) {
      final id = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final entry = {
        '_id': id,
        'name': f.name,
        'icon': f.icon,
        'budget': f.budget,
        'spent': 0,
        'color': f.color,
      };
      final local = await LocalStorageService.getFolders();
      local.add(entry);
      await LocalStorageService.saveFolders(local);
      _ref.read(useLocalDataProvider.notifier).state = true;
      state = AsyncValue.data(
          [...prev.where((x) => x.id != '__temp__'), _folderFromMap(entry)]);
    }
  }

  Future<void> update(String id, Folder Function(Folder) updater) async {
    final current = state.maybeWhen(data: (l) => l, orElse: () => <Folder>[]);
    final folder = current.firstWhere((f) => f.id == id);
    final updated = updater(folder);
    try {
      await FolderService.updateFolder(
        folderId: id,
        name: updated.name,
        icon: updated.icon,
        budget: updated.budget,
        spent: updated.spent,
        color: updated.color,
      );
      await refresh();
    } catch (e) {
      if (_ref.read(useLocalDataProvider) || id.startsWith('local_')) {
        final local = await LocalStorageService.getFolders();
        final idx = local.indexWhere((f) => f['_id'] == id);
        if (idx >= 0) {
          local[idx] = {
            ...local[idx],
            'name': updated.name,
            'icon': updated.icon,
            'budget': updated.budget,
            'spent': updated.spent,
            'color': updated.color,
          };
          await LocalStorageService.saveFolders(local);
          state = AsyncValue.data(local.map(_folderFromMap).toList());
          return;
        }
      }
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    try {
      await FolderService.deleteFolder(id);
      await refresh();
    } catch (e) {
      if (_ref.read(useLocalDataProvider) || id.startsWith('local_')) {
        final local = await LocalStorageService.getFolders();
        local.removeWhere((f) => f['_id'] == id);
        await LocalStorageService.saveFolders(local);
        final expenses = await LocalStorageService.getExpenses();
        expenses.removeWhere((ex) => ex['folderId'] == id);
        await LocalStorageService.saveExpenses(expenses);
        state = AsyncValue.data(local.map(_folderFromMap).toList());
        return;
      }
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> addExpense(String folderId, double amount) async {
    try {
      await FolderService.addExpense(folderId: folderId, amount: amount);
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> setBudget(String folderId, double budget) async {
    try {
      await FolderService.setBudget(folderId: folderId, budget: budget);
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// ── Expenses ──────────────────────────────────────────────────────────────────
final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, AsyncValue<List<Expense>>>((ref) {
  return ExpensesNotifier(ref);
});

class ExpensesNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final Ref _ref;

  ExpensesNotifier(this._ref) : super(const AsyncValue.data([])) {
    _ref.listen<bool>(isAuthenticatedProvider, (prev, isAuth) {
      if (isAuth) {
        refresh();
      } else {
        state = const AsyncValue.data([]);
      }
    }, fireImmediately: true);
  }

  Future<void> refresh() async {
    try {
      state = const AsyncValue.loading();
      final data = await ExpenseService.getExpenses();
      final expenses = data.map((e) => Expense.fromJson(e)).toList();
      await LocalStorageService.saveExpenses(data);
      state = AsyncValue.data(expenses);
    } catch (e, st) {
      try {
        final local = await LocalStorageService.getExpenses();
        if (local.isNotEmpty) {
          state =
              AsyncValue.data(local.map((x) => Expense.fromJson(x)).toList());
          return;
        }
      } catch (_) {}
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Expense e) async {
    try {
      await ExpenseService.createExpense(
        folderId: e.folderId,
        amount: e.amount,
        label: e.label,
        description: e.description,
        category: e.category,
      );
      await refresh();
      await _ref.read(foldersProvider.notifier).refresh();
    } catch (_) {
      final id = 'local_exp_${DateTime.now().millisecondsSinceEpoch}';
      final entry = {
        '_id': id,
        'folderId': e.folderId,
        'amount': e.amount,
        'label': e.label,
        'description': e.description,
        'category': e.category,
        'date': e.date.toIso8601String(),
      };
      final expenses = await LocalStorageService.getExpenses();
      expenses.insert(0, entry);
      await LocalStorageService.saveExpenses(expenses);

      final folders = await LocalStorageService.getFolders();
      final fi = folders.indexWhere((f) => f['_id'] == e.folderId);
      if (fi >= 0) {
        folders[fi]['spent'] =
            (folders[fi]['spent'] as num).toDouble() + e.amount;
        await LocalStorageService.saveFolders(folders);
      }
      _ref.read(useLocalDataProvider.notifier).state = true;
      await refresh();
      await _ref.read(foldersProvider.notifier).refresh();
    }
  }

  Future<void> remove(String expenseId) async {
    try {
      await ExpenseService.deleteExpense(expenseId);
      await refresh();
      await _ref.read(foldersProvider.notifier).refresh();
    } catch (_) {
      final expenses = await LocalStorageService.getExpenses();
      final idx = expenses.indexWhere((x) => x['_id'] == expenseId);
      if (idx < 0) return;
      final removed = expenses.removeAt(idx);
      await LocalStorageService.saveExpenses(expenses);
      final folders = await LocalStorageService.getFolders();
      final fi = folders.indexWhere((f) => f['_id'] == removed['folderId']);
      if (fi >= 0) {
        folders[fi]['spent'] = ((folders[fi]['spent'] as num).toDouble() -
                (removed['amount'] as num).toDouble())
            .clamp(0, double.infinity);
        await LocalStorageService.saveFolders(folders);
      }
      await refresh();
      await _ref.read(foldersProvider.notifier).refresh();
    }
  }
}

// ── Wishlist ──────────────────────────────────────────────────────────────────
final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, AsyncValue<List<WishlistItem>>>(
        (ref) {
  return WishlistNotifier(ref);
});

class WishlistNotifier extends StateNotifier<AsyncValue<List<WishlistItem>>> {
  final Ref _ref;

  WishlistNotifier(this._ref) : super(const AsyncValue.data([])) {
    _ref.listen<bool>(isAuthenticatedProvider, (prev, isAuth) {
      if (isAuth) {
        refresh();
      } else {
        state = const AsyncValue.data([]);
      }
    }, fireImmediately: true);
  }

  Future<void> refresh() async {
    try {
      state = const AsyncValue.loading();
      final data = await WishlistService.getWishlistItems();
      final items = data.map(WishlistItem.fromJson).toList();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(WishlistItem i) async {
    try {
      await WishlistService.createWishlistItem(
        name: i.name,
        price: i.price,
        imageEmoji: i.imageEmoji,
        imageUrl: i.imageUrl,
        merchantUrl: i.merchantUrl,
        merchantName: i.merchantName,
        category: i.category,
        priority: i.priority,
        description: '',
        dailySaving: i.dailySaving,
        monthlySaving: i.monthlySaving,
        expectedPurchaseDate: i.expectedPurchaseDate,
      );
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> update(
      String id, WishlistItem Function(WishlistItem) updater) async {
    try {
      final current =
          state.maybeWhen(data: (l) => l, orElse: () => <WishlistItem>[]);
      final item = current.firstWhere((i) => i.id == id);
      final updated = updater(item);
      await WishlistService.updateWishlistItem(
        itemId: id,
        name: updated.name,
        price: updated.price,
        saved: updated.saved,
        dailySaving: updated.dailySaving,
        monthlySaving: updated.monthlySaving,
        imageEmoji: updated.imageEmoji,
        imageUrl: updated.imageUrl,
        merchantUrl: updated.merchantUrl,
        merchantName: updated.merchantName,
        category: updated.category,
        priority: updated.priority,
        description: '',
        expectedPurchaseDate: updated.expectedPurchaseDate,
        completed: false,
      );
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    try {
      await WishlistService.deleteWishlistItem(id);
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> addSavings(String id, double amount, {String note = ''}) async {
    final current =
        state.maybeWhen(data: (l) => l, orElse: () => <WishlistItem>[]);
    state = AsyncValue.data([
      for (final item in current)
        if (item.id == id)
          item.copyWith(
              saved: (item.saved + amount).clamp(0, item.price).toDouble())
        else
          item
    ]);
    try {
      await WishlistService.addSavings(itemId: id, amount: amount, note: note);
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// ── Derived providers ─────────────────────────────────────────────────────────
final totalSpentProvider = Provider<double>((ref) {
  return ref.watch(foldersProvider).maybeWhen(
        data: (f) => f.fold<double>(0, (s, x) => s + x.spent),
        orElse: () => 0,
      );
});

final totalBudgetedProvider = Provider<double>((ref) {
  return ref.watch(foldersProvider).maybeWhen(
        data: (f) => f.fold<double>(0, (s, x) => s + x.budget),
        orElse: () => 0,
      );
});

/// Spendable balance = bank total − sum of folder allocations (budgets).
final remainingBalanceProvider = Provider<double>((ref) {
  final balance = ref.watch(balanceProvider);
  final allocated = ref.watch(totalBudgetedProvider);
  return (balance - allocated).clamp(0, double.infinity);
});

/// Total saved this month (balance minus spent).
final monthlySavedProvider = Provider<double>((ref) {
  final balance = ref.watch(balanceProvider);
  final spent = ref.watch(totalSpentProvider);
  return (balance - spent).clamp(0, double.infinity);
});

final healthScoreProvider = Provider<int>((ref) {
  final balance = ref.watch(balanceProvider);
  final spent = ref.watch(totalSpentProvider);
  final budgeted = ref.watch(totalBudgetedProvider);
  if (balance == 0) return 0;
  final saveRate = ((balance - spent) / balance).clamp(0, 1);
  final budgetDiscipline =
      budgeted == 0 ? 0.5 : (1 - (spent / budgeted)).clamp(0, 1);
  return ((saveRate * 60) + (budgetDiscipline * 40)).round();
});

final savingsStreakProvider = StateProvider<int>((ref) => 14);

// Goals
final goalsProvider =
    StateNotifierProvider<GoalsNotifier, AsyncValue<List<SavingsGoal>>>((ref) {
  return GoalsNotifier(ref);
});

class GoalsNotifier extends StateNotifier<AsyncValue<List<SavingsGoal>>> {
  final Ref _ref;

  GoalsNotifier(this._ref) : super(const AsyncValue.data([])) {
    _ref.listen<bool>(isAuthenticatedProvider, (prev, isAuth) {
      if (isAuth) {
        refresh();
      } else {
        state = const AsyncValue.data([]);
      }
    }, fireImmediately: true);
  }

  Future<void> refresh() async {
    try {
      state = const AsyncValue.loading();
      final data = await GoalService.getGoals();
      state = AsyncValue.data(data.map(SavingsGoal.fromJson).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(SavingsGoal goal) async {
    try {
      await GoalService.createGoal(
        name: goal.name,
        targetAmount: goal.targetAmount,
        savedAmount: goal.savedAmount,
        deadline: goal.deadline,
        category: goal.category,
        icon: goal.icon,
        color: goal.color,
      );
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> update(
      String id, SavingsGoal Function(SavingsGoal) updater) async {
    final current =
        state.maybeWhen(data: (l) => l, orElse: () => <SavingsGoal>[]);
    final goal = current.firstWhere((g) => g.id == id);
    final updated = updater(goal);
    try {
      await GoalService.updateGoal(
        goalId: id,
        name: updated.name,
        targetAmount: updated.targetAmount,
        savedAmount: updated.savedAmount,
        deadline: updated.deadline,
        category: updated.category,
        icon: updated.icon,
        color: updated.color,
      );
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> addSavings(String id, double amount, {String note = ''}) async {
    final current =
        state.maybeWhen(data: (l) => l, orElse: () => <SavingsGoal>[]);
    state = AsyncValue.data([
      for (final goal in current)
        if (goal.id == id)
          goal.copyWith(
            savedAmount: (goal.savedAmount + amount)
                .clamp(0, goal.targetAmount)
                .toDouble(),
          )
        else
          goal
    ]);
    try {
      await GoalService.addSavings(goalId: id, amount: amount, note: note);
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    try {
      await GoalService.deleteGoal(id);
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Last 7 days spending (index 0 = 6 days ago, 6 = today).
final weeklySpendProvider = Provider<List<double>>((ref) {
  return ref.watch(expensesProvider).maybeWhen(
        data: (list) {
          final amounts = List<double>.filled(7, 0);
          for (final e in list) {
            if (e.daysAgo >= 0 && e.daysAgo < 7) {
              amounts[6 - e.daysAgo] += e.amount;
            }
          }
          return amounts;
        },
        orElse: () => List<double>.filled(7, 0),
      );
});

// ── Income records (for transaction history) ──────────────────────────────────
final incomesProvider = StateNotifierProvider<IncomesNotifier,
    AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return IncomesNotifier(ref);
});

class IncomesNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final Ref _ref;
  IncomesNotifier(this._ref) : super(const AsyncValue.data([])) {
    _ref.listen<bool>(isAuthenticatedProvider, (prev, isAuth) {
      if (isAuth) {
        refresh();
      } else {
        state = const AsyncValue.data([]);
      }
    }, fireImmediately: true);
  }

  Future<void> refresh() async {
    state = AsyncValue.data(await LocalStorageService.getIncomes());
  }

  Future<void> add({required double amount, required String label}) async {
    final entry = {
      '_id': 'local_inc_${DateTime.now().millisecondsSinceEpoch}',
      'amount': amount,
      'label': label,
      'date': DateTime.now().toIso8601String(),
    };
    final list = await LocalStorageService.getIncomes();
    list.insert(0, entry);
    await LocalStorageService.saveIncomes(list);
    state = AsyncValue.data(list);
  }
}

/// Unified transaction list item for history screen.
class TransactionItem {
  final String id;
  final bool isIncome;
  final double amount;
  final String label;
  final String subtitle;
  final int daysAgo;

  const TransactionItem({
    required this.id,
    required this.isIncome,
    required this.amount,
    required this.label,
    required this.subtitle,
    required this.daysAgo,
  });
}

final allTransactionsProvider =
    Provider<AsyncValue<List<TransactionItem>>>((ref) {
  final expenses = ref.watch(expensesProvider);
  final incomes = ref.watch(incomesProvider);
  return expenses.when(
    data: (expList) => incomes.when(
      data: (incList) {
        final items = <TransactionItem>[
          ...expList.map((e) => TransactionItem(
                id: e.id,
                isIncome: false,
                amount: e.amount,
                label: e.label,
                subtitle: e.folderName.isNotEmpty ? e.folderName : e.category,
                daysAgo: e.daysAgo,
              )),
          ...incList.map((i) {
            final dateStr = i['date'] as String?;
            final date = dateStr != null
                ? DateTime.tryParse(dateStr) ?? DateTime.now()
                : DateTime.now();
            return TransactionItem(
              id: i['_id']?.toString() ?? '',
              isIncome: true,
              amount: (i['amount'] as num).toDouble(),
              label: i['label']?.toString() ?? 'Income',
              subtitle: 'Income',
              daysAgo: DateTime.now().difference(date).inDays,
            );
          }),
        ];
        items.sort((a, b) => a.daysAgo.compareTo(b.daysAgo));
        return AsyncValue.data(items);
      },
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

/// Smart insights provider for dashboard tips
final smartInsightsProvider = Provider<List<String>>((ref) {
  return [
    'Track your spending regularly to stay on budget.',
    'Set realistic savings goals and review them monthly.',
    'Automate your savings by setting up recurring transfers.',
    'Use the AI coach to get personalized financial advice.',
    'Review your expenses weekly to identify patterns.',
  ];
});
