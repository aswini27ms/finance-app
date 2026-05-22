import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_provider.dart';
import '../../shared/widgets/premium_effects.dart';
import '../../theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  void _navigate(AuthState auth) {
    if (_navigated || auth.isLoading || !mounted) return;
    _navigated = true;
    if (auth.isAuthenticated) {
      context.go('/dashboard');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (_, next) => _navigate(next));

    // Fallback if auth resolves before listener attaches
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate(auth));

    return Scaffold(
      body: PremiumPageBackground(
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.savings_rounded, color: Colors.white, size: 56),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.6, 0.6), curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              const Text('Smart Savings',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5))
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms)
                  .slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text('Save smart. Live smarter.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14))
                  .animate()
                  .fadeIn(delay: 600.ms),
              if (auth.isLoading) ...[
                const SizedBox(height: 32),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white70),
                  ),
                ),
              ],
            ],
          ),
          ),
        ),
      ),
    );
  }
}
