import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../application/providers/firebase_provider.dart';
import '../../application/providers/proposal_provider.dart';
import '../../application/usecases/load_diet_bills.dart';
import '../../application/usecases/load_issue_advocates.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/activity_stats.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/user_proposal.dart';
import '../../infrastructure/analytics/analytics_service.dart';
import '../../infrastructure/local_storage/activity_store.dart';
import '../../infrastructure/providers/user_preferences_provider.dart';
import '../navigation/navigation_helpers.dart';
import '../theme/app_theme.dart';
import '../widgets/prefecture_picker.dart';
import '../widgets/submission_status_badge.dart';
import 'about_screen.dart';
import 'challenge_detail_screen.dart';
import 'interest_setup_screen.dart';
import 'vote_memo_journal_screen.dart';

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
          const _ReplyNotificationBanner(),
          const _WeeklyDigestCard(),
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
          const SizedBox(height: AppSpacing.md),
          const _ThemeModeSettingRow(),
          const SizedBox(height: AppSpacing.md),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.badge),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.badge),
              onTap: () => context.pushScreenWithTransition(
                const InterestSetupScreen(),
                screenName: 'InterestSetup',
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
                      Icons.interests_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('興味分野を編集', style: TextStyle(fontSize: 13)),
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
          const SizedBox(height: AppSpacing.md),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.badge),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.badge),
              onTap: () => context.pushScreenWithTransition(
                const VoteMemoJournalScreen(),
                screenName: 'VoteMemoJournal',
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
                      Icons.menu_book_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('投票の記録を見る', style: TextStyle(fontSize: 13)),
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
          const SizedBox(height: AppSpacing.lg),
          _StatsGrid(stats: stats),
          const SizedBox(height: AppSpacing.lg),
          challengesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
            data: (challenges) => _CategoryRadarCard(
              votedChallenges: challenges
                  .where((c) => votedChallengeIds.contains(c.id))
                  .toList(),
            ),
          ),
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
                        challengeId: c.id,
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
          challengesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
            data: (challenges) => _FollowedChallengesSection(
              allChallenges: challenges,
              followedIds: ActivityStore().followedChallengeIds,
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

/// 表示テーマ（システムに合わせる/ライト/ダーク）の設定行。
class _ThemeModeSettingRow extends ConsumerWidget {
  const _ThemeModeSettingRow();

  static const _options = {
    'system': ('端末に合わせる', Icons.brightness_auto),
    'light': ('ライト', Icons.light_mode_outlined),
    'dark': ('ダーク', Icons.dark_mode_outlined),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeProvider).valueOrNull ?? 'system';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.palette_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          const Text('表示テーマ', style: TextStyle(fontSize: 13)),
          const Spacer(),
          SegmentedButton<String>(
            showSelectedIcon: false,
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            segments: _options.entries
                .map(
                  (e) => ButtonSegment(
                    value: e.key,
                    icon: Icon(e.value.$2, size: 16),
                    tooltip: e.value.$1,
                  ),
                )
                .toList(),
            selected: {current},
            onSelectionChanged: (selection) async {
              final mode = selection.first;
              await ref.read(themeModeProvider.notifier).setThemeMode(mode);
            },
          ),
        ],
      ),
    );
  }
}

/// 自分のコメントに新しい返信が付いていないか確認し、件数バッジで知らせる。
/// タップすると全て確認済みにする（返信元のコメントへ個別に飛ぶ仕組みは無いため、
/// 通知に気づいたらコメントした課題を見に行ってもらう形にしている）。
class _ReplyNotificationBanner extends ConsumerWidget {
  const _ReplyNotificationBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unseenAsync = ref.watch(myUnseenReplyCountProvider);
    final unseen = unseenAsync.valueOrNull ?? 0;
    if (unseen == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: () async {
            await markAllRepliesSeen(ref);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.forum, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'あなたのコメントに$unseen件の新しい返信があります',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Text(
                  '確認済みにする',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 直近7日間の活動（投票・コメント・クイズ）をまとめて振り返れるダイジェストカード。
/// 継続利用の動機付けのため、ストリークカードの近くに表示する。
class _WeeklyDigestCard extends StatelessWidget {
  const _WeeklyDigestCard();

  @override
  Widget build(BuildContext context) {
    final counts = ActivityStore().weeklyActivityCounts;
    final voteCount = counts['vote'] ?? 0;
    final commentCount = counts['comment'] ?? 0;
    final quizCount = counts['quiz'] ?? 0;
    final total = voteCount + commentCount + quizCount;
    if (total == 0) return const SizedBox.shrink();

    final parts = [
      if (voteCount > 0) '投票 $voteCount回',
      if (commentCount > 0) 'コメント $commentCount件',
      if (quizCount > 0) 'クイズ $quizCount回',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今週の活動',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  Text(
                    parts.join(' ・ '),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            const Spacer(),
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.badge),
              onTap: () => _share(delivered),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.ios_share,
                  size: 16,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...delivered.map(
          (c) => _MiniChallengeRow(
            challengeId: c.id,
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

  Future<void> _share(List<Challenge> delivered) async {
    final lines = delivered.map((c) => '・${c.name}').join('\n');
    final text =
        '政策投票マップで賛同した課題のうち、${delivered.length}件で実際に国会審議や'
        '協力団体の動きがありました。\n\n$lines\n\nあなたも声を届けてみませんか？';
    try {
      await Share.share(text);
      AnalyticsService().logContentShared(contentType: 'voice_delivered');
    } catch (_) {
      // シェアシートのキャンセル等は無視する
    }
  }
}

/// フォロー中の課題を一覧表示し、国会・協力団体の動きがあるかどうかを示す。
/// アプリは静的なデータセットを使っているため、リアルタイムのプッシュ通知は
/// 送れない（新着があったことを検知する仕組みがない）。その代わり、
/// マイページを開くたびに最新の状況をここで確認できるようにしている。
class _FollowedChallengesSection extends StatelessWidget {
  final List<Challenge> allChallenges;
  final Set<String> followedIds;

  const _FollowedChallengesSection({
    required this.allChallenges,
    required this.followedIds,
  });

  @override
  Widget build(BuildContext context) {
    if (followedIds.isEmpty) return const SizedBox.shrink();
    final followed = allChallenges
        .where((c) => followedIds.contains(c.id))
        .toList();
    if (followed.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.notifications_active_outlined,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            const Text(
              'フォロー中の課題',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 6),
            Text(
              '${followed.length}件',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...followed.map((c) {
          final hasActivity =
              LoadDietBills.forChallenge(c.id).isNotEmpty ||
              LoadIssueAdvocates.forChallenge(c.id).isNotEmpty;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniChallengeRow(
                challengeId: c.id,
                title: c.name,
                category: c.category,
                onTap: () => context.pushScreenWithTransition(
                  ChallengeDetailScreen(challenge: c),
                  screenName: 'ChallengeDetail',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  bottom: AppSpacing.xs,
                ),
                child: Text(
                  hasActivity ? '🔔 国会・協力団体の動きがあります' : '動きはまだありません',
                  style: TextStyle(
                    fontSize: 11,
                    color: hasActivity
                        ? AppColors.success
                        : AppColors.textMuted,
                    fontWeight: hasActivity
                        ? FontWeight.w700
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

/// 賛同した課題のカテゴリ内訳をレーダーチャートで可視化する。
/// 全国平均などの比較データは存在しないため、あくまで自分自身の
/// 関心分野の偏りを振り返るための個人向けグラフ。
class _CategoryRadarCard extends StatelessWidget {
  final List<Challenge> votedChallenges;

  const _CategoryRadarCard({required this.votedChallenges});

  static const _categories = [
    'economy',
    'welfare',
    'demographic',
    'politics',
    'debt',
    'structural',
  ];

  @override
  Widget build(BuildContext context) {
    final counts = {for (final cat in _categories) cat: 0};
    for (final c in votedChallenges) {
      if (counts.containsKey(c.category)) {
        counts[c.category] = counts[c.category]! + 1;
      }
    }
    final maxCount = counts.values.fold(0, (a, b) => a > b ? a : b);
    if (maxCount == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'あなたの関心分野',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const Text(
            '賛同した課題のカテゴリ内訳',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 220,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                radarBackgroundColor: Colors.transparent,
                radarBorderData: const BorderSide(color: AppColors.border),
                gridBorderData: const BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
                tickBorderData: const BorderSide(color: Colors.transparent),
                tickCount: maxCount.clamp(1, 4),
                ticksTextStyle: const TextStyle(
                  color: Colors.transparent,
                  fontSize: 0,
                ),
                titleTextStyle: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                getTitle: (index, angle) => RadarChartTitle(
                  text: AppColors.categoryLabel(_categories[index]),
                ),
                dataSets: [
                  RadarDataSet(
                    fillColor: AppColors.primary.withValues(alpha: 0.2),
                    borderColor: AppColors.primary,
                    borderWidth: 2,
                    entryRadius: 3,
                    dataEntries: _categories
                        .map((c) => RadarEntry(value: counts[c]!.toDouble()))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

class _MiniChallengeRow extends StatefulWidget {
  final String challengeId;
  final String title;
  final String category;
  final VoidCallback onTap;

  const _MiniChallengeRow({
    required this.challengeId,
    required this.title,
    required this.category,
    required this.onTap,
  });

  @override
  State<_MiniChallengeRow> createState() => _MiniChallengeRowState();
}

class _MiniChallengeRowState extends State<_MiniChallengeRow> {
  Future<void> _editMemo() async {
    final controller = TextEditingController(
      text: ActivityStore().voteMemoFor(widget.challengeId) ?? '',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('投票メモ'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 100,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'なぜこの課題に賛同したか、あとで振り返るための一言メモ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(''),
            child: const Text('削除'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (result == null) return; // キャンセル
    await ActivityStore().setVoteMemo(widget.challengeId, result);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(widget.category);
    final memo = ActivityStore().voteMemoFor(widget.challengeId);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.badge),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.badge),
        onTap: widget.onTap,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    AppColors.categoryIcon(widget.category),
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                    onTap: _editMemo,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        memo == null
                            ? Icons.edit_note_outlined
                            : Icons.sticky_note_2,
                        size: 16,
                        color: memo == null
                            ? AppColors.textMuted
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              if (memo != null) ...[
                const SizedBox(height: 4),
                Text(
                  memo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                      if (p.submissionStatus != SubmissionStatus.none) ...[
                        const SizedBox(height: 6),
                        SubmissionStatusBadge(proposal: p),
                      ],
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
