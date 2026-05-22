import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/savings_service.dart';
import '../../shared/components/main_shell.dart';
import '../../shared/widgets/premium_effects.dart';
import '../../shared/widgets/shimmer_box.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatters.dart';
import '../../utils/icon_resolver.dart';
import 'folder_model.dart';
import 'widgets/create_folder_sheet.dart';
import 'widgets/folder_actions_sheet.dart';

class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  void _openCreate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateFolderSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(foldersProvider);
    final totalBudget = ref.watch(totalBudgetedProvider);
    final totalSpent = ref.watch(totalSpentProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const ShellBackButton(),
        title: const Text('Folders', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: PremiumPageBackground(
        child: folders.when(
          data: (folderList) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _PageHero(
                        title: 'Organize every expense with cleaner budget folders.',
                        subtitle:
                            'Keep your money sorted into focused buckets so spending feels calm, visible, and easy to manage.',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _TopStatCard(
                              label: 'Total budgeted',
                              value: Formatters.money(totalBudget),
                              accent: AppColors.primary,
                              icon: Icons.account_balance_wallet_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TopStatCard(
                              label: 'Total spent',
                              value: Formatters.money(totalSpent),
                              accent: const Color(0xFFEF4444),
                              icon: Icons.arrow_upward_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (folderList.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your active folders',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '${folderList.length} total',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      if (folderList.isNotEmpty) const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
              if (folderList.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(onAdd: () => _openCreate(context)),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                  sliver: SliverList.separated(
                    itemCount: folderList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _FolderTile(folder: folderList[i])
                        .animate()
                        .fadeIn(delay: (i * 60).ms)
                        .slideY(begin: 0.1),
                  ),
                ),
            ],
          ),
          loading: () => const ShimmerList(),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text('Could not load folders', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.read(foldersProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New folder', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _PageHero extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PageHero({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return PremiumGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'SMART BUDGETING',
              style: TextStyle(
                color: AppColors.primaryAlt,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.7),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.62), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _TopStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  const _TopStatCard({required this.label, required this.value, required this.accent, required this.icon});

  @override
  Widget build(BuildContext context) {
    return PremiumGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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
              child: const Icon(Icons.folder_open_outlined, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('No folders yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Create folders to organise groceries, rent, travel, shopping, and every other expense with a cleaner system.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create your first folder'),
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

class _FolderTile extends ConsumerWidget {
  final Folder folder;
  const _FolderTile({required this.folder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverBudget = folder.budget > 0 && folder.spent > folder.budget;

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => FolderActionsSheet(folder: folder),
      ),
      child: PremiumGlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Color(folder.color).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(iconFromName(folder.icon), color: Color(folder.color)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          folder.name,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.money(folder.remaining),
                        style: TextStyle(fontWeight: FontWeight.w800, color: isOverBudget ? Colors.red : null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOverBudget ? 'Budget exceeded' : 'Budget tracking active',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverBudget ? Colors.red[300] : Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedProgressBar(
                    value: folder.progress,
                    color: isOverBudget ? Colors.red : Color(folder.color),
                    height: 8,
                    backgroundColor: Color(folder.color).withValues(alpha: 0.12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${Formatters.money(folder.spent)} spent', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('of ${Formatters.money(folder.budget)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.35)),
          ],
        ),
      ),
    );
  }
}
