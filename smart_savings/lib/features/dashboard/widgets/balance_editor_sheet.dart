import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_constants.dart';
import '../../../services/auth_provider.dart';
import '../../../services/savings_service.dart';
import '../../../services/user_service.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';

// PIN for balance access – stored in code for now (demo).
// In a real app this must be stored securely and user-configurable.
const _kDefaultPin = '1234';

class BalanceEditorSheet extends ConsumerStatefulWidget {
  const BalanceEditorSheet({super.key});
  @override
  ConsumerState<BalanceEditorSheet> createState() =>
      _BalanceEditorSheetState();
}

class _BalanceEditorSheetState extends ConsumerState<BalanceEditorSheet> {
  final _pinCtrl = TextEditingController();
  final _pinFocus = FocusNode();
  bool _pinError = false;
  Timer? _autoLockTimer;

  late final TextEditingController _balanceCtrl;
  bool _autoAllocate = true;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final unlocked = ref.read(balanceVisibleProvider);
    _balanceCtrl = TextEditingController(
        text: unlocked ? ref.read(balanceProvider).toStringAsFixed(0) : '');
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    _pinFocus.dispose();
    _balanceCtrl.dispose();
    _autoLockTimer?.cancel();
    super.dispose();
  }

  void _verifyPin() {
    if (_pinCtrl.text == _kDefaultPin) {
      ref.read(balanceVisibleProvider.notifier).unlock();
      _balanceCtrl.text = ref.read(balanceProvider).toStringAsFixed(0);
      setState(() => _pinError = false);
      // Start an auto-lock timer to re-lock after inactivity
      _autoLockTimer?.cancel();
      _autoLockTimer = Timer(const Duration(seconds: 30), () {
        if (mounted) {
          ref.read(balanceVisibleProvider.notifier).lock();
          // clear pin and update UI
          _pinCtrl.clear();
          setState(() {});
        }
      });
    } else {
      setState(() => _pinError = true);
      _pinCtrl.clear();
    }
  }

  Future<void> _save() async {
    final v = double.tryParse(_balanceCtrl.text) ?? 0;
    if (v <= 0) {
      setState(() => _saveError = 'Please enter a valid amount');
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      // Update locally
      ref.read(balanceProvider.notifier).state = v;

      // Persist to backend
      final userId = ref.read(userIdProvider);
      if (userId != null) {
        await UserService.updateBalance(userId: userId, balance: v);
      }

      // Auto-allocate budgets to folders
      if (_autoAllocate) {
        final folders = ref.read(foldersProvider).maybeWhen(
              data: (f) => f,
              orElse: () => const [],
            );
        for (final f in folders) {
          final pct = AppConstants.defaultFolderAllocation[f.name] ?? 0;
          if (pct > 0) {
            await ref
                .read(foldersProvider.notifier)
                .setBudget(f.id, v * pct);
          }
        }
      }

      if (mounted) {
        // After saving, lock the balance view for privacy
        _autoLockTimer?.cancel();
        ref.read(balanceVisibleProvider.notifier).lock();
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _saveError = 'Failed to save. Check your connection.';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = ref.watch(balanceVisibleProvider);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1629),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              20, 10, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: unlocked ? _buildEditor(context) : _buildPinGate(context),
        ),
      ),
    );
  }

  Widget _buildPinGate(BuildContext context) {
    final pin = _pinCtrl.text;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Balance locked',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text('Enter your PIN to view & update balance',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, color: Colors.white54),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () => _pinFocus.requestFocus(),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (i) {
              final ch = i < pin.length ? pin[i] : '';
              final filled = ch.isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 56,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: filled
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _pinError
                        ? const Color(0xFFEF4444)
                        : (filled
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: 0.10)),
                    width: filled ? 1.6 : 1,
                  ),
                ),
                child: Text(
                  filled ? '•' : '•',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: filled
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              );
            }),
          ),
        ),
        // hidden input to drive the boxes
        SizedBox(
          height: 0,
          child: TextField(
            controller: _pinCtrl,
            focusNode: _pinFocus,
            autofocus: true,
            keyboardType: TextInputType.number,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            showCursor: false,
            enableInteractiveSelection: false,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: (_) {
              if (_pinError) setState(() => _pinError = false);
              setState(() {});
              if (_pinCtrl.text.length == 4) _verifyPin();
            },
            onSubmitted: (_) => _verifyPin(),
          ),
        ),
        if (_pinError) ...[
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Incorrect PIN. Try again.',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
          ),
        ],
        const SizedBox(height: 16),
        GradientButton(
          label: pin.length == 4 ? 'Unlock' : 'Enter PIN',
          onPressed: pin.length == 4 ? _verifyPin : null,
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PIN reset not enabled yet')),
            );
          },
          child: const Text('Forgot PIN?'),
        ),
      ],
    );
  }

  Widget _buildEditor(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Expanded(
              child: Text('My Balance',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
            ),
            IconButton(
              tooltip: 'Lock',
              onPressed: () {
                _autoLockTimer?.cancel();
                ref.read(balanceVisibleProvider.notifier).lock();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.lock_rounded, color: Colors.white54),
            ),
            IconButton(
              onPressed: () {
                // Ensure we lock when closing the editor without saving
                _autoLockTimer?.cancel();
                ref.read(balanceVisibleProvider.notifier).lock();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close_rounded, color: Colors.white54),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.06),
                Colors.white.withValues(alpha: 0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Balance',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8),
              ),
              const SizedBox(height: 10),
              Text(
                Formatters.money(ref.read(remainingBalanceProvider)),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _balanceCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            prefixText: '₹ ',
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            errorText: _saveError,
          ),
          onChanged: (_) {
            if (_saveError != null) setState(() => _saveError = null);
          },
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: SwitchListTile(
            value: _autoAllocate,
            onChanged: (v) => setState(() => _autoAllocate = v),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            title: const Text('Auto-allocate to folders',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            subtitle: const Text('Re-distribute budgets by default %',
                style: TextStyle(color: Colors.white60)),
            activeThumbColor: AppColors.primary,
          ),
        ),
        const SizedBox(height: 14),
        GradientButton(
          label: _isSaving ? 'Saving…' : 'Save Balance',
          onPressed: _isSaving ? null : _save,
        ),
      ],
    );
  }
}
