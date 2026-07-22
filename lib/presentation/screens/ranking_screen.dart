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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('週刊 ランキング'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '課題'),
              Tab(text: '対策案'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_ChallengeRankingTab(), _PolicyOptionRankingTab()],
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
