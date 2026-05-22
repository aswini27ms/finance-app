import 'package:flutter/material.dart';

import '../../utils/formatters.dart';

class AnimatedMoney extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;

  const AnimatedMoney({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text(Formatters.money(v), style: style),
    );
  }
}
