import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_provider.dart';
import '../../services/local_storage_service.dart';
import '../../services/savings_service.dart';
import '../../shared/components/main_shell.dart';
import '../../shared/widgets/premium_effects.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PremiumPageBackground(
        child: CustomScrollView(
          slivers: [
          // ── Beautiful header ─────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: const ShellBackButton(fallbackRoute: '/profile'),
            actions: const [SidebarMenuButton()],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.settings_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Settings',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.5),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: isDark ? 0.14 : 0.07),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Appearance ───────────────────────────────────────────
                _SectionTitle('Appearance').animate().fadeIn(delay: 50.ms),
                const SizedBox(height: 10),
                _ThemeSelector(mode: mode, ref: ref)
                    .animate()
                    .fadeIn(delay: 80.ms)
                    .slideY(begin: 0.06),
                const SizedBox(height: 24),

                // ── Notifications ─────────────────────────────────────────
                _SectionTitle('Notifications').animate().fadeIn(delay: 110.ms),
                const SizedBox(height: 10),
                _SettingsCard(
                  children: [
                    _ToggleTile(
                      icon: Icons.notifications_active_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Budget alerts',
                      subtitle: 'Notify when a folder hits 80%',
                      value: true,
                      onChanged: (_) {},
                    ),
                    _CardDivider(),
                    _ToggleTile(
                      icon: Icons.calendar_month_rounded,
                      iconColor: AppColors.primary,
                      title: 'Weekly summary',
                      subtitle: 'Savings report every Sunday',
                      value: true,
                      onChanged: (_) {},
                    ),
                    _CardDivider(),
                    _ToggleTile(
                      icon: Icons.campaign_rounded,
                      iconColor: const Color(0xFF94A3B8),
                      title: 'Promotional tips',
                      subtitle: 'Money-saving ideas & offers',
                      value: false,
                      onChanged: (_) {},
                    ),
                  ],
                ).animate().fadeIn(delay: 130.ms).slideY(begin: 0.06),
                const SizedBox(height: 24),

                // ── Preferences ───────────────────────────────────────────
                _SectionTitle('Preferences').animate().fadeIn(delay: 160.ms),
                const SizedBox(height: 10),
                _SettingsCard(
                  children: [
                    _InfoTile(
                      icon: Icons.currency_rupee_rounded,
                      iconColor: const Color(0xFF22C55E),
                      title: 'Currency',
                      trailing: _Badge('INR ₹'),
                    ),
                    _CardDivider(),
                    _ActionTile(
                      icon: Icons.fingerprint_rounded,
                      iconColor: const Color(0xFF6366F1),
                      title: 'App lock',
                      subtitle: 'Use biometric or device PIN',
                      onTap: () {},
                    ),
                    _CardDivider(),
                    _InfoTile(
                      icon: Icons.language_rounded,
                      iconColor: const Color(0xFF06B6D4),
                      title: 'Language',
                      trailing: _Badge('English'),
                    ),
                  ],
                ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.06),
                const SizedBox(height: 24),

                // ── Security ──────────────────────────────────────────────
                _SectionTitle('Security').animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 10),
                _SettingsCard(
                  children: [
                    _ActionTile(
                      icon: Icons.lock_reset_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Change PIN',
                      subtitle: 'Update your balance lock PIN',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN change coming soon')),
                      ),
                    ),
                    _CardDivider(),
                    _ActionTile(
                      icon: Icons.history_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Login history',
                      subtitle: 'View recent sessions',
                      onTap: () {},
                    ),
                  ],
                ).animate().fadeIn(delay: 220.ms).slideY(begin: 0.06),
                const SizedBox(height: 24),

                // ── Account ───────────────────────────────────────────────
                _SectionTitle('Account').animate().fadeIn(delay: 240.ms),
                const SizedBox(height: 10),
                _SettingsCard(
                  children: [
                    _ActionTile(
                      icon: Icons.delete_sweep_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Reset local data',
                      subtitle: 'Clear offline cache only',
                      onTap: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => _ConfirmDialog(
                            title: 'Reset local data?',
                            body:
                                'Clears locally cached folders and expenses. Server data is unchanged.',
                            confirmLabel: 'Reset',
                            confirmColor: const Color(0xFFF59E0B),
                          ),
                        );
                        if (ok == true) {
                          await LocalStorageService.clearAll();
                          ref.invalidate(foldersProvider);
                          ref.invalidate(expensesProvider);
                          ref.invalidate(incomesProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Local data cleared')),
                            );
                          }
                        }
                      },
                    ),
                    _CardDivider(),
                    _ActionTile(
                      icon: Icons.logout_rounded,
                      iconColor: const Color(0xFFEF4444),
                      title: 'Log out',
                      subtitle: 'Sign out of your account',
                      danger: true,
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => _ConfirmDialog(
                            title: 'Log out?',
                            body:
                                'You\'ll need to sign in again to access your savings.',
                            confirmLabel: 'Log out',
                            confirmColor: const Color(0xFFEF4444),
                          ),
                        );
                        if (ok == true) {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) context.go('/login');
                        }
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.06),
                const SizedBox(height: 24),

                // ── App info ──────────────────────────────────────────────
                _AppInfoFooter().animate().fadeIn(delay: 300.ms),
              ]),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

// ── Theme selector ────────────────────────────────────────────────────────────
class _ThemeSelector extends StatelessWidget {
  final ThemeMode mode;
  final WidgetRef ref;
  const _ThemeSelector({required this.mode, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final options = [
      (mode: ThemeMode.light, icon: Icons.light_mode_rounded, label: 'Light'),
      (mode: ThemeMode.dark, icon: Icons.dark_mode_rounded, label: 'Dark'),
      (
        mode: ThemeMode.system,
        icon: Icons.brightness_auto_rounded,
        label: 'System'
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: options.map((opt) {
          final selected = mode == opt.mode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(themeModeProvider.notifier).set(opt.mode);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Icon(
                      opt.icon,
                      size: 22,
                      color: selected
                          ? Colors.white
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.4)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      opt.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.45)
                                : Colors.black.withValues(alpha: 0.45)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Settings card wrapper ─────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A2E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
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
      child: Column(children: children),
    );
  }
}

// ── Toggle tile ───────────────────────────────────────────────────────────────
class _ToggleTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_ToggleTile> createState() => _ToggleTileState();
}

class _ToggleTileState extends State<_ToggleTile> {
  late bool _val;

  @override
  void initState() {
    super.initState();
    _val = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _IconBox(icon: widget.icon, color: widget.iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(widget.subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Switch.adaptive(
            value: _val,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _val = v);
              widget.onChanged(v);
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ── Action tile ───────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool danger;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.danger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _IconBox(icon: icon, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: danger ? const Color(0xFFEF4444) : null,
                    ),
                  ),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info tile (no action) ─────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget trailing;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _IconBox(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ── Icon box ──────────────────────────────────────────────────────────────────
class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: color, size: 19),
    );
  }
}

// ── Badge widget ──────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Card divider ──────────────────────────────────────────────────────────────
class _CardDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 68,
      endIndent: 16,
      color: Colors.grey.withValues(alpha: 0.12),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Colors.grey,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ── App info footer ───────────────────────────────────────────────────────────
class _AppInfoFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.savings_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Smart Savings',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0 · Built with ❤️',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confirm dialog ────────────────────────────────────────────────────────────
class _ConfirmDialog extends StatelessWidget {
  final String title, body, confirmLabel;
  final Color confirmColor;

  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Text(body, style: const TextStyle(color: Colors.grey)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel,
              style:
                  TextStyle(color: confirmColor, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
