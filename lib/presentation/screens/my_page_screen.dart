import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/firebase_provider.dart';
import '../../application/providers/proposal_provider.dart';
import '../../application/usecases/load_diet_bills.dart';
import '../../application/usecases/load_issue_advocates.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/activity_stats.dart';
import '../../domain/entities/challenge.dart';
import '../../infrastructure/local_storage/activity_store.dart';
import '../navigation/navigation_helpers.dart';
import '../theme/app_theme.dart';
import '../widgets/prefecture_picker.dart';
import 'about_screen.dart';
import 'challenge_detail_screen.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ActivityStore().currentStats();
    final unlocked = Achievements.all
        .where((a) => a.isUnlockedBy(stats))
        .toList();

    final challengesAsync = ref.watch(challengesProvider);
    final votedChallengeIds = ActivityStore().votedChallengeIds;
    final selectedPrefecture = ref.watch(selectedPrefectureProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('マイページ')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _StreakCard(stats: stats),
          const SizedBox(height: AppSpacing.md),
          _PrefectureSettingRow(
            selected: selectedPrefecture,
            onTap: () async {
              final picked = await showPrefecturePicker(context);
              if (picked != null) {
                await ActivityStore().setSelectedPrefecture(picked);
                ref.read(selectedPrefectureProvider.notifier).state = picked;
              }
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _StatsGrid(stats: stats),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Text(
                '実績バッジ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 6),
              Text(
                '${unlocked.length}/${Achievements.all.length}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.85,
            children: Achievements.all
                .map(
                  (a) => _AchievementBadge(
                    achievement: a,
                    unlocked: a.isUnlockedBy(stats),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'あなたが賛同した課題',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          challengesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Text(
              '読み込めませんでした',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            data: (challenges) {
              final voted = challenges
                  .where((c) => votedChallengeIds.contains(c.id))
                  .toList();
              if (voted.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    'まだ賛同した課題がありません',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                );
              }
              return Column(
                children: voted
                    .map(
                      (c) => _MiniChallengeRow(
                        title: c.name,
                        category: c.category,
                        onTap: () => context.pushScreenWithTransition(
                          ChallengeDetailScreen(challenge: c),
                          screenName: 'ChallengeDetail',
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          challengesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
            data: (challenges) => _VoiceDeliveredSection(
              votedChallenges: challenges
                  .where((c) => votedChallengeIds.contains(c.id))
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'あなたが提案した課題',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          _MySubmittedProposals(),
          const SizedBox(height: AppSpacing.lg),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.badge),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.badge),
              onTap: () => context.pushScreenWithTransition(
                const AboutScreen(),
                screenName: 'About',
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('このアプリについて', style: TextStyle(fontSize: 13)),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 連続投票日数（ストリーク）を目立たせて表示するカード。
/// 継続利用の動機付けのため、マイページ最上部に常時表示する。
class _StreakCard extends StatelessWidget {
  final ActivityStats stats;

  const _StreakCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final streak = stats.voteStreakDays;
    final hasStreak = streak > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: hasStreak ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: hasStreak ? null : Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(hasStreak ? '🔥' : '💤', style: const TextStyle(fontSize: 32)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasStreak ? '$streak日連続で投票中' : '今日から投票を始めよう',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: hasStreak ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                if (stats.longestVoteStreak > 0)
                  Text(
                    '最長記録: ${stats.longestVoteStreak}日',
                    style: TextStyle(
                      fontSize: 11,
                      color: hasStreak ? Colors.white70 : AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// お住まいの都道府県設定行。ランキング画面の「地域」タブでの
/// パーソナライズ表示に使う。
class _PrefectureSettingRow extends StatelessWidget {
  final String? selected;
  final VoidCallback onTap;

  const _PrefectureSettingRow({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.badge),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.badge),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.badge),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selected == null ? 'お住まいの都道府県を設定する' : selected!,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 自分が賛同した課題のうち、国会での動き（法案審議）や協力団体の活動など、
/// 実際に「声が届いている」ことが確認できるものをハイライトするセクション。
class _VoiceDeliveredSection extends StatelessWidget {
  final List<Challenge> votedChallenges;

  const _VoiceDeliveredSection({required this.votedChallenges});

  @override
  Widget build(BuildContext context) {
    final delivered = votedChallenges.where((c) {
      return LoadDietBills.forChallenge(c.id).isNotEmpty ||
          LoadIssueAdvocates.forChallenge(c.id).isNotEmpty;
    }).toList();

    if (delivered.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.campaign, size: 16, color: AppColors.success),
            const SizedBox(width: 6),
            const Text(
              'あなたの声が届いています',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 6),
            Text(
              '${delivered.length}件',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...delivered.map(
          (c) => _MiniChallengeRow(
            title: c.name,
            category: c.category,
            onTap: () => context.pushScreenWithTransition(
              ChallengeDetailScreen(challenge: c),
              screenName: 'ChallengeDetail',
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final ActivityStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('賛同した課題', stats.votedChallengeCount, Icons.how_to_vote),
      ('選んだ対策案', stats.policyVoteCount, Icons.checklist),
      ('投稿したコメント', stats.commentsPostedCount, Icons.forum),
      ('完了したクイズ', stats.quizzesCompletedCount, Icons.quiz),
      ('提案した課題', stats.submittedProposalCount, Icons.campaign),
      ('応援した提案', stats.votedProposalCount, Icons.thumb_up),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.4,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(item.$3, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.$2}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          item.$1,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;

  const _AchievementBadge({required this.achievement, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.primaryLight : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: unlocked ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: unlocked ? 1 : 0.3,
            child: Text(
              achievement.emoji,
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: unlocked ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChallengeRow extends StatelessWidget {
  final String title;
  final String category;
  final VoidCallback onTap;

  const _MiniChallengeRow({
    required this.title,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(category);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.badge),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.badge),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.badge),
          ),
          child: Row(
            children: [
              Icon(AppColors.categoryIcon(category), size: 14, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 13)),
              ),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MySubmittedProposals extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsAsync = ref.watch(proposalsProvider);
    final submittedIds = ActivityStore().submittedProposalIds;

    return proposalsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Text(
        '読み込めませんでした',
        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      data: (proposals) {
        final mine = proposals
            .where((p) => submittedIds.contains(p.id))
            .toList();
        if (mine.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              'まだ提案していません',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          );
        }
        return Column(
          children: mine
              .map(
                (p) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.title,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        '${p.voteCount}票',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
