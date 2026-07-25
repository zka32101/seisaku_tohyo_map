import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/firebase_provider.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/policy_option.dart';
import '../theme/app_theme.dart';
import 'challenge_detail_screen.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('週刊 ランキング'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '課題'),
              Tab(text: '対策案'),
              Tab(text: 'マップ'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ChallengeRankingTab(),
            _PolicyOptionRankingTab(),
            _ChallengeMapTab(),
          ],
        ),
      ),
    );
  }
}

class _ChallengeRankingTab extends ConsumerWidget {
  const _ChallengeRankingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(challengesProvider);

    return challengesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('エラー: $err')),
      data: (challenges) {
        final ranked = [...challenges]
          ..sort((a, b) => b.voteCount.compareTo(a.voteCount));

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: ranked.length,
          itemBuilder: (context, index) {
            return _ChallengeRankingRow(
              rank: index + 1,
              challenge: ranked[index],
            );
          },
        );
      },
    );
  }
}

class _ChallengeRankingRow extends StatelessWidget {
  final int rank;
  final Challenge challenge;

  const _ChallengeRankingRow({required this.rank, required this.challenge});

  static const _medals = {1: '🥇', 2: '🥈', 3: '🥉'};

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(challenge.category);
    final isTop3 = rank <= 3;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChallengeDetailScreen(challenge: challenge),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isTop3 ? color : AppColors.border,
              width: isTop3 ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  _medals[rank] ?? '$rank',
                  style: TextStyle(
                    fontSize: isTop3 ? 22 : 15,
                    fontWeight: FontWeight.w800,
                    color: isTop3 ? null : AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppColors.categoryLabel(challenge.category),
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${challenge.voteCount}票',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '賛同 ${challenge.agreeCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyOptionRankingTab extends ConsumerWidget {
  const _PolicyOptionRankingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(allPolicyOptionsProvider);
    final challengesAsync = ref.watch(challengesProvider);

    if (challengesAsync.isLoading || optionsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final challenges = challengesAsync.valueOrNull;
    final options = optionsAsync.valueOrNull;
    if (challenges == null || options == null) {
      return const Center(child: Text('エラーが発生しました'));
    }

    final challengeById = {for (final c in challenges) c.id: c};
    final ranked = [...options]
      ..sort((a, b) => b.voteCount.compareTo(a.voteCount));

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: ranked.length,
      itemBuilder: (context, index) {
        final option = ranked[index];
        final challenge = challengeById[option.challengeId];
        if (challenge == null) return const SizedBox.shrink();
        return _PolicyOptionRankingRow(
          rank: index + 1,
          option: option,
          challenge: challenge,
        );
      },
    );
  }
}

class _PolicyOptionRankingRow extends StatelessWidget {
  final int rank;
  final PolicyOption option;
  final Challenge challenge;

  const _PolicyOptionRankingRow({
    required this.rank,
    required this.option,
    required this.challenge,
  });

  static const _medals = {1: '🥇', 2: '🥈', 3: '🥉'};

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(challenge.category);
    final isTop3 = rank <= 3;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChallengeDetailScreen(challenge: challenge),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isTop3 ? color : AppColors.border,
              width: isTop3 ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  _medals[rank] ?? '$rank',
                  style: TextStyle(
                    fontSize: isTop3 ? 22 : 15,
                    fontWeight: FontWeight.w800,
                    color: isTop3 ? null : AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      challenge.name,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '${option.voteCount}票',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MapMode { attention, budget }

/// 課題を「投票数（ランキング）」だけでなく、注目度（賛同率×投票数）や
/// 予算規模との組み合わせで俯瞰できる散布図マップ
class _ChallengeMapTab extends ConsumerStatefulWidget {
  const _ChallengeMapTab();

  @override
  ConsumerState<_ChallengeMapTab> createState() => _ChallengeMapTabState();
}

class _ChallengeMapTabState extends ConsumerState<_ChallengeMapTab> {
  _MapMode _mode = _MapMode.attention;

  @override
  Widget build(BuildContext context) {
    final challengesAsync = ref.watch(challengesProvider);

    return challengesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('エラー: $err')),
      data: (challenges) {
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            SegmentedButton<_MapMode>(
              segments: const [
                ButtonSegment(
                  value: _MapMode.attention,
                  label: Text('注目度マップ'),
                  icon: Icon(Icons.bubble_chart_outlined, size: 16),
                ),
                ButtonSegment(
                  value: _MapMode.budget,
                  label: Text('予算マップ'),
                  icon: Icon(Icons.account_balance_wallet_outlined, size: 16),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) =>
                  setState(() => _mode = selection.first),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_mode == _MapMode.attention)
              _AttentionMap(challenges: challenges)
            else
              _BudgetMap(challenges: challenges),
          ],
        );
      },
    );
  }
}

/// 「投票数（注目度）」×「賛同率」の2軸で課題を配置するマップ
class _AttentionMap extends StatelessWidget {
  final List<Challenge> challenges;

  const _AttentionMap({required this.challenges});

  @override
  Widget build(BuildContext context) {
    final targets = challenges;
    if (targets.isEmpty) return const SizedBox.shrink();

    final maxVotes = targets
        .map((c) => c.voteCount)
        .fold(0, (a, b) => a > b ? a : b);

    final spots = targets
        .map(
          (c) => ScatterSpot(
            c.voteCount == 0 ? 0 : c.agreeCount / c.voteCount,
            c.voteCount.toDouble(),
            dotPainter: FlDotCirclePainter(
              radius: 6,
              color: AppColors.categoryColor(
                c.category,
              ).withValues(alpha: 0.75),
            ),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '横：賛同率（この課題に投票した人のうち賛同した割合）\n縦：投票数（注目度）',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.fromLTRB(
            4,
            AppSpacing.md,
            AppSpacing.md,
            4,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: SizedBox(
            height: 320,
            child: ScatterChart(
              ScatterChartData(
                minX: 0,
                maxX: 1,
                minY: 0,
                maxY: maxVotes == 0 ? 10 : maxVotes * 1.15,
                scatterSpots: spots,
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true, drawVerticalLine: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.round()}',
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
                      interval: 0.25,
                      getTitlesWidget: (value, meta) => Text(
                        '${(value * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                scatterTouchData: ScatterTouchData(
                  touchTooltipData: ScatterTouchTooltipData(
                    getTooltipItems: (spot) {
                      final index = spots.indexOf(spot);
                      final challenge = index >= 0 && index < targets.length
                          ? targets[index]
                          : null;
                      return ScatterTooltipItem(
                        challenge?.name ?? '',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    if (event is! FlTapUpEvent) return;
                    final spotIndex = response?.touchedSpot?.spotIndex;
                    if (spotIndex == null ||
                        spotIndex < 0 ||
                        spotIndex >= targets.length) {
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChallengeDetailScreen(
                          challenge: targets[spotIndex],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          '右上ほど「多くの人が注目し、強く賛同している」課題。左下は「まだ知られていないが、'
          '知られれば強く賛同されるかもしれない」課題です。',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// 「関連する国の予算規模」×「投票数（注目度）」で課題を配置するマップ
class _BudgetMap extends StatelessWidget {
  final List<Challenge> challenges;

  const _BudgetMap({required this.challenges});

  @override
  Widget build(BuildContext context) {
    final targets =
        challenges.where((c) => c.budgetTrillionYen != null).toList()..sort(
          (a, b) => a.budgetTrillionYen!.compareTo(b.budgetTrillionYen!),
        );
    if (targets.isEmpty) return const SizedBox.shrink();

    final maxVotes = targets
        .map((c) => c.voteCount)
        .reduce((a, b) => a > b ? a : b);
    final maxBudget = targets
        .map((c) => c.budgetTrillionYen!)
        .reduce((a, b) => a > b ? a : b);
    // 予算規模は数千億円〜約400兆円まで桁が大きく異なるため、横軸は予算の小さい順の並び順とし、
    // 実際の規模の大小は円の面積（budget比率）で表現する
    final spots = <ScatterSpot>[];
    for (var i = 0; i < targets.length; i++) {
      final c = targets[i];
      final budget = c.budgetTrillionYen!;
      final radius = 4 + (budget / maxBudget) * 16;
      spots.add(
        ScatterSpot(
          i.toDouble(),
          c.voteCount.toDouble(),
          dotPainter: FlDotCirclePainter(
            radius: radius,
            color: AppColors.categoryColor(c.category).withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '円の大きさ：関連する国の予算区分の規模（兆円）\n縦：投票数（注目度）',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.fromLTRB(
            4,
            AppSpacing.md,
            AppSpacing.md,
            4,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: SizedBox(
            height: 320,
            child: ScatterChart(
              ScatterChartData(
                minX: -0.5,
                maxX: targets.length - 0.5,
                minY: 0,
                maxY: maxVotes == 0 ? 10 : maxVotes * 1.15,
                scatterSpots: spots,
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.round()}',
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
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.round();
                        if (idx < 0 || idx >= targets.length) {
                          return const SizedBox.shrink();
                        }
                        final budget = targets[idx].budgetTrillionYen!;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            budget >= 1
                                ? '${budget.toStringAsFixed(0)}兆'
                                : '${budget.toStringAsFixed(1)}兆',
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                scatterTouchData: ScatterTouchData(
                  touchTooltipData: ScatterTouchTooltipData(
                    getTooltipItems: (spot) {
                      final index = spots.indexOf(spot);
                      final challenge = index >= 0 && index < targets.length
                          ? targets[index]
                          : null;
                      return ScatterTooltipItem(
                        challenge?.name ?? '',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    if (event is! FlTapUpEvent) return;
                    final spotIndex = response?.touchedSpot?.spotIndex;
                    if (spotIndex == null ||
                        spotIndex < 0 ||
                        spotIndex >= targets.length) {
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChallengeDetailScreen(
                          challenge: targets[spotIndex],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          '予算規模は、課題に関連する国の予算区分（社会保障関係費・防衛関係費など）の規模を'
          '示す参考値です。課題そのものへの予算配分ではなく、出典・時点が確認できた課題のみ'
          '表示しています（財務省・厚労省資料などをもとにしたスナップショット）。',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
