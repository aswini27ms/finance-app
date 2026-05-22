import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF7C5CFC); // vibrant purple
  static const Color primaryAlt = Color(0xFF9B7DFF); // lighter purple
  static const Color accent = Color(0xFF00D4FF); // electric cyan
  static const Color success = Color(0xFF00E5A0); // mint green
  static const Color warning = Color(0xFFFFB340);
  static const Color danger = Color(0xFFFF4D6A);

  // Dark theme (primary surfaces)
  static const Color darkBg = Color(0xFF0A0A14); // near-black
  static const Color darkCard = Color(0xFF12121E); // card background
  static const Color darkSurface = Color(0xFF1A1A2E); // elevated surface
  static const Color darkSurface2 = Color(0xFF22223A); // deeper elevation
  static const Color darkText = Color(0xFFEEEEFF);
  static const Color darkTextSub = Color(0xFF8888AA);
  static const Color darkMuted = Color(0xFF555577);
  static const Color darkBorder = Color(0xFF2A2A44);

  // Light theme
  static const Color lightBg = Color(0xFFF4F4FC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F0FA);
  static const Color lightText = Color(0xFF0D0D1A);
  static const Color lightTextSub = Color(0xFF666688);
  static const Color lightMuted = Color(0xFF9999BB);
  static const Color lightBorder = Color(0xFFE0E0F0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C5CFC), Color(0xFF9B7DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF6B46FB), Color(0xFF8B63FF), Color(0xFFAD7EFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF7C5CFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00C97A), Color(0xFF00E5A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF2D55), Color(0xFFFF4D6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
