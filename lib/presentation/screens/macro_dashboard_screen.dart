import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../application/providers/dashboard_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/chart_axis.dart';
import '../widgets/offline_banner.dart';
import 'challenge_list_screen.dart';
import 'donation_screen.dart';
import 'glossary_screen.dart';
import 'my_page_screen.dart';
import 'prefecture_aging_screen.dart';
import 'quiz_screen.dart';
import 'ranking_screen.dart';
import 'time_machine_screen.dart';

class MacroDashboardScreen extends ConsumerWidget {
  const MacroDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(macroDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('日本の未来'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'マイページ',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MyPageScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.volunteer_activism_outlined),
            tooltip: '応援する（寄付）',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const DonationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: '用語集',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const GlossaryScreen()),
              );
            },
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
        data: (dashboard) {
          final popValues = dashboard.populationTrend
              .map((e) => e.population)
              .toList();
          final popInterval = niceAxisInterval(
            popValues.reduce((a, b) => a < b ? a : b),
            popValues.reduce((a, b) => a > b ? a : b),
          );

          final energyValues = dashboard.energySelfSufficiency
              .map((e) => e.selfSufficiencyRate)
              .toList();
          final energyInterval = niceAxisInterval(
            energyValues.reduce((a, b) => a < b ? a : b),
            energyValues.reduce((a, b) => a > b ? a : b),
          );

          final healthcareValues = dashboard.healthcareCostTrend
              .map((e) => e.totalCost)
              .toList();
          final healthcareInterval = niceAxisInterval(
            healthcareValues.reduce((a, b) => a < b ? a : b),
            healthcareValues.reduce((a, b) => a > b ? a : b),
          );

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const OfflineBanner(),
              _DashboardSection(
                title: '人口はどれだけ減る？',
                subtitle: '2023年 → 2070年',
                footnote:
                    '${dashboard.populationTrend.first.population.toStringAsFixed(0)}百万人 → '
                    '${dashboard.populationTrend.last.population.toStringAsFixed(0)}百万人',
                child: SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: popInterval,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppColors.border,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final idx = value.round();
                              if (idx < 0 ||
                                  idx >= dashboard.populationTrend.length) {
                                return const SizedBox.shrink();
                              }
                              final year = dashboard.populationTrend[idx].year;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '$year',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 28,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: popInterval,
                            getTitlesWidget: (value, meta) => Text(
                              value.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: dashboard.populationTrend
                              .asMap()
                              .entries
                              .map(
                                (e) => FlSpot(
                                  e.key.toDouble(),
                                  e.value.population,
                                ),
                              )
                              .toList(),
                          isCurved: true,
                          color: AppColors.populationBlue,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.populationBlue.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TimeMachineScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.access_time, size: 18),
                label: const Text('政策でどう変わる？タイムマシンで見る'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PrefectureAgingScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('過疎・高齢化はどこで進んでいる？都道府県別に見る'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              _DashboardSection(
                title: '税金は何に使われている？',
                subtitle: '2026年度 国の予算',
                child: Column(
                  children: dashboard.budgetAllocation
                      .asMap()
                      .entries
                      .map(
                        (e) => _BudgetRow(
                          label: e.value.category,
                          percentage: e.value.percentage,
                          amount: e.value.amount,
                          color: _budgetColor(e.key),
                        ),
                      )
                      .toList(),
                ),
              ),

              _DashboardSection(
                title: '生活に困っている人は？',
                subtitle: '2025年推計',
                child: Column(
                  children: dashboard.distressStatistics
                      .map(
                        (item) => _DistressRow(
                          label: item.label,
                          count: item.count,
                          maxCount: dashboard.distressStatistics
                              .map((e) => e.count)
                              .reduce((a, b) => a > b ? a : b),
                        ),
                      )
                      .toList(),
                ),
              ),

              _DashboardSection(
                title: 'エネルギーは自分の国でまかなえている？',
                subtitle: '2000年 → 2025年',
                footnote:
                    'エネルギー自給率 '
                    '${dashboard.energySelfSufficiency.last.selfSufficiencyRate.toStringAsFixed(1)}%'
                    '（主要国の中でも低水準）',
                child: SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: energyInterval,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppColors.border,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: energyInterval,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final idx = value.round();
                              if (idx < 0 ||
                                  idx >=
                                      dashboard.energySelfSufficiency.length) {
                                return const SizedBox.shrink();
                              }
                              final year =
                                  dashboard.energySelfSufficiency[idx].year;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '$year',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: dashboard.energySelfSufficiency
                              .asMap()
                              .entries
                              .map(
                                (e) => FlSpot(
                                  e.key.toDouble(),
                                  e.value.selfSufficiencyRate,
                                ),
                              )
                              .toList(),
                          isCurved: true,
                          color: AppColors.pensionOrange,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.pensionOrange.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              _DashboardSection(
                title: '医療費はどれだけ増えている？',
                subtitle: '2000年 → 2025年 国民医療費',
                footnote:
                    '${dashboard.healthcareCostTrend.first.totalCost.toStringAsFixed(1)}兆円 → '
                    '${dashboard.healthcareCostTrend.last.totalCost.toStringAsFixed(1)}兆円',
                child: SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: healthcareInterval,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppColors.border,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: healthcareInterval,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toStringAsFixed(0)}兆',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final idx = value.round();
                              if (idx < 0 ||
                                  idx >= dashboard.healthcareCostTrend.length) {
                                return const SizedBox.shrink();
                              }
                              final year =
                                  dashboard.healthcareCostTrend[idx].year;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '$year',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: dashboard.healthcareCostTrend
                              .asMap()
                              .entries
                              .map(
                                (e) =>
                                    FlSpot(e.key.toDouble(), e.value.totalCost),
                              )
                              .toList(),
                          isCurved: true,
                          color: AppColors.careGreen,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.careGreen.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RankingScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.leaderboard, size: 18),
                label: const Text('週刊 課題ランキングを見る'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const QuizScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        const Icon(Icons.quiz, color: Colors.white, size: 28),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'あなたの感覚、実際とズレてる？',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const Text(
                                'ギャップクイズで診断してみよう',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Text('☕', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '広告なしで運営しています',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '気に入ったら寄付で応援いただけると嬉しいです',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DonationScreen(),
                          ),
                        );
                      },
                      child: const Text('応援する'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChallengeListScreen(),
                ),
              );
            },
            icon: const Icon(Icons.how_to_vote),
            label: const Text('課題に投票する'),
          ),
        ),
      ),
    );
  }

  Color _budgetColor(int index) {
    const colors = [
      AppColors.pensionOrange,
      AppColors.textSecondary,
      AppColors.debtRed,
      AppColors.careGreen,
      AppColors.populationBlue,
      AppColors.politicsPurple,
    ];
    return colors[index % colors.length];
  }
}

/// 見出し・補足・グラフをひとまとめにする共通カード
class _DashboardSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final String? footnote;

  const _DashboardSection({
    required this.title,
    required this.subtitle,
    required this.child,
    this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
          if (footnote != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              footnote!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String label;
  final double percentage;
  final double amount;
  final Color color;

  const _BudgetRow({
    required this.label,
    required this.percentage,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 56,
            child: Text(
              '¥${amount.toStringAsFixed(1)}兆',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistressRow extends StatelessWidget {
  final String label;
  final double count;
  final double maxCount;

  const _DistressRow({
    required this.label,
    required this.count,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 13)),
              ),
              Text(
                '${count.toStringAsFixed(1)}百万人',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / maxCount,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation(AppColors.pensionOrange),
            ),
          ),
        ],
      ),
    );
  }
}
