import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/savings_service.dart';
import '../../shared/components/main_shell.dart';
import '../../shared/widgets/premium_effects.dart';
import '../../shared/widgets/shimmer_box.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(foldersProvider);
    final weekly = ref.watch(weeklySpendProvider);
    final spent = ref.watch(totalSpentProvider);
    final saved = ref.watch(monthlySavedProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const ShellBackButton(),
        title: const Text('Analytics', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: PremiumPageBackground(
        preset: OrbPreset.analytics,
        child: foldersAsync.when(
          data: (folders) {
            final total = folders.fold<double>(0, (s, f) => s + f.spent);
            final maxWeekly = weekly.isEmpty ? 0.0 : weekly.reduce((a, b) => a > b ? a : b);
            final heatMax = maxWeekly > 0 ? maxWeekly : 1.0;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
              children: [
                PremiumGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'INSIGHT MODE',
                          style: TextStyle(
                            color: Color(0xFF7DE3FF),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Understand spending patterns faster and make sharper money choices.',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.15),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Use weekly and category trends to spot what is helping your budget and what needs attention.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.62), height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _MiniStat(label: 'Spent', value: Formatters.money(spent), color: Colors.red[400]!)),
                    const SizedBox(width: 10),
                    Expanded(child: _MiniStat(label: 'Saved', value: Formatters.money(saved), color: Colors.green[600]!)),
                  ],
                ),
                const SizedBox(height: 20),
                _Card(
                  title: '7-day spending',
                  child: SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                final i = v.toInt();
                                if (i < 0 || i >= labels.length) return const SizedBox();
                                return Text(labels[i], style: const TextStyle(fontSize: 11, color: Colors.grey));
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [AppColors.primary.withValues(alpha: 0.3), Colors.transparent],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            spots: [for (int i = 0; i < weekly.length; i++) FlSpot(i.toDouble(), weekly[i])],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: 0.1),
                const SizedBox(height: 20),
                _Card(
                  title: 'Category spending',
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: folders.any((f) => f.spent > 0)
                            ? PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 50,
                                  sections: [
                                    for (final f in folders)
                                      if (f.spent > 0)
                                        PieChartSectionData(
                                          color: Color(f.color),
                                          value: f.spent,
                                          radius: 40,
                                          title: total == 0 ? '' : '${((f.spent / total) * 100).toStringAsFixed(0)}%',
                                          titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                                        ),
                                  ],
                                ),
                              )
                            : Center(child: Text('No spending data yet', style: TextStyle(color: Colors.grey[500]))),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: folders
                            .where((f) => f.spent > 0)
                            .map((f) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(color: Color(f.color), shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 6),
                                    Text('${f.name}: ${Formatters.money(f.spent)}', style: const TextStyle(fontSize: 12)),
                                  ],
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                const SizedBox(height: 20),
                _Card(
                  title: 'Weekly spending pattern',
                  child: SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (int i = 0; i < weekly.length; i++)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: (weekly[i] / heatMax * 80).clamp(4, 80).toDouble()),
                                    duration: Duration(milliseconds: 500 + (i * 90)),
                                    curve: Curves.easeOutCubic,
                                    builder: (_, animatedHeight, __) => Container(
                                      height: animatedHeight,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.4 + (weekly[i] / heatMax) * 0.6),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 20),
                _Card(
                  title: 'Spending by folder',
                  child: SizedBox(
                    height: 200,
                    child: folders.isEmpty
                        ? Center(child: Text('Create folders to see breakdown', style: TextStyle(color: Colors.grey[500])))
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, _) {
                                      final i = v.toInt();
                                      if (i < 0 || i >= folders.length) return const SizedBox();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          folders[i].name.length > 3 ? folders[i].name.substring(0, 3) : folders[i].name,
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: [
                                for (int i = 0; i < folders.length; i++)
                                  BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: folders[i].spent,
                                        color: Color(folders[i].color),
                                        width: 14,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
              ],
            );
          },
          loading: () => const ShimmerList(),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Could not load analytics', style: TextStyle(color: Colors.red[400])),
                TextButton(
                  onPressed: () => ref.read(foldersProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return PremiumGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.circle, size: 14, color: color),
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return PremiumGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
