import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_provider.dart';
import '../../services/savings_service.dart';
import '../../shared/components/main_shell.dart';
import '../../shared/widgets/premium_effects.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../dashboard/widgets/balance_editor_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final remaining = ref.watch(remainingBalanceProvider);
    final spent = ref.watch(totalSpentProvider);
    final allocated = ref.watch(totalBudgetedProvider);
    final visible = ref.watch(balanceVisibleProvider);
    final streak = ref.watch(savingsStreakProvider);
    final score = ref.watch(healthScoreProvider);
    final userName = ref.watch(userNameProvider) ?? 'User';
    final userEmail = ref.watch(userEmailProvider) ?? '';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(
        leading: const ShellBackButton(),
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: PremiumPageBackground(
        child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: Text(initial,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
              child: Text(userName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700))),
          Center(
              child:
                  Text(userEmail, style: const TextStyle(color: Colors.grey))),
          const SizedBox(height: 24),
          const Text('Financial Summary',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _SummaryRow(
                  'Bank balance',
                  visible ? Formatters.money(balance) : '₹ •••••',
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
                _SummaryRow('Folder allocations',
                    visible ? Formatters.money(allocated) : '₹ ••••'),
                _SummaryRow('Available to spend',
                    visible ? Formatters.money(remaining) : '₹ •••••'),
                const Divider(color: Colors.white24, height: 20),
                _SummaryRow('Total spent', Formatters.money(spent)),
                _SummaryRow('Health score', '$score%'),
                _SummaryRow('Saving streak', '$streak days'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _InfoTile(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Monthly income',
              value: visible ? Formatters.money(balance) : '₹ •••••'),
          _InfoTile(
              icon: Icons.savings_outlined,
              label: 'Saving goal',
              value: 'Build ${Formatters.compact(remaining)} buffer'),
          const SizedBox(height: 12),
          _Item(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => context.push('/settings')),
          _Item(
              icon: Icons.bar_chart_outlined,
              label: 'Analytics',
              onTap: () => context.go('/analytics')),
          _Item(
              icon: Icons.flag_outlined,
              label: 'Goals',
              onTap: () => context.go('/goals')),
          _Item(
              icon: Icons.logout,
              label: 'Log out',
              danger: true,
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }),
        ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final VoidCallback? onTap;
  const _SummaryRow(this.label, this.value, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13)),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.lock_outline_rounded,
                      size: 14, color: Colors.white70),
                ],
              ],
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: value.contains('•') ? 1.2 : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _Item(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: danger ? Colors.red : null),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: danger ? Colors.red : null)),
        trailing: const Icon(Icons.chevron_right_rounded),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
