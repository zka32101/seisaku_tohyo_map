import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../application/providers/policy_simulation_provider.dart';
import '../../domain/entities/policy_scenario.dart';
import '../theme/app_theme.dart';
import '../widgets/chart_axis.dart';
import 'glossary_screen.dart';

const _policyColors = {
  PolicyType.baseline: AppColors.textMuted,
  PolicyType.policyA: AppColors.debtRed,
  PolicyType.policyB: AppColors.populationBlue,
  PolicyType.expert: AppColors.success,
};

const _indicatorLabels = {
  'population': '人口',
  'pension_reserve': '年金積立金',
  'national_debt': '国債残高',
  'healthcare_cost': '医療費',
  'housing_vacancy': '空き家率',
};

class TimeMachineScreen extends ConsumerWidget {
  const TimeMachineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulations = ref.watch(policySimulationsProvider);
    final simulation = ref.watch(selectedSimulationProvider);
    final selectedIndicatorId = ref.watch(selectedIndicatorIdProvider);
    final selectedYear = ref.watch(selectedYearProvider);
    final selectedData = simulation.dataForYear(selectedYear);

    return Scaffold(
      appBar: AppBar(
        title: const Text('タイムマシン'),
        actions: [
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '政策によって未来はどう変わる？年を動かして比べてみよう',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.md),

              // 指標セレクター（5指標になり得るため横スクロール対応）
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: simulations
                      .map(
                        (s) => ButtonSegment(
                          value: s.id,
                          label: Text(_indicatorLabels[s.id] ?? s.id),
                        ),
                      )
                      .toList(),
                  selected: {selectedIndicatorId},
                  onSelectionChanged: (selection) {
                    ref.read(selectedIndicatorIdProvider.notifier).state =
                        selection.first;
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Text(
                simulation.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // グラフ
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border),
                ),
                child: SizedBox(
                  height: 240,
                  child: _PolicyChart(
                    simulation: simulation,
                    selectedYear: selectedYear,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 年スライダー
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      '$selectedYear 年',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Slider(
                      value: selectedYear
                          .clamp(simulation.minYear, simulation.maxYear)
                          .toDouble(),
                      min: simulation.minYear.toDouble(),
                      max: simulation.maxYear.toDouble(),
                      divisions: simulation.maxYear - simulation.minYear,
                      label: '$selectedYear',
                      onChanged: (value) {
                        ref.read(selectedYearProvider.notifier).state = value
                            .round();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // シナリオ別の数値カード
              ...PolicyType.values.map(
                (policy) => _ScenarioRow(
                  policy: policy,
                  value: policy.valueAt(selectedData),
                  unit: simulation.unit,
                  baselineValue: selectedData.baseline,
                  lowerIsBetter: simulation.lowerIsBetter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyChart extends StatelessWidget {
  final PolicySimulation simulation;
  final int selectedYear;

  const _PolicyChart({required this.simulation, required this.selectedYear});

  @override
  Widget build(BuildContext context) {
    final selectedIndex =
        selectedYear.clamp(simulation.minYear, simulation.maxYear) -
        simulation.minYear;

    final allValues = simulation.yearData
        .expand((d) => PolicyType.values.map((p) => p.valueAt(d)))
        .toList();
    final interval = niceAxisInterval(
      allValues.reduce((a, b) => a < b ? a : b),
      allValues.reduce((a, b) => a > b ? a : b),
    );
    final unit = simulation.unit.split('（').first.split('(').first.trim();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: interval,
              getTitlesWidget: (value, meta) => Text(
                '${value.toStringAsFixed(0)}$unit',
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
              interval: 10,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= simulation.yearData.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${simulation.yearData[idx].year}',
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
        extraLinesData: ExtraLinesData(
          verticalLines: [
            VerticalLine(
              x: selectedIndex.toDouble(),
              color: AppColors.primary.withValues(alpha: 0.4),
              strokeWidth: 2,
              dashArray: [4, 4],
            ),
          ],
        ),
        lineBarsData: PolicyType.values.map((policy) {
          return LineChartBarData(
            spots: simulation.yearData
                .asMap()
                .entries
                .map<FlSpot>(
                  (e) => FlSpot(e.key.toDouble(), policy.valueAt(e.value)),
                )
                .toList(),
            isCurved: true,
            color: _policyColors[policy],
            barWidth: policy == PolicyType.baseline ? 2 : 3,
            dotData: const FlDotData(show: false),
            dashArray: policy == PolicyType.baseline ? [4, 3] : null,
          );
        }).toList(),
      ),
    );
  }
}

class _ScenarioRow extends StatelessWidget {
  final PolicyType policy;
  final double value;
  final String unit;
  final double baselineValue;
  final bool lowerIsBetter;

  const _ScenarioRow({
    required this.policy,
    required this.value,
    required this.unit,
    required this.baselineValue,
    required this.lowerIsBetter,
  });

  @override
  Widget build(BuildContext context) {
    final isBaseline = policy == PolicyType.baseline;
    final diff = value - baselineValue;
    final isImprovement = lowerIsBetter ? diff < 0 : diff > 0;
    final color = _policyColors[policy]!;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              policy.label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          if (!isBaseline) ...[
            const SizedBox(width: 6),
            Text(
              '(${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isImprovement ? AppColors.success : AppColors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
