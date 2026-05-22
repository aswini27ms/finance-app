import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/savings_service.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../theme/app_colors.dart';
import '../wishlist_model.dart';

class AddWishlistSheet extends ConsumerStatefulWidget {
  const AddWishlistSheet({super.key});
  @override
  ConsumerState<AddWishlistSheet> createState() => _AddWishlistSheetState();
}

class _AddWishlistSheetState extends ConsumerState<AddWishlistSheet> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _dailyCtrl = TextEditingController(text: '200');
  final _monthlyCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _merchantNameCtrl = TextEditingController();
  final _merchantUrlCtrl = TextEditingController();
  String _emoji = '🎁';
  String _category = 'Gadgets';
  String _priority = 'Medium';
  DateTime? _expectedDate;
  bool _isLoading = false;
  String? _error;

  static const _emojis = [
    '🎁', '💻', '🎧', '📱', '🚗', '🏖️', '👟', '⌚', '📚',
    '🎮', '✈️', '🏠', '💎', '🎵', '🍕',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _dailyCtrl.dispose();
    _monthlyCtrl.dispose();
    _imageUrlCtrl.dispose();
    _merchantNameCtrl.dispose();
    _merchantUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a product name');
      return;
    }
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    if (price <= 0) {
      setState(() => _error = 'Please enter a valid price');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final daily = double.tryParse(_dailyCtrl.text) ?? 100;
      await ref.read(wishlistProvider.notifier).add(WishlistItem(
            id: '',
            name: name,
            price: price,
            saved: 0,
            dailySaving: daily,
            monthlySaving: double.tryParse(_monthlyCtrl.text) ?? daily * 30,
            imageEmoji: _emoji,
            imageUrl: _imageUrlCtrl.text.trim(),
            merchantName: _merchantNameCtrl.text.trim(),
            merchantUrl: _merchantUrlCtrl.text.trim(),
            category: _category,
            priority: _priority,
            expectedPurchaseDate:
                _expectedDate ?? DateTime.now().add(Duration(days: (price / daily).ceil())),
          ));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _error = 'Failed to add item. Check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxH = MediaQuery.of(context).size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Fixed header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Add to Wishlist',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Scrollable body ───────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  24, 0, 24, MediaQuery.of(context).viewInsets.bottom + 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji picker
                  Text('Pick an emoji',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _emojis
                        .map((e) => GestureDetector(
                              onTap: () => setState(() => _emoji = e),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _emoji == e
                                      ? AppColors.primary
                                          .withValues(alpha: 0.15)
                                      : theme.colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _emoji == e
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(e,
                                      style:
                                          const TextStyle(fontSize: 22)),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  Text('Category',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Gadgets', 'Travel', 'Fashion', 'Home', 'Education', 'Other']
                        .map((c) => ChoiceChip(
                              selected: _category == c,
                              label: Text(c),
                              onSelected: (_) => setState(() => _category = c),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: _priority,
                    decoration: InputDecoration(
                      labelText: 'Priority level',
                      prefixIcon: const Icon(Icons.priority_high_rounded),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    items: ['Low', 'Medium', 'High']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setState(() => _priority = v ?? _priority),
                  ),
                  const SizedBox(height: 14),

                  // Name
                  TextField(
                    controller: _nameCtrl,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Product name',
                      hintText: 'e.g. iPhone 15, MacBook…',
                      prefixIcon: const Icon(Icons.shopping_bag_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                      errorText: _error,
                    ),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Price
                  TextField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Price',
                      prefixText: '₹ ',
                      prefixIcon: const Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _imageUrlCtrl,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: 'Product image URL',
                      hintText: 'https://...',
                      prefixIcon: const Icon(Icons.image_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 6),
                    title: Text(
                      'Store link (optional)',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Add an Amazon/Flipkart link to open later',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    children: [
                      TextField(
                        controller: _merchantNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Merchant name',
                          hintText: 'Amazon / Flipkart',
                          prefixIcon: const Icon(Icons.storefront_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _merchantUrlCtrl,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          labelText: 'Merchant URL',
                          hintText: 'https://...',
                          prefixIcon: const Icon(Icons.link_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Daily saving
                  TextField(
                    controller: _dailyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Daily saving target',
                      prefixText: '₹ ',
                      prefixIcon: const Icon(Icons.savings_outlined),
                      helperText: 'How much you plan to save each day',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _monthlyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Monthly saving target',
                      prefixText: '₹ ',
                      prefixIcon: const Icon(Icons.calendar_month_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _expectedDate ??
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) setState(() => _expectedDate = picked);
                    },
                    icon: const Icon(Icons.event_outlined),
                    label: Text(_expectedDate == null
                        ? 'Expected purchase date'
                        : 'Expected ${_expectedDate!.day}/${_expectedDate!.month}/${_expectedDate!.year}'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Fixed footer button ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: GradientButton(
              label: _isLoading ? 'Adding…' : 'Add to Wishlist',
              onPressed: _isLoading ? null : _add,
            ),
          ),
        ],
      ),
    );
  }
}
