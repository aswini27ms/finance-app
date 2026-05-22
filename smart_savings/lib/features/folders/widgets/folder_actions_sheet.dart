import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/savings_service.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/icon_resolver.dart';
import '../../analytics/expense_model.dart';
import '../folder_model.dart';

// ── Icon / palette constants (same as create sheet) ──────────────────────────
const _kIcons = [
  ('folder',         Icons.folder_outlined,           'General'),
  ('restaurant',     Icons.restaurant_outlined,        'Food'),
  ('flight',         Icons.flight_takeoff_outlined,    'Travel'),
  ('home',           Icons.home_outlined,              'Home'),
  ('trending_up',    Icons.trending_up,                'Invest'),
  ('sports_esports', Icons.sports_esports_outlined,    'Fun'),
  ('shield',         Icons.shield_outlined,            'Emergency'),
  ('shopping_bag',   Icons.shopping_bag_outlined,      'Shopping'),
  ('local_hospital', Icons.local_hospital_outlined,    'Health'),
  ('other',          Icons.more_horiz_rounded,         'Other'),
];

const _kPalette = [
  0xFF6366F1, 0xFF7C3AED, 0xFF22C55E, 0xFFF59E0B,
  0xFFEC4899, 0xFF06B6D4, 0xFFF43F5E, 0xFFEF4444,
];

const _kCategories = [
  'general', 'food', 'transport', 'shopping',
  'health', 'entertainment', 'education', 'other',
];

class FolderActionsSheet extends ConsumerStatefulWidget {
  final Folder folder;
  const FolderActionsSheet({super.key, required this.folder});

  @override
  ConsumerState<FolderActionsSheet> createState() => _FolderActionsSheetState();
}

class _FolderActionsSheetState extends ConsumerState<FolderActionsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Add Expense tab
  final _amountCtrl = TextEditingController();
  final _labelCtrl  = TextEditingController();
  String _category  = 'general';
  bool _addingExpense = false;
  String? _expenseErr;

  // Edit Folder tab
  late TextEditingController _nameCtrl;
  late TextEditingController _budgetCtrl;
  late int    _editColor;
  late String _editIcon;
  bool _savingEdit = false;
  String? _editErr;

  @override
  void initState() {
    super.initState();
    _tabCtrl   = TabController(length: 3, vsync: this);
    _nameCtrl  = TextEditingController(text: widget.folder.name);
    _budgetCtrl= TextEditingController(text: widget.folder.budget > 0 ? widget.folder.budget.toStringAsFixed(0) : '');
    _editColor = widget.folder.color;
    _editIcon  = widget.folder.icon;
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _amountCtrl.dispose();
    _labelCtrl.dispose();
    _nameCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  // ── Add expense ─────────────────────────────────────────────────────────────
  Future<void> _addExpense() async {
    final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amt <= 0) { setState(() => _expenseErr = 'Enter a valid amount'); return; }
    final label = _labelCtrl.text.trim();
    if (label.isEmpty) { setState(() => _expenseErr = 'Enter a label'); return; }
    if (widget.folder.id == '__temp__') {
      setState(() => _expenseErr = 'Folder is still saving. Try again in a moment.');
      return;
    }

    setState(() { _addingExpense = true; _expenseErr = null; });
    try {
      // POST /api/expenses — this also updates folder.spent on the backend
      await ref.read(expensesProvider.notifier).add(Expense(
        id: '',
        folderId: widget.folder.id,
        amount: amt,
        label: label,
        category: _category,
        date: DateTime.now(),
        daysAgo: 0,
      ));
      // Refresh folders so spent amount updates in UI
      await ref.read(foldersProvider.notifier).refresh();
      HapticFeedback.mediumImpact();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('₹${amt.toStringAsFixed(0)} added to ${widget.folder.name}'),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _expenseErr = e.toString().replaceFirst('Exception: ', '');
        _addingExpense = false;
      });
    }
  }

  // ── Save edit ───────────────────────────────────────────────────────────────
  Future<void> _saveEdit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) { setState(() => _editErr = 'Name is required'); return; }

    setState(() { _savingEdit = true; _editErr = null; });
    try {
      await ref.read(foldersProvider.notifier).update(widget.folder.id, (f) =>
        f.copyWith(
          name: name,
          icon: _editIcon,
          color: _editColor,
          budget: double.tryParse(_budgetCtrl.text.trim()) ?? f.budget,
        ),
      );
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _editErr = 'Failed to save changes.'; _savingEdit = false; });
    }
  }

  // ── Delete ──────────────────────────────────────────────────────────────────
  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete ${widget.folder.name}?',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
          'This will permanently delete this folder and all its expenses. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(foldersProvider.notifier).remove(widget.folder.id);
      if (mounted) Navigator.pop(context);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pc = Color(widget.folder.color);
    final maxH = MediaQuery.of(context).size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: pc.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(iconFromName(widget.folder.icon), color: pc),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.folder.name,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      Text(
                        '₹${widget.folder.spent.toStringAsFixed(0)} spent of ₹${widget.folder.budget.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  onPressed: _delete,
                  tooltip: 'Delete folder',
                ),
              ],
            ),
          ),
          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: widget.folder.progress,
                minHeight: 6,
                backgroundColor: pc.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(
                  widget.folder.progress >= 1 ? Colors.red : pc,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabCtrl,
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Add Expense'),
              Tab(text: 'Edit Folder'),
              Tab(text: 'History'),
            ],
          ),
          Flexible(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildAddExpenseTab(isDark),
                _buildEditTab(isDark),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Add Expense tab ─────────────────────────────────────────────────────────
  Widget _buildAddExpenseTab(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(
            controller: _amountCtrl,
            label: 'Amount',
            prefixText: '₹ ',
            icon: Icons.currency_rupee_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
            error: _expenseErr,
            onChanged: (_) { if (_expenseErr != null) setState(() => _expenseErr = null); },
          ),
          const SizedBox(height: 12),
          _field(
            controller: _labelCtrl,
            label: 'Label',
            icon: Icons.label_outline,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) {},
          ),
          const SizedBox(height: 14),
          Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _kCategories.map((c) {
              final sel = _category == c;
              return GestureDetector(
                onTap: () => setState(() => _category = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppColors.primary : Colors.transparent),
                  ),
                  child: Text(c,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppColors.primary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: _addingExpense ? 'Adding…' : 'Add Expense',
            onPressed: _addingExpense ? null : _addExpense,
          ),
        ],
      ),
    );
  }

  // ── Edit Folder tab ─────────────────────────────────────────────────────────
  Widget _buildEditTab(bool isDark) {
    final pc = Color(_editColor);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(
            controller: _nameCtrl,
            label: 'Folder Name',
            icon: Icons.folder_outlined,
            textCapitalization: TextCapitalization.words,
            error: _editErr,
            onChanged: (_) { if (_editErr != null) setState(() => _editErr = null); },
          ),
          const SizedBox(height: 12),
          _field(
            controller: _budgetCtrl,
            label: 'Monthly Budget',
            prefixText: '₹ ',
            icon: Icons.account_balance_wallet_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          Text('Icon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 8),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _kIcons.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final (key, iconData, label) = _kIcons[i];
                final sel = _editIcon == key;
                return GestureDetector(
                  onTap: () => setState(() => _editIcon = key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 56,
                    decoration: BoxDecoration(
                      color: sel ? pc.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: sel ? pc : Colors.transparent, width: 1.5),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(iconData, color: sel ? pc : Colors.grey, size: 20),
                      const SizedBox(height: 3),
                      Text(label, style: TextStyle(fontSize: 8, color: sel ? pc : Colors.grey)),
                    ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text('Color', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: _kPalette.map((c) {
              final sel = _editColor == c;
              return GestureDetector(
                onTap: () => setState(() => _editColor = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: sel ? 38 : 34, height: sel ? 38 : 34,
                  decoration: BoxDecoration(
                    color: Color(c), shape: BoxShape.circle,
                    border: Border.all(color: sel ? Colors.white : Colors.transparent, width: 2.5),
                    boxShadow: sel ? [BoxShadow(color: Color(c).withValues(alpha: 0.5), blurRadius: 10)] : [],
                  ),
                  child: sel ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: _savingEdit ? 'Saving…' : 'Save Changes',
            onPressed: _savingEdit ? null : _saveEdit,
          ),
        ],
      ),
    );
  }

  // ── History tab ─────────────────────────────────────────────────────────────
  Widget _buildHistoryTab() {
    return Consumer(builder: (context, ref, _) {
      final expenses = ref.watch(expensesProvider);
      return expenses.when(
        data: (all) {
          final folderExpenses = all.where((e) => e.folderId == widget.folder.id).toList();
          if (folderExpenses.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text('No expenses yet', style: TextStyle(color: Colors.grey[500])),
              ]),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: folderExpenses.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final e = folderExpenses[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_outlined, color: AppColors.primary, size: 18),
                ),
                title: Text(e.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(
                  '${e.category}  •  ${e.daysAgo == 0 ? 'Today' : '${e.daysAgo}d ago'}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                trailing: Text(
                  '-₹${e.amount.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Could not load history')),
      );
    });
  }

  // ── Shared input field ──────────────────────────────────────────────────────
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefixText,
    String? error,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        prefixIcon: Icon(icon, size: 20),
        errorText: error,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
