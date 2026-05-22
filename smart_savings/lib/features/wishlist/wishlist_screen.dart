import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/savings_service.dart';
import '../../shared/components/main_shell.dart';
import '../../shared/widgets/premium_effects.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import 'widgets/add_wishlist_sheet.dart';
import 'wishlist_model.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  void _openAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const AddWishlistSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const ShellBackButton(),
        title: const Text('Goals', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: PremiumPageBackground(
        preset: OrbPreset.goals,
        child: items.when(
          data: (itemList) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _WishlistHero(),
                      const SizedBox(height: 20),
                      if (itemList.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your active goals',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '${itemList.length} items',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      if (itemList.isNotEmpty) const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
              if (itemList.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: _EmptyState(onAdd: () => _openAdd(context)))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                  sliver: SliverList.separated(
                    itemCount: itemList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => _WishCard(item: itemList[i])
                        .animate()
                        .fadeIn(delay: (i * 80).ms)
                        .slideY(begin: 0.1),
                  ),
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text('Could not load goals', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.read(wishlistProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add item', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _WishlistHero extends ConsumerWidget {
  const _WishlistHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(wishlistProvider).maybeWhen(data: (value) => value, orElse: () => <WishlistItem>[]);
    final totalTarget = items.fold<double>(0, (sum, item) => sum + item.price);
    final totalSaved = items.fold<double>(0, (sum, item) => sum + item.saved);

    return PremiumGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'GOAL PLANNER',
              style: TextStyle(
                color: Color(0xFFF9A8D4),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Turn your dream purchases into clear savings goals.',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.15),
          ),
          const SizedBox(height: 10),
          Text(
            'Track each item like a goal, measure progress beautifully, and stay motivated while moving closer to what matters.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.62), height: 1.5),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _StatPill(label: 'Saved', value: Formatters.compact(totalSaved))),
              const SizedBox(width: 12),
              Expanded(child: _StatPill(label: 'Target', value: Formatters.compact(totalTarget))),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return PremiumGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.56))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flag_rounded, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('No goals yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Add gadgets, travel plans, gifts, or anything you want to turn into a visible savings goal.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add your first goal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishCard extends ConsumerWidget {
  final WishlistItem item;
  const _WishCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          useSafeArea: true,
          builder: (_) => _WishlistDetailSheet(item: item),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: item.imageUrl.isEmpty
                        ? Center(child: Text(item.imageEmoji, style: const TextStyle(fontSize: 28)))
                        : Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(item.imageEmoji, style: const TextStyle(fontSize: 28)),
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(Formatters.money(item.price), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _Pill(text: item.category),
                            _Pill(text: '${item.priority} priority'),
                            if (item.merchantName.trim().isNotEmpty) _Pill(text: item.merchantName.trim()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Remove item?'),
                              content: Text('Remove "${item.name}" from your goals?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
                              ],
                            ),
                          ) ??
                          false;
                      if (ok) {
                        await ref.read(wishlistProvider.notifier).remove(item.id);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AnimatedProgressBar(
                value: item.progress,
                color: AppColors.primary,
                height: 8,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${Formatters.money(item.saved)} saved', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  Text(Formatters.percent(item.progress), style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text('Remaining ${Formatters.money(item.remaining)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  if (item.merchantUrl.trim().isNotEmpty)
                    IconButton(
                      tooltip: 'Open link',
                      onPressed: () => _openLink(context, item.merchantUrl),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    ),
                  TextButton.icon(
                    onPressed: () => _showAllocateDialog(context, ref, item),
                    icon: const Icon(Icons.savings_outlined, size: 16),
                    label: const Text('Allocate'),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reach this goal in ${item.daysRemaining} days if you save ${Formatters.money(item.dailySaving)}/day',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllocateDialog(BuildContext context, WidgetRef ref, WishlistItem item) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Allocate to ${item.name}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(ctrl.text.trim()) ?? 0;
              if (amount <= 0) return;
              await ref.read(wishlistProvider.notifier).addSavings(item.id, amount);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${Formatters.money(amount)} allocated to ${item.name}')),
                );
              }
            },
            child: const Text('Allocate'),
          ),
        ],
      ),
    );
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid link')));
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }
}

class _WishlistDetailSheet extends ConsumerWidget {
  final WishlistItem item;
  const _WishlistDetailSheet({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(wishlistProvider).maybeWhen(
          data: (items) {
            for (final candidate in items) {
              if (candidate.id == item.id) return candidate;
            }
            return item;
          },
          orElse: () => item,
        );
    final date = live.estimatedPurchaseDate;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: live.imageUrl.isEmpty
                ? Container(
                    height: 170,
                    decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                    child: Center(child: Text(live.imageEmoji, style: const TextStyle(fontSize: 64))),
                  )
                : Image.network(
                    live.imageUrl,
                    height: 190,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 170,
                      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                      child: Center(child: Text(live.imageEmoji, style: const TextStyle(fontSize: 64))),
                    ),
                  ),
          ),
          const SizedBox(height: 18),
          Text(live.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(text: live.category),
              _Pill(text: '${live.priority} priority'),
              if (live.merchantName.trim().isNotEmpty) _Pill(text: live.merchantName.trim()),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedProgressBar(value: live.progress, color: AppColors.primary, height: 10),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Metric('Target', Formatters.money(live.price)),
              _Metric('Saved', Formatters.money(live.saved)),
              _Metric('Remaining', Formatters.money(live.remaining)),
              _Metric('Progress', Formatters.percent(live.progress)),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_available_outlined, color: AppColors.primary),
            title: Text('At current savings rate, reach this goal in ${live.daysRemaining} days.'),
            subtitle: Text('Estimated date: ${date.day}/${date.month}/${date.year}'),
          ),
          if (live.merchantUrl.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.link_outlined, color: AppColors.primary),
              title: Text(live.merchantName.trim().isEmpty ? 'Open product link' : 'Open on ${live.merchantName.trim()}'),
              subtitle: Text(
                live.merchantUrl.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                tooltip: 'Copy',
                icon: const Icon(Icons.copy_rounded),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: live.merchantUrl.trim()));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied')));
                  }
                },
              ),
              onTap: () async {
                final uri = Uri.tryParse(live.merchantUrl.trim());
                if (uri == null) return;
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
          ],
          FilledButton.icon(
            onPressed: () => _WishCard(item: live)._showAllocateDialog(context, ref, live),
            icon: const Icon(Icons.savings_outlined),
            label: const Text('Allocate funds'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(wishlistProvider.notifier).remove(live.id);
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete goal item'),
          ),
          const SizedBox(height: 18),
          const Text('Goal history', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (live.savingsHistory.isEmpty)
            const Text('No allocations yet', style: TextStyle(color: Colors.grey))
          else
            ...live.savingsHistory.map((h) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(Formatters.money(h.amount)),
                  subtitle: Text('${h.date.day}/${h.date.month}/${h.date.year}'),
                )),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ]),
    );
  }
}
