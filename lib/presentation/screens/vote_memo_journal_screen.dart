import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/firebase_provider.dart';
import '../../domain/entities/challenge.dart';
import '../../infrastructure/local_storage/activity_store.dart';
import '../navigation/navigation_helpers.dart';
import '../theme/app_theme.dart';
import 'challenge_detail_screen.dart';

/// これまでに書いた投票メモを新しい順に振り返れる「投票の記録」画面。
/// メモは端末ローカル保存のため、他ユーザーには見えない自分だけの記録。
class VoteMemoJournalScreen extends ConsumerWidget {
  const VoteMemoJournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(challengesProvider);
    final memos = ActivityStore().voteMemos;

    return Scaffold(
      appBar: AppBar(title: const Text('投票の記録')),
      body: challengesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(
          child: Text('読み込めませんでした', style: TextStyle(fontSize: 12)),
        ),
        data: (challenges) {
          if (memos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'まだメモがありません。\n賛同した課題の一覧で📝アイコンから\n一言メモを残せます',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ),
            );
          }

          final challengeById = {for (final c in challenges) c.id: c};
          final entries = memos.keys.toList()
            ..sort((a, b) {
              final aTime = ActivityStore().voteMemoUpdatedAt(a);
              final bTime = ActivityStore().voteMemoUpdatedAt(b);
              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return 1;
              if (bTime == null) return -1;
              return bTime.compareTo(aTime);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final challengeId = entries[index];
              final challenge = challengeById[challengeId];
              final memo = memos[challengeId]!;
              final updatedAt = ActivityStore().voteMemoUpdatedAt(challengeId);
              return _MemoEntryCard(
                challenge: challenge,
                memo: memo,
                updatedAt: updatedAt,
              );
            },
          );
        },
      ),
    );
  }
}

class _MemoEntryCard extends StatelessWidget {
  final Challenge? challenge;
  final String memo;
  final DateTime? updatedAt;

  const _MemoEntryCard({
    required this.challenge,
    required this.memo,
    required this.updatedAt,
  });

  static const _months = [
    '',
    '1月',
    '2月',
    '3月',
    '4月',
    '5月',
    '6月',
    '7月',
    '8月',
    '9月',
    '10月',
    '11月',
    '12月',
  ];

  String _formatDate(DateTime d) => '${d.year}年${_months[d.month]}${d.day}日';

  @override
  Widget build(BuildContext context) {
    final color = challenge == null
        ? AppColors.textMuted
        : AppColors.categoryColor(challenge!.category);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: challenge == null
            ? null
            : () => context.pushScreenWithTransition(
                ChallengeDetailScreen(challenge: challenge!),
                screenName: 'ChallengeDetail',
              ),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (challenge != null)
                    Icon(
                      AppColors.categoryIcon(challenge!.category),
                      size: 14,
                      color: color,
                    ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      challenge?.name ?? '削除された課題',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (updatedAt != null)
                    Text(
                      _formatDate(updatedAt!),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                memo,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
