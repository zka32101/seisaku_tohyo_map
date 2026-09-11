import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nihon_future_map/infrastructure/providers/analytics_provider.dart';

/// Personal analytics dashboard screen showing voting patterns and interest analysis
class MyAnalyticsScreen extends ConsumerWidget {
  const MyAnalyticsScreen({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('マイ分析'), centerTitle: true),
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
        data: (analytics) => _buildContent(context, analytics),
      ),
    );
  }

  Widget _buildContent(BuildContext context, analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVotingPatternCard(context, analytics),
          const SizedBox(height: 16),
          _buildInterestAnalysisCard(context, analytics),
          const SizedBox(height: 16),
          _buildVotingScoreCard(context, analytics),
          const SizedBox(height: 16),
          _buildTimeSeriesChart(context, analytics),
        ],
      ),
    );
  }

  Widget _buildVotingPatternCard(BuildContext context, analytics) {
    final categoryCounts = analytics.categoryCounts;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '投票パターン',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (categoryCounts.isEmpty)
              const Center(child: Text('投票データがありません'))
            else
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: categoryCounts.entries
                        .map(
                          (entry) => PieChartSectionData(
                            value: entry.value.toDouble(),
                            title: entry.key,
                            color: _getCategoryColor(entry.key),
                            radius: 50,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestAnalysisCard(BuildContext context, analytics) {
    final trends = analytics.interestTrends;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '関心分野の推移',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (trends.isEmpty)
              const Center(child: Text('トレンドデータがありません'))
            else
              Column(
                children: trends.map((trend) {
                  final change = trend.thisMonthCount - trend.lastMonthCount;
                  final isPositive = change >= 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(trend.category),
                        Row(
                          children: [
                            Text(
                              '${trend.lastMonthCount} → ${trend.thisMonthCount}',
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isPositive
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: isPositive ? Colors.green : Colors.red,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingScoreCard(BuildContext context, analytics) {
    final realizationRate = analytics.realizationRate;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '実現率',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: realizationRate,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${(realizationRate * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSeriesChart(BuildContext context, analytics) {
    final monthlyVoteCounts = analytics.monthlyVoteCounts;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '投票数（3ヶ月推移）',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (monthlyVoteCounts.isEmpty)
              const Center(child: Text('グラフデータがありません'))
            else
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final labels = ['2月前', '1月前', '今月'];
                            final index = value.toInt();
                            return Text(
                              index < labels.length ? labels[index] : '',
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(
                            0,
                            (monthlyVoteCounts['two_months_ago'] ?? 0)
                                .toDouble(),
                          ),
                          FlSpot(
                            1,
                            (monthlyVoteCounts['one_month_ago'] ?? 0)
                                .toDouble(),
                          ),
                          FlSpot(
                            2,
                            (monthlyVoteCounts['this_month'] ?? 0).toDouble(),
                          ),
                        ],
                        isCurved: true,
                        color: const Color(0xFF2563EB),
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '経済・財政':
        return const Color(0xFFF97316);
      case '福祉・医療':
        return const Color(0xFF10B981);
      case '人口・地域':
        return const Color(0xFF3B82F6);
      case '環境・エネルギー':
        return const Color(0xFF8B5CF6);
      case '政治構造':
        return const Color(0xFF0D9488);
      case '教育・科学':
        return const Color(0xFFEC4899);
      case '防衛・外交':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
