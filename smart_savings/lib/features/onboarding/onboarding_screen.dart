import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../shared/widgets/gradient_button.dart';
import '../../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    (
      asset: 'assets/lottie/finance.json',
      eyebrow: 'SMART MONEY',
      title: 'Take charge of every rupee with calm, premium budgeting.',
      sub:
          'Build focused savings habits, track spending beautifully, and stay in control with a dashboard that feels effortless.'
    ),
    (
      asset: 'assets/lottie/analysis.json',
      eyebrow: 'REAL-TIME INSIGHTS',
      title: 'See where your money goes before your month gets away from you.',
      sub:
          'Watch folder budgets, monthly progress, and healthier saving decisions update in one elegant flow.'
    ),
    (
      asset: 'assets/lottie/register.json',
      eyebrow: 'START STRONG',
      title: 'Create smarter routines, reach goals faster, and save with confidence.',
      sub:
          'From daily expenses to future dreams, Smart Savings helps every decision feel intentional and motivating.'
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _page == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          const _OnboardingBackdrop(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) {
                      final p = _pages[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                                child: Text(
                                  '0${i + 1} / 0${_pages.length}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF15202B), Color(0xFF101118)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(36),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.07),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.18),
                                      blurRadius: 40,
                                      offset: const Offset(0, 20),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(30),
                                                gradient: RadialGradient(
                                                  center: Alignment.topCenter,
                                                  radius: 1.15,
                                                  colors: [
                                                    AppColors.accent.withValues(alpha: 0.18),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Lottie.asset(
                                              p.asset,
                                              fit: BoxFit.contain,
                                              repeat: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        p.eyebrow,
                                        style: const TextStyle(
                                          color: AppColors.primaryAlt,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ).animate().fadeIn(delay: 120.ms),
                                    const SizedBox(height: 18),
                                    Text(
                                      p.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        height: 1.12,
                                        letterSpacing: -1.2,
                                      ),
                                    ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.08),
                                    const SizedBox(height: 14),
                                    Text(
                                      p.sub,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.70),
                                        fontSize: 15,
                                        height: 1.55,
                                      ),
                                    ).animate().fadeIn(delay: 240.ms),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_pages.length, (i) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 260),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _page == i ? 26 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: _page == i ? AppColors.primaryGradient : null,
                                  color: _page == i
                                      ? null
                                      : Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 170,
                          child: GradientButton(
                            label: isLastPage ? 'Start Saving' : 'Next View',
                            icon: isLastPage ? Icons.arrow_forward_rounded : Icons.chevron_right_rounded,
                            onPressed: () {
                              if (isLastPage) {
                                context.go('/login');
                              } else {
                                _controller.nextPage(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOut,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingBackdrop extends StatelessWidget {
  const _OnboardingBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF090A11), Color(0xFF11131C), Color(0xFF090A11)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -40,
          child: _glow(const Color(0xFF7C5CFC), 220, 0.18),
        ),
        Positioned(
          top: 180,
          left: -40,
          child: _glow(const Color(0xFF00D4FF), 180, 0.10),
        ),
        Positioned(
          bottom: -30,
          right: 20,
          child: _glow(const Color(0xFF9B7DFF), 240, 0.12),
        ),
      ],
    );
  }

  Widget _glow(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), Colors.transparent],
        ),
      ),
    );
  }
}
