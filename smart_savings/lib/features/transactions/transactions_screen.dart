import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/savings_service.dart';
import '../../shared/components/main_shell.dart';
import '../../shared/widgets/premium_effects.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../dashboard/widgets/balance_editor_sheet.dart';
import '../folders/widgets/add_expense_sheet.dart';

enum _Filter { all, income, expense, today, week, month }

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});
  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  _Filter _filter = _Filter.all;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TransactionItem> _applyFilter(List<TransactionItem> all) {
    final byKind = switch (_filter) {
      _Filter.income => all.where((e) => e.isIncome).toList(),
      _Filter.expense => all.where((e) => !e.isIncome).toList(),
      _Filter.today => all.where((e) => e.daysAgo == 0).toList(),
      _Filter.week => all.where((e) => e.daysAgo <= 7).toList(),
      _Filter.month => all.where((e) => e.daysAgo <= 30).toList(),
      _Filter.all => all,
    };
    if (_query.trim().isEmpty) return byKind;
    final q = _query.toLowerCase();
    return byKind.where((e) => e.label.toLowerCase().contains(q) || e.subtitle.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(allTransactionsProvider);
    final balance = ref.watch(balanceProvider);
    final spent = ref.watch(totalSpentProvider);
    final saved = ref.watch(monthlySavedProvider);
    final visible = ref.watch(balanceVisibleProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const ShellBackButton(),
        title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddExpenseSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.remove_rounded, color: Colors.white),
        label: const Text('Add Expense', style: TextStyle(color: Colors.white)),
      ),
      body: PremiumPageBackground(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF181A22), Color(0xFF11131A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Track every move with a cleaner money timeline.',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Review spending, income, and search history in one easier view.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.62), height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryTile(
                          label: visible ? 'Balance' : 'Balance locked',
                          value: visible ? Formatters.money(balance) : '₹ •••••',
                          icon: visible ? Icons.account_balance_wallet_outlined : Icons.lock_rounded,
                          onTap: visible
                              ? null
                              : () => showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    useSafeArea: true,
                                    builder: (_) => const BalanceEditorSheet(),
                                  ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryTile(
                          label: 'Spent',
                          value: Formatters.money(spent),
                          icon: Icons.arrow_upward_rounded,
                          valueColor: const Color(0xFFFF6B6B),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryTile(
                          label: 'Saved',
                          value: Formatters.money(saved),
                          icon: Icons.savings_outlined,
                          valueColor: const Color(0xFF4ADE80),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search merchant, category, notes',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: _Filter.values.map((f) {
                  final sel = _filter == f;
                  final label = switch (f) {
                    _Filter.all => 'All',
                    _Filter.income => 'Income',
                    _Filter.expense => 'Expense',
                    _Filter.today => 'Today',
                    _Filter.week => 'This Week',
                    _Filter.month => 'This Month',
                  };
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _filter = f);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel ? Colors.transparent : AppColors.primary.withValues(alpha: 0.10),
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.primary),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: transactions.when(
                data: (all) {
                  final filtered = _applyFilter(all);
                  if (filtered.isEmpty) return _EmptyState(filter: _filter);
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _TransactionTile(item: filtered[i])
                        .animate()
                        .fadeIn(delay: (i * 40).ms)
                        .slideY(begin: 0.05),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('Could not load transactions'),
                      TextButton(
                        onPressed: () {
                          ref.read(expensesProvider.notifier).refresh();
                          ref.read(incomesProvider.notifier).refresh();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends ConsumerWidget {
  final TransactionItem item;
  const _TransactionTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final color = item.isIncome ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final prefix = item.isIncome ? '+' : '-';

    return Dismissible(
      key: Key(item.id),
      direction: item.isIncome ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
      ),
      confirmDismiss: item.isIncome
          ? null
          : (_) async {
              return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete expense?'),
                  content: Text('Remove "${item.label}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
      onDismissed: item.isIncome
          ? null
          : (_) async {
              await ref.read(expensesProvider.notifier).remove(item.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.label} deleted'), action: SnackBarAction(label: 'Undo', onPressed: () {})),
                );
              }
            },
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _TransactionDetailSheet(item: item),
        ),
        child: PremiumGlassCard(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      '${item.subtitle} • ${item.daysAgo == 0 ? 'Today' : item.daysAgo == 1 ? 'Yesterday' : '${item.daysAgo}d ago'}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Text('$prefix₹${item.amount.toStringAsFixed(0)}', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionDetailSheet extends StatelessWidget {
  final TransactionItem item;
  const _TransactionDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.isIncome ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(item.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(item.label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 18),
          _DetailRow('Type', item.isIncome ? 'Income' : 'Expense'),
          _DetailRow('Amount', Formatters.money(item.amount)),
          _DetailRow('Category / Folder', item.subtitle),
          _DetailRow('When', item.daysAgo == 0 ? 'Today' : '${item.daysAgo} days ago'),
          const SizedBox(height: 12),
          if (!item.isIncome)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit transaction from folder history'),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final VoidCallback? onTap;

  const _SummaryTile({required this.label, required this.value, required this.icon, this.valueColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: PremiumGlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: value.contains('•') ? 1.2 : 0,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final _Filter filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final msg = switch (filter) {
      _Filter.today => 'No transactions today',
      _Filter.week => 'No transactions this week',
      _Filter.month => 'No transactions this month',
      _Filter.income => 'No income transactions',
      _Filter.expense => 'No expense transactions',
      _Filter.all => 'No transactions yet',
    };
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(msg, style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Use Add Expense to start building your money timeline.', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
