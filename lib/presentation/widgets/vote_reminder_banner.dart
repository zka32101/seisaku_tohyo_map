import 'package:flutter/material.dart';

import '../../infrastructure/local_storage/activity_store.dart';
import '../navigation/navigation_helpers.dart';
import '../screens/challenge_list_screen.dart';
import '../theme/app_theme.dart';

/// 投票ストリークが継続中で、今日はまだ投票していない場合に表示するリマインドバナー。
/// 「ストリークを途切れさせたくない」という損失回避の心理を利用し、
/// 継続利用を後押しする。
class VoteReminderBanner extends StatelessWidget {
  const VoteReminderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ActivityStore();
    final streak = store.voteStreakDays;
    final votedToday = store.hasVotedToday;

    if (votedToday || streak <= 0) return const SizedBox.shrink();

    return Material(
      color: AppColors.pensionOrange.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppRadius.badge),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.badge),
        onTap: () => context.pushScreenWithTransition(
          const ChallengeListScreen(),
          screenName: 'ChallengeList',
        ),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.badge),
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$streak日連続記録中！今日はまだ投票していません',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
