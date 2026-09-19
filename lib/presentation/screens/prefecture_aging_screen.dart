import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/firebase_provider.dart';
import '../../application/usecases/load_prefecture_aging_stats.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/prefecture_aging_stat.dart';
import '../theme/app_theme.dart';
import 'challenge_detail_screen.dart';

/// 都道府県別の高齢化率ランキング画面（過疎・高齢化の実態を、関連する課題とあわせて見る）
class PrefectureAgingScreen extends ConsumerWidget {
  const PrefectureAgingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(challengesProvider);
    final sorted = [...LoadPrefectureAgingStats.all]
      ..sort((a, b) => b.agingRatePercent.compareTo(a.agingRatePercent));
    final maxRate = sorted.first.agingRatePercent;

    return Scaffold(
      appBar: AppBar(title: const Text('過疎・高齢化の実態')),
      body: challengesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
        data: (challenges) {
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sorted.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const _IntroCard();
              }
              if (index == sorted.length + 1) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    '出典: ${LoadPrefectureAgingStats.sourceLabel}',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                );
              }
              final stat = sorted[index - 1];
              final relatedIds = LoadPrefectureAgingStats.relatedChallengeIds(
                stat,
              );
              final related = challenges
                  .where((c) => relatedIds.contains(c.id))
                  .toList();
              return _PrefectureRow(
                rank: index,
                stat: stat,
                maxRate: maxRate,
                relatedChallenges: related,
              );
            },
          );
        },
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '65歳以上人口の割合（高齢化率）が高い順に並べています',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            '高齢化が進む地域ほど、介護・地域医療・地方財政などの課題が深刻になりやすい傾向があります。'
            '都道府県をタップすると、関連する課題を確認できます。',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrefectureRow extends StatelessWidget {
  final int rank;
  final PrefectureAgingStat stat;
  final double maxRate;
  final List<Challenge> relatedChallenges;

  const _PrefectureRow({
    required this.rank,
    required this.stat,
    required this.maxRate,
    required this.relatedChallenges,
  });

  Color get _barColor {
    if (stat.agingRatePercent >= 33.7) return AppColors.debtRed;
    if (stat.agingRatePercent <= 28.6) return AppColors.populationBlue;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  stat.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${stat.agingRatePercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stat.agingRatePercent / maxRate,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation(_barColor),
            ),
          ),
          if (relatedChallenges.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: relatedChallenges
                  .map(
                    (c) => ActionChip(
                      label: Text(c.name, style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppColors.categoryColor(
                        c.category,
                      ).withValues(alpha: 0.1),
                      side: BorderSide.none,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ChallengeDetailScreen(challenge: c),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
