import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/gradient_button.dart';
import '../../theme/app_colors.dart';
import '_auth_shell.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  final _focusNode = FocusNode();
  int _secondsLeft = 30;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _secondsLeft = 30;
    Future.doWhile(() async {
      if (!mounted) return false;
      if (_secondsLeft <= 0) return false;
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _secondsLeft--);
      return _secondsLeft > 0;
    });
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0 || _resending) return;
    setState(() => _resending = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _resending = false);
    _startTimer();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New code sent (demo)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final otp = _otpCtrl.text;
    final canVerify = otp.length == 6;

    return AuthShell(
      title: 'Verify your secure sign in.',
      subtitle: 'Enter the 6-digit confirmation code sent to your phone to unlock your dashboard safely.',
      lottieAsset: 'assets/lottie/analysis.json',
      badge: 'OTP VERIFICATION',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'One final step before you continue.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This quick verification helps keep your account and savings activity protected.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: () => _focusNode.requestFocus(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                final ch = i < otp.length ? otp[i] : '';
                final filled = ch.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: filled
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    border: Border.all(
                      color: filled
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.35),
                      width: filled ? 1.6 : 1.2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    filled ? ch : '•',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: filled ? Colors.white : Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Hidden input (drives the boxes above)
          SizedBox(
            height: 0,
            child: TextField(
              controller: _otpCtrl,
              focusNode: _focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: canVerify ? 'Verify & Continue' : 'Enter Full OTP',
            icon: Icons.verified_user_rounded,
            onPressed: canVerify ? () => context.go('/dashboard') : null,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: (_secondsLeft == 0 && !_resending) ? _resend : null,
            child: Text(
              _resending
                  ? 'Sending…'
                  : (_secondsLeft == 0
                      ? 'Resend code'
                      : 'Resend in 0:${_secondsLeft.toString().padLeft(2, '0')}'),
            ),
          ),
        ],
      ),
    );
  }
}
