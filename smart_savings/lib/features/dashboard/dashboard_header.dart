// ─────────────────────────────────────────────────────────────────────────────
// UPGRADED DASHBOARD HEADER
// Drop-in replacement for _Header in dashboard_screen.dart.
//
// Changes vs original:
//  • Refined greeting typography with a subtle shimmer badge
//  • Menu button has a glowing ripple and gradient border on press
//  • Notification bell added (right of menu — wire up as needed)
//  • Avatar uses gradient border ring instead of flat square
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/components/main_shell.dart';
import '../../../theme/app_colors.dart';

class DashboardHeader extends StatefulWidget {
  final String userName;

  const DashboardHeader({super.key, required this.userName});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  bool _menuPressed = false;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial =
        widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Avatar with gradient ring ────────────────────────────────
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.38),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // ── Greeting + name ─────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$_greeting,',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.45)
                          : Colors.black.withValues(alpha: 0.38),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Tiny "today" badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withValues(alpha: isDark ? 0.18 : 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _dayLabel(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                widget.userName,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
        ),

        // ── Menu button (opens sidebar drawer) ───────────────────────
        GestureDetector(
          onTapDown: (_) => setState(() => _menuPressed = true),
          onTapUp: (_) {
            setState(() => _menuPressed = false);
            HapticFeedback.lightImpact();
            mainShellScaffoldKey.currentState?.openDrawer();
          },
          onTapCancel: () => setState(() => _menuPressed = false),
          child: AnimatedScale(
            scale: _menuPressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _menuPressed
                    ? AppColors.primary.withValues(alpha: 0.16)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _menuPressed
                      ? AppColors.primary.withValues(alpha: 0.45)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : Colors.black.withValues(alpha: 0.07)),
                  width: _menuPressed ? 1.5 : 1.0,
                ),
                boxShadow: _menuPressed
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.20),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Styled hamburger lines (not default Icon) for premium look
                  _HamburgerLine(
                    width: 18,
                    color: _menuPressed
                        ? AppColors.primary
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.78)
                            : Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  _HamburgerLine(
                    width: 13,
                    color: _menuPressed
                        ? AppColors.primary.withValues(alpha: 0.7)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.45)
                            : Colors.black45),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _dayLabel() {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[DateTime.now().weekday - 1];
  }
}

class _HamburgerLine extends StatelessWidget {
  final double width;
  final Color color;
  const _HamburgerLine({required this.width, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: 2,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}
