import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_provider.dart';
import '../../shared/widgets/gradient_button.dart';
import '_auth_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/dashboard');
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return AuthShell(
      title: 'Welcome back to your money space.',
      subtitle:
          'Sign in to review budgets, track fresh spending, and keep every goal moving in the right direction.',
      lottieAsset: 'assets/lottie/finance.json',
      badge: 'LOGIN TO CONTINUE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Let’s continue building better saving habits.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your dashboard, folders, and progress are waiting.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _emailController,
            enabled: !authState.isLoading,
            style: const TextStyle(color: Colors.white),
            decoration: authInputDecoration(context, 'Email address', Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            enabled: !authState.isLoading,
            style: const TextStyle(color: Colors.white),
            obscureText: true,
            decoration: authInputDecoration(context, 'Password', Icons.lock_outline),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: authState.isLoading
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Reset password'),
                          content: const Text(
                            'Use your registered email and request a reset once the backend reset flow is enabled, or contact support for help.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Got it'),
                            ),
                          ],
                        ),
                      );
                    },
              child: const Text('Need help with password?'),
            ),
          ),
          const SizedBox(height: 10),
          GradientButton(
            label: authState.isLoading ? 'Signing you in...' : 'Enter Dashboard',
            icon: Icons.arrow_forward_rounded,
            onPressed: authState.isLoading
                ? null
                : () {
                    ref.read(authProvider.notifier).login(
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                        );
                  },
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: authState.isLoading ? null : () => context.go('/signup'),
              child: const Text("New here? Create your smart account"),
            ),
          ),
        ],
      ),
    );
  }
}
