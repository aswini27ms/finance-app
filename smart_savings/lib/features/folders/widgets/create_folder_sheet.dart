import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/savings_service.dart';
import '../folder_model.dart';

// ── Public opener ─────────────────────────────────────────────────────────────
void showCreateFolderSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => const CreateFolderSheet(),
  );
}

class CreateFolderSheet extends StatelessWidget {
  const CreateFolderSheet({super.key});
  @override
  Widget build(BuildContext context) => const _SheetBody();
}

// ── Icon data ─────────────────────────────────────────────────────────────────
const _kIcons = [
  ('folder',         Icons.folder_outlined,           'General'),
  ('restaurant',     Icons.restaurant_outlined,        'Food'),
  ('flight',         Icons.flight_takeoff_outlined,    'Travel'),
  ('home',           Icons.home_outlined,              'Home'),
  ('trending_up',    Icons.trending_up,                'Invest'),
  ('sports_esports', Icons.sports_esports_outlined,    'Fun'),
  ('shield',         Icons.shield_outlined,            'Emergency'),
  ('shopping_bag',   Icons.shopping_bag_outlined,      'Shopping'),
  ('local_hospital', Icons.local_hospital_outlined,    'Health'),
  ('other',          Icons.more_horiz_rounded,         'Other'),
];

const _kPalette = [
  0xFF6366F1, 0xFF22C55E, 0xFFF59E0B,
  0xFFEC4899, 0xFF06B6D4, 0xFFF43F5E, 0xFF8B5CF6,
];

// ── Sheet body ────────────────────────────────────────────────────────────────
class _SheetBody extends ConsumerStatefulWidget {
  const _SheetBody();
  @override
  ConsumerState<_SheetBody> createState() => _SheetBodyState();
}

class _SheetBodyState extends ConsumerState<_SheetBody> {
  final _nameCtrl   = TextEditingController();
  final _budgetCtrl = TextEditingController();
  int    _color     = 0xFF6366F1;
  String _icon      = 'folder';
  bool   _loading   = false;
  String? _nameErr;
  String? _budgetErr;

  // After success we switch to the success screen
  bool   _success   = false;
  Folder? _created;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  // ── Validate ────────────────────────────────────────────────────────────────
  bool _validate() {
    bool ok = true;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _nameErr = 'Folder name is required');
      HapticFeedback.heavyImpact();
      ok = false;
    } else if (name.length < 2) {
      setState(() => _nameErr = 'At least 2 characters');
      HapticFeedback.heavyImpact();
      ok = false;
    }
    final b = _budgetCtrl.text.trim();
    if (b.isNotEmpty && (double.tryParse(b) == null || double.parse(b) < 0)) {
      setState(() => _budgetErr = 'Enter a valid amount');
      HapticFeedback.heavyImpact();
      ok = false;
    }
    return ok;
  }

  // ── Create ──────────────────────────────────────────────────────────────────
  Future<void> _create() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    setState(() { _loading = true; _nameErr = null; _budgetErr = null; });

    final folder = Folder(
      id: '',
      name: _nameCtrl.text.trim(),
      icon: _icon,
      budget: double.tryParse(_budgetCtrl.text.trim()) ?? 0,
      spent: 0,
      color: _color,
    );

    try {
      await ref.read(foldersProvider.notifier).add(folder);
      HapticFeedback.mediumImpact();
      setState(() { _loading = false; _success = true; _created = folder; });
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() {
        _loading = false;
        _nameErr = 'Could not create folder — check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.93;
    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1629),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.18),
            blurRadius: 40, offset: const Offset(0, -6),
          ),
        ],
      ),
      child: _success ? _SuccessScreen(folder: _created!, onViewFolders: () => Navigator.pop(context), onCreateAnother: () => setState(() { _success = false; _nameCtrl.clear(); _budgetCtrl.clear(); _icon = 'folder'; _color = 0xFF6366F1; }))
                      : _FormScreen(nameCtrl: _nameCtrl, budgetCtrl: _budgetCtrl, color: _color, icon: _icon, loading: _loading, nameErr: _nameErr, budgetErr: _budgetErr, onColorChanged: (c) => setState(() => _color = c), onIconChanged: (i) => setState(() => _icon = i), onNameChanged: (_) { if (_nameErr != null) setState(() => _nameErr = null); setState(() {}); }, onBudgetChanged: (_) { if (_budgetErr != null) setState(() => _budgetErr = null); setState(() {}); }, onCreate: _create),
    );
  }
}

// ── Form screen ───────────────────────────────────────────────────────────────
class _FormScreen extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController budgetCtrl;
  final int color;
  final String icon;
  final bool loading;
  final String? nameErr;
  final String? budgetErr;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<String> onIconChanged;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onBudgetChanged;
  final VoidCallback onCreate;

  const _FormScreen({
    required this.nameCtrl, required this.budgetCtrl,
    required this.color, required this.icon, required this.loading,
    required this.nameErr, required this.budgetErr,
    required this.onColorChanged, required this.onIconChanged,
    required this.onNameChanged, required this.onBudgetChanged,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── App bar ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white70, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text('Create Folder',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Divider(color: Colors.white.withValues(alpha: 0.07), height: 1),

        // ── Scrollable form ──────────────────────────────────────────────
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Folder Name'),
                const SizedBox(height: 8),
                _inputField(
                  controller: nameCtrl,
                  hint: 'e.g. Groceries',
                  prefixIcon: Icons.folder_outlined,
                  error: nameErr,
                  onChanged: onNameChanged,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                _label('Monthly Budget', sub: 'Optional'),
                const SizedBox(height: 8),
                _inputField(
                  controller: budgetCtrl,
                  hint: '5000',
                  prefixIcon: Icons.currency_rupee_rounded,
                  prefixText: '₹  ',
                  error: budgetErr,
                  onChanged: onBudgetChanged,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                ),
                const SizedBox(height: 22),
                _label('Choose Icon'),
                const SizedBox(height: 10),
                _IconGrid(selected: icon, color: color, onTap: onIconChanged),
                const SizedBox(height: 22),
                _label('Choose Color'),
                const SizedBox(height: 10),
                _ColorRow(selected: color, onTap: onColorChanged),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // ── Sticky button ────────────────────────────────────────────────
        _StickyButton(loading: loading, onTap: onCreate),
      ],
    );
  }

  static Widget _label(String text, {String? sub}) {
    return Row(children: [
      Text(text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600)),
      if (sub != null) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(sub,
              style: const TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    ]);
  }

  static Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    String? prefixText,
    String? error,
    required ValueChanged<String> onChanged,
    bool autofocus = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF6366F1), size: 20),
        prefixText: prefixText,
        prefixStyle: const TextStyle(
            color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 16),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        errorText: error,
        errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEF4444))),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

// ── Icon grid ─────────────────────────────────────────────────────────────────
class _IconGrid extends StatelessWidget {
  final String selected;
  final int color;
  final ValueChanged<String> onTap;
  const _IconGrid({required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _kIcons.map((e) {
        final (key, iconData, label) = e;
        final sel = selected == key;
        final pc = Color(color);
        return GestureDetector(
          onTap: () { HapticFeedback.selectionClick(); onTap(key); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: sel ? pc.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel ? pc : Colors.white.withValues(alpha: 0.08),
                width: sel ? 1.5 : 1,
              ),
              boxShadow: sel ? [BoxShadow(color: pc.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))] : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData, color: sel ? pc : Colors.white54, size: 22),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        color: sel ? pc : Colors.white38)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Color row ─────────────────────────────────────────────────────────────────
class _ColorRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _ColorRow({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _kPalette.map((c) {
        final sel = selected == c;
        return GestureDetector(
          onTap: () { HapticFeedback.selectionClick(); onTap(c); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 10),
            width: sel ? 40 : 36,
            height: sel ? 40 : 36,
            decoration: BoxDecoration(
              color: Color(c),
              shape: BoxShape.circle,
              border: Border.all(color: sel ? Colors.white : Colors.transparent, width: 2.5),
              boxShadow: sel ? [BoxShadow(color: Color(c).withValues(alpha: 0.6), blurRadius: 14, spreadRadius: 1)] : [],
            ),
            child: sel ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
          ),
        );
      }).toList(),
    );
  }
}

// ── Sticky create button ──────────────────────────────────────────────────────
class _StickyButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onTap;
  const _StickyButton({required this.loading, required this.onTap});
  @override
  State<_StickyButton> createState() => _StickyButtonState();
}

class _StickyButtonState extends State<_StickyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 100.ms, reverseDuration: 200.ms);
    _scale = Tween(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1629),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
      ),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: GestureDetector(
          onTapDown: (_) { if (!widget.loading) _ctrl.forward(); },
          onTapUp: (_) { _ctrl.reverse(); if (!widget.loading) widget.onTap(); },
          onTapCancel: () => _ctrl.reverse(),
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              gradient: widget.loading
                  ? const LinearGradient(colors: [Color(0xFF3D3F5C), Color(0xFF3D3F5C)])
                  : const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: widget.loading ? [] : [
                BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.45), blurRadius: 24, offset: const Offset(0, 8)),
                BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.25), blurRadius: 40, offset: const Offset(0, 16)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.loading)
                  const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
                else
                  const Icon(Icons.create_new_folder_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  widget.loading ? 'Creating…' : 'Create Folder',
                  style: TextStyle(
                      color: widget.loading ? Colors.white54 : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Success screen (matches screenshot) ──────────────────────────────────────
class _SuccessScreen extends StatelessWidget {
  final Folder folder;
  final VoidCallback onViewFolders;
  final VoidCallback onCreateAnother;

  const _SuccessScreen({
    required this.folder,
    required this.onViewFolders,
    required this.onCreateAnother,
  });

  String get _iconLabel {
    for (final e in _kIcons) {
      if (e.$1 == folder.icon) return e.$3;
    }
    return 'General';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: onViewFolders,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Folder icon with check badge
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: Color(folder.color).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _kIcons.firstWhere((e) => e.$1 == folder.icon, orElse: () => _kIcons.first).$2,
                  color: Color(folder.color),
                  size: 48,
                ),
              ),
              Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
              ),
            ],
          ).animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.easeOutBack).fadeIn(duration: 300.ms),

          const SizedBox(height: 20),
          const Text('Folder Created!',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))
              .animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms),
          const SizedBox(height: 6),
          Text('${folder.name} folder has been\ncreated successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 14, height: 1.5))
              .animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 28),

          // Details card
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                _DetailRow('Name', folder.name),
                _Divider(),
                _DetailRow('Budget',
                    folder.budget > 0 ? '₹${folder.budget.toStringAsFixed(0)}' : 'Not set'),
                _Divider(),
                _DetailRow('Icon', _iconLabel),
                _Divider(),
                _DetailRow('Color', '', colorDot: Color(folder.color)),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.15, duration: 400.ms),

          const SizedBox(height: 28),

          // View Folders button
          GestureDetector(
            onTap: onViewFolders,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: const Center(
                child: Text('View Folders',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, duration: 400.ms),

          const SizedBox(height: 14),

          // Create another
          GestureDetector(
            onTap: onCreateAnother,
            child: const Text('Create Another',
                style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? colorDot;
  const _DetailRow(this.label, this.value, {this.colorDot});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13)),
          if (colorDot != null)
            Container(width: 22, height: 22, decoration: BoxDecoration(color: colorDot, shape: BoxShape.circle))
          else
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: Colors.white.withValues(alpha: 0.06), indent: 20, endIndent: 20);
}
