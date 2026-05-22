import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/savings_service.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../theme/app_colors.dart';
import '../../analytics/expense_model.dart';
/// Standalone add-expense sheet with folder picker (dashboard, transactions, sidebar).
void showAddExpenseSheet(BuildContext context, {String? preselectedFolderId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => AddExpenseSheet(preselectedFolderId: preselectedFolderId),
  );
}

class AddExpenseSheet extends ConsumerStatefulWidget {
  final String? preselectedFolderId;
  const AddExpenseSheet({super.key, this.preselectedFolderId});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _amountCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();
  final _merchantCtrl = TextEditingController();
  String? _folderId;
  String _category = 'food';
  bool _loading = false;
  String? _error;

  static const _categories = [
    'food', 'transport', 'shopping', 'health', 'entertainment', 'education', 'other',
  ];

  @override
  void initState() {
    super.initState();
    _folderId = widget.preselectedFolderId;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _labelCtrl.dispose();
    _merchantCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amt <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    final label = _labelCtrl.text.trim();
    if (label.isEmpty) {
      setState(() => _error = 'Enter a label');
      return;
    }
    if (_folderId == null || _folderId == '__temp__') {
      setState(() => _error = 'Select a folder');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(expensesProvider.notifier).add(Expense(
        id: '',
        folderId: _folderId!,
        amount: amt,
        label: label,
        description: _merchantCtrl.text.trim(),
        category: _category,
        date: DateTime.now(),
        daysAgo: 0,
      ));
      await ref.read(foldersProvider.notifier).refresh();
      HapticFeedback.mediumImpact();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense ₹${amt.toStringAsFixed(0)} added'),
            backgroundColor: const Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final folders = ref.watch(foldersProvider);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Add Expense',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            folders.when(
              data: (list) {
                final valid = list.where((f) => f.id != '__temp__').toList();
                if (valid.isEmpty) {
                  return Text('Create a folder first',
                      style: TextStyle(color: Colors.grey[600]));
                }
                return DropdownButtonFormField<String>(
                  initialValue:
                      _folderId != null && valid.any((f) => f.id == _folderId)
                      ? _folderId
                      : valid.first.id,
                  decoration: InputDecoration(
                    labelText: 'Category / Folder',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: valid
                      .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _folderId = v),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Could not load folders'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
                errorText: _error,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _labelCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Label',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _merchantCtrl,
              decoration: InputDecoration(
                labelText: 'Merchant (optional)',
                hintText: 'e.g. Swiggy',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((c) {
                final sel = _category == c;
                return GestureDetector(
                  onTap: () => setState(() => _category = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(c,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : AppColors.primary)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: _loading ? 'Adding…' : 'Add Expense',
              onPressed: _loading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
