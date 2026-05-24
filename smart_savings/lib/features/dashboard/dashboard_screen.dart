import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_provider.dart';
import '../../services/savings_service.dart';
import '../../shared/widgets/animated_counter.dart';
import '../../shared/widgets/premium_effects.dart';
import '../../shared/widgets/shimmer_box.dart';
import '../../shared/widgets/section_header.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatters.dart';
import '../../utils/icon_resolver.dart';
import '../folders/widgets/add_expense_sheet.dart';
import '../folders/widgets/create_folder_sheet.dart';
import 'dashboard_header.dart';
import 'widgets/balance_editor_sheet.dart';
import 'widgets/health_ring.dart';
import 'widgets/quick_action.dart';
import 'widgets/savings_sparkline.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _openBalanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const BalanceEditorSheet(),
    );
  }

  void _openCreateFolder(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const CreateFolderSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final remaining = ref.watch(remainingBalanceProvider);
    final spent = ref.watch(totalSpentProvider);
    final saved = ref.watch(monthlySavedProvider);
    final allocated = ref.watch(totalBudgetedProvider);
    final balanceVisible = ref.watch(balanceVisibleProvider);
    final score = ref.watch(healthScoreProvider);
    final streak = ref.watch(savingsStreakProvider);
    final folders = ref.watch(foldersProvider);
    final goals = ref.watch(wishlistProvider);
    final insights = ref.watch(smartInsightsProvider);
    final userName = ref.watch(userNameProvider) ?? 'Saver';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PremiumPageBackground(
        preset: OrbPreset.dashboard,
        child: Stack(
          children: [
            // Background gradient blob
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: isDark ? 0.14 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -100,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: isDark ? 0.07 : 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              children: [
                // ── Header ───────────────────────────────────────────────
                DashboardHeader(userName: userName).animate().fadeIn(),
                const SizedBox(height: 20),

                // ── Premium hero area ─────────────────────────────────────
                _BalanceCard(
                  balance: balance,
                  remaining: remaining,
                  allocated: allocated,
                  visible: balanceVisible,
                  onTap: () => _openBalanceSheet(context),
                ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.06),
                const SizedBox(height: 14),
                _BudgetPlannerCard(
                  allocated: allocated,
                  remaining: remaining,
                  spent: spent,
                ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.06),
                const SizedBox(height: 16),

                // ── Stats row ─────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.shield_outlined,
                        iconColor: score >= 70
                            ? const Color(0xFF22C55E)
                            : (score >= 40
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFEF4444)),
                        label: 'Health',
                        value: '$score%',
                        subtitle: score >= 70
                            ? 'Excellent'
                            : (score >= 40 ? 'Steady' : 'Watch out'),
                        ring: HealthRing(score: score),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department_rounded,
                        iconColor: const Color(0xFFF97316),
                        label: 'Streak',
                        value: '$streak',
                        subtitle: '$streak days saving',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.savings_outlined,
                        iconColor: const Color(0xFF22C55E),
                        label: 'Saved',
                        value: Formatters.compact(saved),
                        subtitle: 'This month',
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.06),
                const SizedBox(height: 16),

                // ── Monthly summary ───────────────────────────────────────
                _MonthlySummary(spent: spent, saved: saved)
                    .animate()
                    .fadeIn(delay: 130.ms)
                    .slideY(begin: 0.06),
                const SizedBox(height: 16),

                // ── Counts row ────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                        child: _CountPill(
                      label: 'Folders',
                      value: folders.maybeWhen(
                          data: (v) => v.length, orElse: () => 0),
                      icon: Icons.folder_rounded,
                      color: AppColors.primary,
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _CountPill(
                      label: 'Goals',
                      value: goals.maybeWhen(
                          data: (v) => v.length, orElse: () => 0),
                      icon: Icons.flag_rounded,
                      color: const Color(0xFF22C55E),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _CountPill(
                      label: 'Insights',
                      value: insights.length,
                      icon: Icons.auto_awesome_rounded,
                      color: const Color(0xFFEC4899),
                    )),
                  ],
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.06),
                const SizedBox(height: 20),

                // ── Quick actions ─────────────────────────────────────────
                SectionHeader(title: 'Move faster today'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: QuickAction(
                      icon: Icons.create_new_folder_outlined,
                      label: '+ Folder',
                      onTap: () => _openCreateFolder(context),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: QuickAction(
                      icon: Icons.add_circle_outline,
                      label: '+ Expense',
                      onTap: () => showAddExpenseSheet(context),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: QuickAction(
                      icon: Icons.flag_outlined,
                      label: '+ Goal',
                      onTap: () => context.go('/goals'),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: QuickAction(
                      icon: Icons.auto_awesome_outlined,
                      label: 'AI Coach',
                      onTap: () => context.go('/coach'),
                    )),
                  ],
                ).animate().fadeIn(delay: 170.ms),
                const SizedBox(height: 24),

                // ── Folders preview ───────────────────────────────────────
                SectionHeader(
                  title: 'Smart folders',
                  action: 'See all',
                  onAction: () => context.go('/folders'),
                ),
                const SizedBox(height: 12),
                folders
                    .when(
                      data: (folderList) => SizedBox(
                        height: 152,
                        child: folderList.isEmpty
                            ? _EmptyFolders(
                                onAdd: () => _openCreateFolder(context))
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: folderList.length + 1,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (_, i) {
                                  if (i == folderList.length) {
                                    return _AddFolderCard(
                                        onTap: () =>
                                            _openCreateFolder(context));
                                  }
                                  final f = folderList[i];
                                  final isOver =
                                      f.budget > 0 && f.spent > f.budget;
                                  return Container(
                                    width: 168,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: isOver
                                            ? Colors.red.withValues(alpha: 0.3)
                                            : Color(f.color)
                                                .withValues(alpha: 0.2),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(f.color)
                                              .withValues(alpha: 0.12),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Color(f.color)
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(iconFromName(f.icon),
                                                  color: Color(f.color),
                                                  size: 18),
                                            ),
                                            const Spacer(),
                                            if (isOver)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.red
                                                      .withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: const Text('Over',
                                                    style: TextStyle(
                                                        fontSize: 9,
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(f.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Text(
                                          Formatters.money(f.remaining) +
                                              ' left',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: isOver
                                                  ? Colors.red
                                                  : Colors.grey[600]),
                                        ),
                                        const SizedBox(height: 10),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: LinearProgressIndicator(
                                            value: f.budget > 0
                                                ? (f.spent / f.budget)
                                                    .clamp(0, 1)
                                                : 0,
                                            backgroundColor: Color(f.color)
                                                .withValues(alpha: 0.15),
                                            valueColor: AlwaysStoppedAnimation(
                                                isOver
                                                    ? Colors.red
                                                    : Color(f.color)),
                                            minHeight: 5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      loading: () => const SizedBox(
                        height: 152,
                        child: ShimmerBox(width: double.infinity, height: 152),
                      ),
                      error: (_, __) => SizedBox(
                        height: 60,
                        child: Center(
                          child: Text('Error loading folders',
                              style: TextStyle(color: Colors.red[400])),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 190.ms),
                const SizedBox(height: 24),

                // ── Smart insights ─────────────────────────────────────────
                SectionHeader(title: 'Helpful money insights'),
                const SizedBox(height: 12),
                ...List.generate(
                    insights.length,
                    (i) => _InsightCard(
                          tip: insights[i],
                        )
                            .animate()
                            .fadeIn(delay: (200 + i * 40).ms)
                            .slideY(begin: 0.06)),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ── Balance card ──────────────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final double balance, remaining, allocated;
  final bool visible;
  final VoidCallback onTap;

  const _BalanceCard({
    required this.balance,
    required this.remaining,
    required this.allocated,
    required this.visible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B1B1F), Color(0xFF11131B), Color(0xFF191525)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.52, 1.0],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.34),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
              blurRadius: 42,
              offset: const Offset(0, 24),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -26,
              right: -12,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'My Balance',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: visible
                                  ? const Color(0xFF4ADE80)
                                  : Colors.white.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            visible ? 'Live balance' : 'Private mode',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                visible
                    ? AnimatedMoney(
                        value: remaining,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                        ),
                      )
                    : const Text(
                        '₹ •••••',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _BalanceStat(label: 'Bank', amount: balance, visible: visible),
                    const SizedBox(width: 10),
                    _BalanceStat(
                      label: 'Allocated',
                      amount: allocated,
                      visible: visible,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 52, child: SavingsSparkline()),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      visible ? Icons.edit_outlined : Icons.lock_outline_rounded,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      visible
                          ? 'Tap to manage your balance'
                          : 'Tap to reveal your balance',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetPlannerCard extends StatelessWidget {
  final double allocated;
  final double remaining;
  final double spent;

  const _BudgetPlannerCard({
    required this.allocated,
    required this.remaining,
    required this.spent,
  });

  @override
  Widget build(BuildContext context) {
    final planned = (allocated <= 0 ? spent + remaining : allocated).abs();
    final spendRatio = planned <= 0 ? 0.0 : (spent / planned).clamp(0, 1).toDouble();
    final remainRatio = planned <= 0 ? 0.0 : (remaining / planned).clamp(0, 1).toDouble();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF12131A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Planned expenses',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.money(planned),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${Formatters.money(remaining)} left to budget',
                    style: const TextStyle(
                      color: Color(0xFF86EFAC),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: spendRatio,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Spent ${Formatters.money(spent)} · Remaining ${Formatters.money(remaining)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.22),
                  AppColors.accent.withValues(alpha: 0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 92,
                  height: 92,
                  child: CircularProgressIndicator(
                    value: (spendRatio + remainRatio).clamp(0, 1),
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pie_chart_rounded, color: Colors.white70, size: 18),
                    const SizedBox(height: 6),
                    Text(
                      '${(spendRatio * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Budget',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final double amount;
  final bool visible;

  const _BalanceStat({
    required this.label,
    required this.amount,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            visible ? Formatters.money(amount) : '₹ ••••',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: visible ? -0.3 : 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value, subtitle;
  final Widget? ring;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
    this.ring,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ring ??
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.3),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Monthly summary ───────────────────────────────────────────────────────────
class _MonthlySummary extends StatelessWidget {
  final double spent, saved;
  const _MonthlySummary({required this.spent, required this.saved});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A2E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Color(0xFFEF4444), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  const Text('Spent this month',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ]),
                const SizedBox(height: 6),
                Text(Formatters.money(spent),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4)),
              ],
            ),
          ),
          Container(
              width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.15)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFF22C55E), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('Saved this month',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                  const SizedBox(height: 6),
                  Text(Formatters.money(saved),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: Color(0xFF22C55E))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Count pill ────────────────────────────────────────────────────────────────
class _CountPill extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _CountPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text('$value',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ── Insight card ──────────────────────────────────────────────────────────────
class _InsightCard extends StatelessWidget {
  final String tip;
  const _InsightCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.lightbulb_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(tip, style: const TextStyle(fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

// ── Empty folders ─────────────────────────────────────────────────────────────
class _EmptyFolders extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyFolders({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined, size: 36, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text('No folders yet',
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Add folder card ───────────────────────────────────────────────────────────
class _AddFolderCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddFolderCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            const Text(
              'New\nFolder',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String userName;
  const _Header({required this.userName});

  @override
  Widget build(BuildContext context) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : (hour < 17 ? 'Good afternoon' : 'Good evening');

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        // Menu button
        GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.07),
              ),
            ),
            child: Icon(
              Icons.menu_rounded,
              size: 20,
              color:
                  isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
