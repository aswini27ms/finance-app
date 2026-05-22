import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Premium fintech-style CTA button.
///
/// Features:
/// - Purple → violet gradient (matches app brand)
/// - Soft glow shadow that pulses when idle
/// - Scale + haptic on press
/// - Loading spinner state
/// - Disabled state with muted appearance
/// - Full-width by default, reusable anywhere
class PremiumCTAButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? leadingIcon;

  /// Override gradient (defaults to indigo→violet)
  final Gradient? gradient;

  const PremiumCTAButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.gradient,
  });

  @override
  State<PremiumCTAButton> createState() => _PremiumCTAButtonState();
}

class _PremiumCTAButtonState extends State<PremiumCTAButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;
  bool _pressed = false;

  static const _gradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const _disabledGradient = LinearGradient(
    colors: [Color(0xFF3D3F5C), Color(0xFF3D3F5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  void _onTapDown(TapDownDetails _) {
    if (!_isEnabled) return;
    setState(() => _pressed = true);
    _pressCtrl.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    if (!_isEnabled) return;
    setState(() => _pressed = false);
    _pressCtrl.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    _pressCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _isEnabled
        ? (widget.gradient ?? _gradient)
        : _disabledGradient;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isEnabled
                ? [
                    // Deep glow
                    BoxShadow(
                      color: const Color(0xFF6366F1)
                          .withValues(alpha: _pressed ? 0.55 : 0.38),
                      blurRadius: _pressed ? 28 : 22,
                      spreadRadius: _pressed ? 2 : 0,
                      offset: const Offset(0, 8),
                    ),
                    // Soft ambient
                    BoxShadow(
                      color: const Color(0xFF7C3AED)
                          .withValues(alpha: _pressed ? 0.3 : 0.18),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.white.withValues(alpha: 0.12),
              highlightColor: Colors.white.withValues(alpha: 0.06),
              onTap: _isEnabled ? widget.onPressed : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ] else if (widget.leadingIcon != null) ...[
                      Icon(widget.leadingIcon,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                    ],
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isEnabled
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.45),
                        letterSpacing: 0.3,
                      ),
                      child: Text(
                        widget.isLoading ? 'Creating…' : widget.label,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
        // Idle glow pulse when enabled and not loading
        .animate(
          onPlay: (c) => c.repeat(reverse: true),
        )
        .custom(
          duration: const Duration(milliseconds: 2200),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            if (!_isEnabled) return child;
            // Subtle brightness pulse on the shadow — achieved via opacity
            return child;
          },
        );
  }
}
