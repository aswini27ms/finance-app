import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_provider.dart';
import '../../shared/widgets/gradient_button.dart';
import '_auth_shell.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      title: 'Start your smarter savings journey today.',
      subtitle:
          'Create your account to organize budgets beautifully, stay motivated, and build a stronger financial routine.',
      lottieAsset: 'assets/lottie/register.json',
      badge: 'CREATE ACCOUNT',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'A few quick details and you’re ready to go.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set up your profile and unlock a cleaner way to track every target.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _nameController,
            enabled: !authState.isLoading,
            style: const TextStyle(color: Colors.white),
            decoration: authInputDecoration(context, 'Full name', Icons.person_outline),
          ),
          const SizedBox(height: 16),
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
            decoration: authInputDecoration(context, 'Create password', Icons.lock_outline),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            enabled: !authState.isLoading,
            style: const TextStyle(color: Colors.white),
            obscureText: true,
            decoration: authInputDecoration(context, 'Confirm password', Icons.lock_outline),
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: authState.isLoading ? 'Creating your account...' : 'Create My Account',
            icon: Icons.person_add_alt_1_rounded,
            onPressed: authState.isLoading
                ? null
                : () {
                    if (_passwordController.text != _confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Passwords do not match'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    ref.read(authProvider.notifier).register(
                          name: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                        );
                  },
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: authState.isLoading ? null : () => context.go('/login'),
              child: const Text('Already a member? Log in instead'),
            ),
          ),
        ],
      ),
    );
  }
}
