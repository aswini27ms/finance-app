import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widgets/premium_effects.dart';
import '../../../theme/app_colors.dart';

class QuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  // Optional gradient — if provided, overrides color
  final Gradient? gradient;

  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.gradient,
  });

  @override
  State<QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<QuickAction>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
    _shimmerCtrl.forward(from: 0);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.color ?? AppColors.primary;

    // Choose gradient — custom, or tinted from baseColor
    final iconGradient = widget.gradient ??
        LinearGradient(
          colors: [
            baseColor,
            Color.lerp(baseColor, Colors.purple, 0.35)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
          decoration: BoxDecoration(
            color: isDark
                ? (_pressed ? const Color(0xFF1A2340) : const Color(0xFF121B2E))
                : (_pressed ? Colors.grey.shade50 : Colors.white),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _pressed
                  ? baseColor.withValues(alpha: 0.40)
                  : baseColor.withValues(alpha: 0.14),
              width: _pressed ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withValues(alpha: _pressed ? 0.22 : 0.10),
                blurRadius: _pressed ? 28 : 18,
                offset: const Offset(0, 8),
              ),
              if (isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon container ─────────────────────────────────────
              GradientIconTile(
                icon: widget.icon,
                gradient: iconGradient,
                idleColor: baseColor,
                size: 46,
                iconSize: 21,
                borderRadius: BorderRadius.circular(15),
              ),
              const SizedBox(height: 11),
              // ── Label ──────────────────────────────────────────────
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 160),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: _pressed ? FontWeight.w800 : FontWeight.w700,
                  color: _pressed
                      ? baseColor
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.82)
                          : Colors.black.withValues(alpha: 0.72)),
                  height: 1.2,
                  letterSpacing: -0.1,
                ),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
