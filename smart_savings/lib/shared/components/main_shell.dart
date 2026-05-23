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

final GlobalKey<ScaffoldState> mainShellScaffoldKey =
    GlobalKey<ScaffoldState>();
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
      onDrawerChanged: (open) =>
          ref.read(sidebarOpenProvider.notifier).state = open,
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
                accentColor: const Color(0xFF6366F1),
                patternType: _PatternType.grid,
                onTap: () {
                  Navigator.pop(context);
                  showCreateFolderSheet(context);
                },
              ).animate().fadeIn(delay: 40.ms).slideX(begin: -0.04),
              _SidebarAction(
                icon: Icons.add_circle_outline_rounded,
                label: 'Add Expense',
                subtitle: 'Record a transaction',
                accentColor: const Color(0xFFEC4899),
                patternType: _PatternType.dots,
                onTap: () {
                  Navigator.pop(context);
                  showAddExpenseSheet(context);
                },
              ).animate().fadeIn(delay: 70.ms).slideX(begin: -0.04),
              _SidebarAction(
                icon: Icons.flag_rounded,
                label: 'Add Goal Item',
                subtitle: 'Save for something special',
                accentColor: const Color(0xFF22C55E),
                patternType: _PatternType.diagonal,
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
                accentColor: const Color(0xFFF59E0B),
                patternType: _PatternType.chevron,
                onTap: () {
                  Navigator.pop(context);
                  context.go('/coach');
                },
              ).animate().fadeIn(delay: 130.ms).slideX(begin: -0.04),
              const SizedBox(height: 6),
              _SidebarDivider(),
              _SectionLabel('Navigate'),
              const SizedBox(height: 4),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _NavItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        path: '/dashboard',
                      ),
                      _NavItem(
                        icon: Icons.folder_rounded,
                        label: 'Folders',
                        path: '/folders',
                      ),
                      _NavItem(
                        icon: Icons.receipt_long_rounded,
                        label: 'Transactions',
                        path: '/transactions',
                      ),
                      _NavItem(
                        icon: Icons.flag_rounded,
                        label: 'Goals',
                        path: '/goals',
                      ),
                      _NavItem(
                        icon: Icons.bar_chart_rounded,
                        label: 'Analytics',
                        path: '/analytics',
                      ),
                      _NavItem(
                        icon: Icons.auto_awesome_rounded,
                        label: 'AI Coach',
                        path: '/coach',
                      ),
                      _NavItem(
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        path: '/profile',
                      ),
                      _NavItem(
                        icon: Icons.settings_rounded,
                        label: 'Settings',
                        path: '/settings',
                      ),
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

// ── Sidebar Shell with geometric pattern background ───────────────────────────
class _SidebarShell extends StatelessWidget {
  final Widget child;
  const _SidebarShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF070D1A),
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
            // Geometric grid pattern background
            Positioned.fill(
              child: CustomPaint(painter: _GeometricPatternPainter()),
            ),
            // Top accent bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF7C3AED),
                      Color(0xFFEC4899),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(38),
                  ),
                ),
              ),
            ),
            // Right edge accent line
            Positioned(
              top: 60,
              right: 0,
              bottom: 60,
              child: Container(
                width: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF6366F1).withValues(alpha: 0.3),
                      const Color(0xFFEC4899).withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Geometric dot-grid pattern painter ───────────────────────────────────────
class _GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..style = PaintingStyle.fill;
    const spacing = 28.0;
    const dotRadius = 1.0;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        final distFromTop = y / size.height;
        final distFromRight = x / size.width;
        final opacity = (0.06 + distFromRight * 0.04) * (1 - distFromTop * 0.5);
        dotPaint.color = Colors.white.withValues(
          alpha: opacity.clamp(0.0, 1.0),
        );
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }

    // Draw diagonal accent lines in top-right area
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 5; i++) {
      final startX = size.width * 0.6 + i * 18.0;
      linePaint.color = const Color(
        0xFF6366F1,
      ).withValues(alpha: 0.06 - i * 0.01);
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX - 120, size.height * 0.4),
        linePaint,
      );
    }

    // Corner bracket decoration top-right
    final bracketPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFF6366F1).withValues(alpha: 0.15);

    final path = Path()
      ..moveTo(size.width - 40, 60)
      ..lineTo(size.width - 10, 60)
      ..lineTo(size.width - 10, 90);
    canvas.drawPath(path, bracketPaint);

    final path2 = Path()
      ..moveTo(size.width - 40, size.height - 60)
      ..lineTo(size.width - 10, size.height - 60)
      ..lineTo(size.width - 10, size.height - 90);
    canvas.drawPath(path2, bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Pattern types for action cards ───────────────────────────────────────────
enum _PatternType { grid, dots, diagonal, chevron }

// ── Sidebar Header ────────────────────────────────────────────────────────────
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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar with geometric border
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF070D1A),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.32),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white38,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.07)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniBalanceCard(
                    label: 'BALANCE',
                    value: visible ? Formatters.money(balance) : '₹ ••••',
                    icon: Icons.account_balance_wallet_rounded,
                    accentColor: const Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniBalanceCard(
                    label: 'AVAILABLE',
                    value: visible ? Formatters.money(remaining) : '₹ ••••',
                    icon: Icons.wallet_outlined,
                    accentColor: const Color(0xFF22C55E),
                    highlight: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 280.ms).slideX(begin: -0.05);
  }
}

class _MiniBalanceCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color accentColor;
  final bool highlight;

  const _MiniBalanceCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: highlight ? 0.10 : 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: highlight ? 0.25 : 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 16),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
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
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
    child: Row(
      children: [
        Container(
          width: 14,
          height: 1.5,
          color: const Color(0xFF6366F1).withValues(alpha: 0.6),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.32),
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
          ),
        ),
      ],
    ),
  );
}

// ── Action card with subtle geometric pattern ─────────────────────────────────
class _SidebarAction extends StatefulWidget {
  final IconData icon;
  final String label, subtitle;
  final Color accentColor;
  final _PatternType patternType;
  final VoidCallback onTap;

  const _SidebarAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accentColor,
    required this.patternType,
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
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 3, 14, 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _pressed
                ? widget.accentColor.withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _pressed
                  ? widget.accentColor.withValues(alpha: 0.30)
                  : Colors.white.withValues(alpha: 0.07),
            ),
          ),
          child: Stack(
            children: [
              // Geometric pattern in background
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 80,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: CustomPaint(
                    painter: _ActionPatternPainter(
                      color: widget.accentColor,
                      type: widget.patternType,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.accentColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.accentColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.36),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: widget.accentColor.withValues(alpha: 0.5),
                    size: 11,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pattern painter for action cards ─────────────────────────────────────────
class _ActionPatternPainter extends CustomPainter {
  final Color color;
  final _PatternType type;

  const _ActionPatternPainter({required this.color, required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    switch (type) {
      case _PatternType.grid:
        for (double x = 0; x < size.width; x += 12) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        for (double y = 0; y < size.height; y += 12) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        break;
      case _PatternType.dots:
        paint.style = PaintingStyle.fill;
        paint.color = color.withValues(alpha: 0.12);
        for (double x = 8; x < size.width; x += 12) {
          for (double y = 8; y < size.height; y += 12) {
            canvas.drawCircle(Offset(x, y), 1.2, paint);
          }
        }
        break;
      case _PatternType.diagonal:
        for (double i = -size.height; i < size.width + size.height; i += 14) {
          canvas.drawLine(
            Offset(i, 0),
            Offset(i + size.height, size.height),
            paint,
          );
        }
        break;
      case _PatternType.chevron:
        for (double y = 0; y < size.height + 20; y += 14) {
          final path = Path()
            ..moveTo(0, y)
            ..lineTo(size.width / 2, y - 10)
            ..lineTo(size.width, y);
          canvas.drawPath(path, paint);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ActionPatternPainter old) =>
      old.color != color || old.type != type;
}

// ── Nav Item ──────────────────────────────────────────────────────────────────
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
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.fromLTRB(14, 2, 14, 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: current
              ? const Color(0xFF6366F1).withValues(alpha: 0.12)
              : (_pressed
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.transparent),
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(
              color: current ? const Color(0xFF6366F1) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: current
                    ? const Color(0xFF6366F1).withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: current
                      ? const Color(0xFF6366F1).withValues(alpha: 0.35)
                      : Colors.transparent,
                ),
              ),
              child: Icon(
                widget.icon,
                color: current
                    ? const Color(0xFF6366F1)
                    : Colors.white.withValues(alpha: 0.40),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: current
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                  fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            if (current)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.30),
                  ),
                ),
                child: const Text(
                  '●',
                  style: TextStyle(color: Color(0xFF6366F1), fontSize: 6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Logout tile ───────────────────────────────────────────────────────────────
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(
            0xFFEF4444,
          ).withValues(alpha: _pressed ? 0.14 : 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(
              0xFFEF4444,
            ).withValues(alpha: _pressed ? 0.35 : 0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEF4444),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Log out',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 11,
              color: const Color(0xFFEF4444).withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────
class _SidebarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ),
    ),
  );
}
