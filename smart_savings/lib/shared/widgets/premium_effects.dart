import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ORB PALETTES — theme-aware preset colour sets
// ─────────────────────────────────────────────────────────────────────────────

class OrbPalette {
  final List<Color> colors;
  final Color baseGlow;
  final List<Color> bgGradient;
  const OrbPalette({
    required this.colors,
    required this.baseGlow,
    required this.bgGradient,
  });
}

class OrbPalettes {
  /// Default fintech dark — deep purple + indigo + violet
  static const dark = OrbPalette(
    colors: [
      Color(0xFF7C5CFC), // brand purple
      Color(0xFF4F46E5), // indigo
      Color(0xFF06B6D4), // cyan
      Color(0xFF8B5CF6), // violet
      Color(0xFFEC4899), // pink accent
    ],
    baseGlow: Color(0xFF7C5CFC),
    bgGradient: [Color(0xFF050610), Color(0xFF0C0E1A), Color(0xFF07090F)],
  );

  /// Dashboard — warmer, more balanced
  static const dashboard = OrbPalette(
    colors: [
      Color(0xFF7C5CFC),
      Color(0xFF3B82F6),
      Color(0xFF06B6D4),
      Color(0xFF8B5CF6),
    ],
    baseGlow: Color(0xFF7C5CFC),
    bgGradient: [Color(0xFF060812), Color(0xFF0C0F1C), Color(0xFF080910)],
  );

  /// Analytics — cooler blue-teal
  static const analytics = OrbPalette(
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF06B6D4),
      Color(0xFF7C5CFC),
      Color(0xFF0EA5E9),
    ],
    baseGlow: Color(0xFF3B82F6),
    bgGradient: [Color(0xFF050B12), Color(0xFF08101A), Color(0xFF050810)],
  );

  /// Goals — warmer green-emerald
  static const goals = OrbPalette(
    colors: [
      Color(0xFF10B981),
      Color(0xFF7C5CFC),
      Color(0xFF06B6D4),
      Color(0xFF059669),
    ],
    baseGlow: Color(0xFF10B981),
    bgGradient: [Color(0xFF050D0B), Color(0xFF080F0C), Color(0xFF050810)],
  );

  /// Light theme default
  static const light = OrbPalette(
    colors: [
      Color(0xFF9B7DFF), // lavender purple
      Color(0xFF818CF8), // soft indigo
      Color(0xFF67E8F9), // soft cyan
      Color(0xFFC4B5FD), // frosted violet
      Color(0xFFF9A8D4), // gentle pink
    ],
    baseGlow: Color(0xFF9B7DFF),
    bgGradient: [Color(0xFFF4F0FF), Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE BACKGROUND — main wrapper
// ─────────────────────────────────────────────────────────────────────────────

enum OrbPreset { defaultPreset, dashboard, analytics, goals }

class PremiumPageBackground extends StatelessWidget {
  final Widget child;
  final OrbPreset preset;

  const PremiumPageBackground({
    super.key,
    required this.child,
    this.preset = OrbPreset.defaultPreset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = isDark ? _darkPalette(preset) : OrbPalettes.light;

    return Stack(
      children: [
        // Base gradient background
        Positioned.fill(
          child: _BaseGradient(palette: palette, isDark: isDark),
        ),

        // Noise/grain texture — very subtle premium feel
        Positioned.fill(
          child: IgnorePointer(
            child: _GrainOverlay(isDark: isDark),
          ),
        ),

        // Orb layer — staggered positions, sizes, speeds
        ..._buildOrbs(palette, isDark),

        // Glass sheen — top-left diagonal highlight
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.025 : 0.60),
                    Colors.transparent,
                    Colors.white.withValues(alpha: isDark ? 0.012 : 0.30),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Content
        child,
      ],
    );
  }

  OrbPalette _darkPalette(OrbPreset preset) {
    return switch (preset) {
      OrbPreset.dashboard => OrbPalettes.dashboard,
      OrbPreset.analytics => OrbPalettes.analytics,
      OrbPreset.goals => OrbPalettes.goals,
      OrbPreset.defaultPreset => OrbPalettes.dark,
    };
  }

  List<Widget> _buildOrbs(OrbPalette palette, bool isDark) {
    final double baseOpacity = isDark ? 1.0 : 0.55;
    final c = palette.colors;
    return [
      // Top-right hero orb
      Positioned(
        top: -100,
        right: -80,
        child: RepaintBoundary(
          child: FloatingOrb(
            color: c[0],
            size: 340,
            opacity: isDark ? 0.22 : 0.18,
            amplitude: 22,
            durationMs: 5200,
            phaseShift: 0,
          ),
        ),
      ),
      // Left-mid orb
      Positioned(
        top: 160,
        left: -80,
        child: RepaintBoundary(
          child: FloatingOrb(
            color: c[1],
            size: 260,
            opacity: (isDark ? 0.16 : 0.14) * baseOpacity,
            amplitude: 18,
            durationMs: 6400,
            phaseShift: math.pi * 0.4,
          ),
        ),
      ),
      // Bottom-right orb
      Positioned(
        bottom: -60,
        right: -30,
        child: RepaintBoundary(
          child: FloatingOrb(
            color: c[2],
            size: 300,
            opacity: (isDark ? 0.13 : 0.12) * baseOpacity,
            amplitude: 14,
            durationMs: 5800,
            phaseShift: math.pi * 0.7,
          ),
        ),
      ),
      // Small accent — top-left
      Positioned(
        top: 60,
        left: 80,
        child: RepaintBoundary(
          child: FloatingOrb(
            color: c.length > 3 ? c[3] : c[0],
            size: 160,
            opacity: (isDark ? 0.10 : 0.09) * baseOpacity,
            amplitude: 10,
            durationMs: 4000,
            phaseShift: math.pi * 0.25,
          ),
        ),
      ),
      // Tiny sparkle orb — mid-right
      Positioned(
        top: 300,
        right: 60,
        child: RepaintBoundary(
          child: FloatingOrb(
            color: c.length > 4 ? c[4] : c[1],
            size: 120,
            opacity: (isDark ? 0.09 : 0.07) * baseOpacity,
            amplitude: 8,
            durationMs: 3400,
            phaseShift: math.pi * 0.9,
          ),
        ),
      ),
      // Bottom-left ambient
      Positioned(
        bottom: 120,
        left: -40,
        child: RepaintBoundary(
          child: FloatingOrb(
            color: c[0],
            size: 180,
            opacity: (isDark ? 0.08 : 0.06) * baseOpacity,
            amplitude: 12,
            durationMs: 7200,
            phaseShift: math.pi * 0.55,
          ),
        ),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BASE GRADIENT
// ─────────────────────────────────────────────────────────────────────────────

class _BaseGradient extends StatelessWidget {
  final OrbPalette palette;
  final bool isDark;
  const _BaseGradient({required this.palette, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette.bgGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GRAIN / NOISE OVERLAY — adds subtle texture like real fintech apps
// ─────────────────────────────────────────────────────────────────────────────

class _GrainOverlay extends StatelessWidget {
  final bool isDark;
  const _GrainOverlay({required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Cheap grain using a semi-transparent diagonal stripe pattern
    return CustomPaint(
      painter: _GrainPainter(isDark: isDark),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final bool isDark;
  _GrainPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.018);
    for (var i = 0; i < 600; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), rng.nextDouble() * 0.9, paint);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// FLOATING ORB — animated with float + breathe
// ─────────────────────────────────────────────────────────────────────────────

class FloatingOrb extends StatefulWidget {
  final Color color;
  final double size;
  final double opacity;
  final double amplitude;
  final int durationMs;
  final double phaseShift;

  const FloatingOrb({
    super.key,
    required this.color,
    required this.size,
    this.opacity = 0.14,
    this.amplitude = 14,
    this.durationMs = 5000,
    this.phaseShift = 0.0,
  });

  @override
  State<FloatingOrb> createState() => _FloatingOrbState();
}

class _FloatingOrbState extends State<FloatingOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    // Stagger start via phaseShift so orbs don't all move in sync
    _ctrl.forward(from: (widget.phaseShift / (math.pi * 2)).clamp(0.0, 1.0));
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _ctrl.reverse();
      if (s == AnimationStatus.dismissed) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        // Float: vertical sine
        final dy = math.sin(_anim.value * math.pi) * widget.amplitude;
        // Breathe: subtle scale pulse
        final scale = 0.93 + (_anim.value * 0.14);
        // Opacity breathe: slightly dims at extremes
        final opacity = widget.opacity * (0.88 + _anim.value * 0.22);

        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.65,
            colors: [
              widget.color.withValues(alpha: widget.opacity),
              widget.color.withValues(alpha: widget.opacity * 0.5),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARALLAX ORB BACKGROUND — scrollable version with scroll-driven parallax
// ─────────────────────────────────────────────────────────────────────────────

class ParallaxOrbBackground extends StatefulWidget {
  final Widget child;
  final OrbPreset preset;

  const ParallaxOrbBackground({
    super.key,
    required this.child,
    this.preset = OrbPreset.defaultPreset,
  });

  @override
  State<ParallaxOrbBackground> createState() => _ParallaxOrbBackgroundState();
}

class _ParallaxOrbBackgroundState extends State<ParallaxOrbBackground> {
  final _scroll = ScrollController();
  double _offset = 0.0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (mounted) {
        setState(() => _offset = _scroll.offset);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = isDark ? _darkPalette(widget.preset) : OrbPalettes.light;
    final c = palette.colors;

    return Stack(
      children: [
        Positioned.fill(child: _BaseGradient(palette: palette, isDark: isDark)),
        Positioned.fill(child: IgnorePointer(child: _GrainOverlay(isDark: isDark))),

        // Parallax orbs shift at different rates as user scrolls
        IgnorePointer(
          child: Stack(
            children: [
              _ParallaxOrb(
                color: c[0], size: 340, opacity: isDark ? 0.20 : 0.16,
                top: -100 - _offset * 0.12, right: -80, durationMs: 5200,
              ),
              _ParallaxOrb(
                color: c[1], size: 260, opacity: isDark ? 0.14 : 0.12,
                top: 160 - _offset * 0.07, left: -80, durationMs: 6400,
              ),
              _ParallaxOrb(
                color: c[2], size: 300, opacity: isDark ? 0.12 : 0.10,
                bottom: -60 + _offset * 0.10, right: -30, durationMs: 5800,
              ),
              _ParallaxOrb(
                color: c.length > 3 ? c[3] : c[0], size: 160,
                opacity: isDark ? 0.09 : 0.07,
                top: 80 - _offset * 0.04, left: 90, durationMs: 4000,
              ),
            ],
          ),
        ),

        // Sheen
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.025 : 0.55),
                    Colors.transparent,
                    Colors.white.withValues(alpha: isDark ? 0.010 : 0.25),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),

        // Child rendered inside the scroll controller
        Builder(
          builder: (ctx) => PrimaryScrollController(
            controller: _scroll,
            child: widget.child,
          ),
        ),
      ],
    );
  }

  OrbPalette _darkPalette(OrbPreset preset) => switch (preset) {
        OrbPreset.dashboard => OrbPalettes.dashboard,
        OrbPreset.analytics => OrbPalettes.analytics,
        OrbPreset.goals => OrbPalettes.goals,
        OrbPreset.defaultPreset => OrbPalettes.dark,
      };
}

class _ParallaxOrb extends StatefulWidget {
  final Color color;
  final double size;
  final double opacity;
  final int durationMs;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const _ParallaxOrb({
    required this.color,
    required this.size,
    required this.opacity,
    required this.durationMs,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  State<_ParallaxOrb> createState() => _ParallaxOrbState();
}

class _ParallaxOrbState extends State<_ParallaxOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      bottom: widget.bottom,
      left: widget.left,
      right: widget.right,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          final dy = math.sin(_ctrl.value * math.pi) * 14;
          final scale = 0.94 + (_ctrl.value * 0.12);
          return Transform.translate(
            offset: Offset(0, dy),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: RepaintBoundary(
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.65,
                colors: [
                  widget.color.withValues(alpha: widget.opacity),
                  widget.color.withValues(alpha: widget.opacity * 0.45),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLASS CARD — premium frosted glass card
// ─────────────────────────────────────────────────────────────────────────────

class PremiumGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? borderRadius;
  final Color? glowColor;

  const PremiumGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final br = borderRadius ?? 24.0;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.035)
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(br),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.white.withValues(alpha: 0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? AppColors.primary).withValues(alpha: isDark ? 0.10 : 0.06),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(br),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.05),
                        Colors.white.withValues(alpha: 0.02),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.80),
                        Colors.white.withValues(alpha: 0.55),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED PROGRESS BAR
// ─────────────────────────────────────────────────────────────────────────────

class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  final Color? backgroundColor;
  final Duration duration;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 8,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: v,
          minHeight: height,
          backgroundColor: backgroundColor ?? color.withValues(alpha: 0.12),
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GRADIENT ICON TILE — press/hover animation with gradient fill
// ─────────────────────────────────────────────────────────────────────────────

class GradientIconTile extends StatefulWidget {
  final IconData icon;
  final Gradient gradient;
  final Color idleColor;
  final double size;
  final double iconSize;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  const GradientIconTile({
    super.key,
    required this.icon,
    required this.gradient,
    this.idleColor = AppColors.primary,
    this.size = 44,
    this.iconSize = 20,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.onTap,
    this.margin = EdgeInsets.zero,
  });

  @override
  State<GradientIconTile> createState() => _GradientIconTileState();
}

class _GradientIconTileState extends State<GradientIconTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.91).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _press() => _ctrl.forward();
  void _release() {
    _ctrl.reverse();
    widget.onTap?.call();
  }

  void _cancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press(),
      onTapUp: (_) => _release(),
      onTapCancel: _cancel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          final pressed = _ctrl.value > 0.3;
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              margin: widget.margin,
              decoration: BoxDecoration(
                gradient: pressed ? widget.gradient : null,
                color: pressed ? null : widget.idleColor.withValues(alpha: 0.12),
                borderRadius: widget.borderRadius,
                border: Border.all(
                  color: pressed
                      ? Colors.white.withValues(alpha: 0.25)
                      : widget.idleColor.withValues(alpha: 0.20),
                  width: pressed ? 1.4 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.idleColor.withValues(alpha: pressed ? 0.40 : 0.12),
                    blurRadius: pressed ? 20 : 10,
                    spreadRadius: pressed ? 1 : 0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: pressed ? Colors.white : widget.idleColor,
                size: widget.iconSize,
              ),
            ),
          );
        },
      ),
    );
  }
}
