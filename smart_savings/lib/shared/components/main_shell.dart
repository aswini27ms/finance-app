import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/folders/widgets/add_expense_sheet.dart';
import '../../features/folders/widgets/create_folder_sheet.dart';
import '../../features/wishlist/widgets/add_wishlist_sheet.dart';
import '../../shared/widgets/premium_effects.dart';
import '../../services/auth_provider.dart';
import '../../services/savings_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';

final GlobalKey<ScaffoldState> mainShellScaffoldKey = GlobalKey<ScaffoldState>();
final sidebarOpenProvider = StateProvider<bool>((ref) => false);

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      key: mainShellScaffoldKey,
      extendBody: false,
      drawer: const _PremiumSidebar(),
      onDrawerChanged: (open) => ref.read(sidebarOpenProvider.notifier).state = open,
      body: PremiumPageBackground(child: child),
    );
  }
}

class SidebarMenuButton extends StatelessWidget {
  final Color? color;
  final Color? backgroundColor;

  const SidebarMenuButton({super.key, this.color, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => mainShellScaffoldKey.currentState?.openDrawer(),
      child: GradientIconTile(
        icon: Icons.menu_rounded,
        size: 40,
        iconSize: 20,
        margin: const EdgeInsets.only(left: 8),
        borderRadius: BorderRadius.circular(12),
        idleColor: color ?? (isDark ? Colors.white : AppColors.primary),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => mainShellScaffoldKey.currentState?.openDrawer(),
      ),
    );
  }
}

class ShellBackButton extends StatelessWidget {
  final String fallbackRoute;
  final Color? color;
  final Color? backgroundColor;

  const ShellBackButton({
    super.key,
    this.fallbackRoute = '/dashboard',
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
        } else {
          context.go(fallbackRoute);
        }
      },
      child: GradientIconTile(
        icon: Icons.arrow_back_ios_new_rounded,
        size: 40,
        iconSize: 17,
        margin: const EdgeInsets.only(left: 8),
        borderRadius: BorderRadius.circular(12),
        idleColor: color ?? (isDark ? Colors.white : AppColors.primary),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
          } else {
            context.go(fallbackRoute);
          }
        },
      ),
    );
  }
}

class _PremiumSidebar extends ConsumerWidget {
  const _PremiumSidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider) ?? 'User';
    final userEmail = ref.watch(userEmailProvider) ?? '';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    final balance = ref.watch(balanceProvider);
    final remaining = ref.watch(remainingBalanceProvider);
    final visible = ref.watch(balanceVisibleProvider);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.86,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: _SidebarShell(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SidebarHeader(
                initial: initial,
                name: userName,
                email: userEmail,
                balance: balance,
                remaining: remaining,
                visible: visible,
              ),
              _SidebarDivider(),
              _SectionLabel('Quick Actions'),
              const SizedBox(height: 4),
              _SidebarAction(
                icon: Icons.create_new_folder_rounded,
                label: 'Create Folder',
                subtitle: 'Add an expense bucket',
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF7C3AED)]),
                glowColor: const Color(0xFF7C3AED),
                onTap: () {
                  Navigator.pop(context);
                  showCreateFolderSheet(context);
                },
              ).animate().fadeIn(delay: 40.ms).slideX(begin: -0.04),
              _SidebarAction(
                icon: Icons.add_circle_outline_rounded,
                label: 'Add Expense',
                subtitle: 'Record a transaction',
                gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFF43F5E)]),
                glowColor: const Color(0xFFEC4899),
                onTap: () {
                  Navigator.pop(context);
                  showAddExpenseSheet(context);
                },
              ).animate().fadeIn(delay: 70.ms).slideX(begin: -0.04),
              _SidebarAction(
                icon: Icons.flag_rounded,
                label: 'Add Goal Item',
                subtitle: 'Save for something special',
                gradient: const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF06B6D4)]),
                glowColor: const Color(0xFF22C55E),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    useSafeArea: true,
                    builder: (_) => const AddWishlistSheet(),
                  );
                },
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.04),
              _SidebarAction(
                icon: Icons.auto_awesome_rounded,
                label: 'AI Coach',
                subtitle: 'Smart financial advice',
                gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEC4899)]),
                glowColor: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/coach');
                },
              ).animate().fadeIn(delay: 130.ms).slideX(begin: -0.04),
              const SizedBox(height: 6),
              _SidebarDivider(),
              _SectionLabel('Navigate'),
              const SizedBox(height: 4),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: const [
                      _NavItem(icon: Icons.home_rounded, label: 'Home', path: '/dashboard'),
                      _NavItem(icon: Icons.folder_rounded, label: 'Folders', path: '/folders'),
                      _NavItem(icon: Icons.receipt_long_rounded, label: 'Transactions', path: '/transactions'),
                      _NavItem(icon: Icons.flag_rounded, label: 'Goals', path: '/goals'),
                      _NavItem(icon: Icons.bar_chart_rounded, label: 'Analytics', path: '/analytics'),
                      _NavItem(icon: Icons.auto_awesome_rounded, label: 'AI Coach', path: '/coach'),
                      _NavItem(icon: Icons.person_rounded, label: 'Profile', path: '/profile'),
                      _NavItem(icon: Icons.settings_rounded, label: 'Settings', path: '/settings'),
                    ],
                  ),
                ),
              ),
              _SidebarDivider(),
              const SizedBox(height: 8),
              _LogoutTile(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarShell extends StatelessWidget {
  final Widget child;
  const _SidebarShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF040914), Color(0xFF0A1325), Color(0xFF0D1A30), Color(0xFF0F1E3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.28, 0.65, 1.0],
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.03),
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(top: -90, right: -90, child: _AnimatedGlowOrb(size: 280, color: AppColors.primary, opacity: 0.20, durationMs: 4200)),
            Positioned(bottom: 40, left: -70, child: _AnimatedGlowOrb(size: 220, color: const Color(0xFF06B6D4), opacity: 0.10, durationMs: 5000)),
            Positioned(top: 260, right: -20, child: _AnimatedGlowOrb(size: 160, color: const Color(0xFFEC4899), opacity: 0.08, durationMs: 3600)),
            Positioned(
              top: 120,
              right: -12,
              child: Container(
                width: 90,
                height: 260,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(duration: 2200.ms, begin: 0.18, end: 0.04),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _SidebarSparklePainter(),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _AnimatedGlowOrb extends StatefulWidget {
  final double size;
  final Color color;
  final double opacity;
  final int durationMs;

  const _AnimatedGlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
    required this.durationMs,
  });

  @override
  State<_AnimatedGlowOrb> createState() => _AnimatedGlowOrbState();
}

class _AnimatedGlowOrbState extends State<_AnimatedGlowOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: widget.durationMs))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.94 + (_controller.value * 0.12);
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [widget.color.withValues(alpha: widget.opacity), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _SidebarSparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final sparkles = <Offset>[
      Offset(size.width * 0.82, size.height * 0.14),
      Offset(size.width * 0.74, size.height * 0.26),
      Offset(size.width * 0.88, size.height * 0.42),
      Offset(size.width * 0.78, size.height * 0.72),
      Offset(size.width * 0.66, size.height * 0.84),
    ];
    final colors = [AppColors.primary, AppColors.accent, const Color(0xFFEC4899), Colors.white];

    for (var i = 0; i < sparkles.length; i++) {
      paint.color = colors[i % colors.length].withValues(alpha: i == 3 ? 0.22 : 0.16);
      canvas.drawCircle(sparkles[i], i == 3 ? 2.6 : 2.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SidebarHeader extends StatelessWidget {
  final String initial, name, email;
  final double balance, remaining;
  final bool visible;

  const _SidebarHeader({
    required this.initial,
    required this.name,
    required this.email,
    required this.balance,
    required this.remaining,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.55),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF07101F), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11, letterSpacing: 0.3),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            name,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white38, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.white.withValues(alpha: 0.10), Colors.transparent],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MiniBalanceCard(
                        label: 'BALANCE',
                        value: visible ? Formatters.money(balance) : '₹ ••••',
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: const Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniBalanceCard(
                        label: 'AVAILABLE',
                        value: visible ? Formatters.money(remaining) : '₹ ••••',
                        icon: Icons.wallet_outlined,
                        iconColor: const Color(0xFF22C55E),
                        highlight: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 280.ms).slideX(begin: -0.05);
  }
}

class _MiniBalanceCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color iconColor;
  final bool highlight;

  const _MiniBalanceCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: highlight ? 0.09 : 0.05),
            Colors.white.withValues(alpha: highlight ? 0.04 : 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlight ? iconColor.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: highlight ? 0.14 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.20),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 1.4),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: -0.3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 1.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.65), Colors.transparent],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              text.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.34),
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
              ),
            ),
          ],
        ),
      );
}

class _SidebarAction extends StatefulWidget {
  final IconData icon;
  final String label, subtitle;
  final LinearGradient gradient;
  final Color glowColor;
  final VoidCallback onTap;

  const _SidebarAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<_SidebarAction> createState() => _SidebarActionState();
}

class _SidebarActionState extends State<_SidebarAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 4, 14, 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: _pressed ? 0.08 : 0.05),
                Colors.white.withValues(alpha: _pressed ? 0.05 : 0.025),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: _pressed ? 0.14 : 0.08)),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: _pressed ? 0.24 : 0.12),
                blurRadius: _pressed ? 24 : 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                top: -10,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [widget.glowColor.withValues(alpha: 0.14), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: widget.gradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: widget.glowColor.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 19),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(color: Colors.white, fontSize: 13.2, fontWeight: FontWeight.w700, letterSpacing: -0.1),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          widget.subtitle,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.22), size: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label, path;
  const _NavItem({required this.icon, required this.label, required this.path});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final current = GoRouterState.of(context).uri.path.startsWith(widget.path);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        Navigator.pop(context);
        context.go(widget.path);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.fromLTRB(14, 3, 14, 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: current
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.18),
                    AppColors.primaryAlt.withValues(alpha: 0.09),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: current ? null : (_pressed ? Colors.white.withValues(alpha: 0.05) : Colors.transparent),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: current ? AppColors.primary.withValues(alpha: 0.35) : Colors.transparent,
          ),
          boxShadow: current
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.20),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: current
                    ? const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: current ? null : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(11),
                boxShadow: current
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.28),
                          blurRadius: 18,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                widget.icon,
                color: current ? Colors.white : Colors.white.withValues(alpha: 0.42),
                size: 17,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: current ? Colors.white : Colors.white.withValues(alpha: 0.58),
                  fontSize: 13.5,
                  fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            if (current)
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LogoutTile extends ConsumerStatefulWidget {
  @override
  ConsumerState<_LogoutTile> createState() => _LogoutTileState();
}

class _LogoutTileState extends ConsumerState<_LogoutTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) async {
        setState(() => _pressed = false);
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) context.go('/login');
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        margin: const EdgeInsets.fromLTRB(14, 4, 14, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEF4444).withValues(alpha: _pressed ? 0.18 : 0.10),
              const Color(0xFFEF4444).withValues(alpha: _pressed ? 0.10 : 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: _pressed ? 0.35 : 0.20),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 17),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Log out',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: const Color(0xFFEF4444).withValues(alpha: 0.45)),
          ],
        ),
      ),
    );
  }
}

class _SidebarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.primary.withValues(alpha: 0.16),
              Colors.white.withValues(alpha: 0.10),
              Colors.transparent,
            ],
          ),
        ),
      );
}
