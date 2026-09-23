import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/firebase_provider.dart';
import '../../domain/entities/challenge.dart';
import '../../infrastructure/local_storage/activity_store.dart';
import '../navigation/navigation_helpers.dart';
import '../theme/app_theme.dart';
import 'challenge_detail_screen.dart';

enum _EntryType { memo, comment }

class _JournalEntry {
  final _EntryType type;
  final String challengeId;
  final String text;
  final DateTime? timestamp;

  const _JournalEntry({
    required this.type,
    required this.challengeId,
    required this.text,
    required this.timestamp,
  });
}

/// これまでに書いた投票メモと投稿したコメントを、新しい順に振り返れる
/// 「投票の記録」画面。メモは端末ローカル保存、コメントはFirestoreから
/// 取得するが、いずれも自分だけの記録として一つのタイムラインにまとめる。
class VoteMemoJournalScreen extends ConsumerWidget {
  const VoteMemoJournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(challengesProvider);
    final myCommentsAsync = ref.watch(myCommentsTimelineProvider);
    final memos = ActivityStore().voteMemos;

    return Scaffold(
      appBar: AppBar(title: const Text('投票の記録')),
      body: challengesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(
          child: Text('読み込めませんでした', style: TextStyle(fontSize: 12)),
        ),
        data: (challenges) {
          final myComments = myCommentsAsync.valueOrNull ?? const [];

          final entries =
              <_JournalEntry>[
                for (final entry in memos.entries)
                  _JournalEntry(
                    type: _EntryType.memo,
                    challengeId: entry.key,
                    text: entry.value,
                    timestamp: ActivityStore().voteMemoUpdatedAt(entry.key),
                  ),
                for (final comment in myComments)
                  _JournalEntry(
                    type: _EntryType.comment,
                    challengeId: comment.challengeId,
                    text: comment.text,
                    timestamp: comment.createdAt,
                  ),
              ]..sort((a, b) {
                if (a.timestamp == null && b.timestamp == null) return 0;
                if (a.timestamp == null) return 1;
                if (b.timestamp == null) return -1;
                return b.timestamp!.compareTo(a.timestamp!);
              });

          if (entries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'まだ記録がありません。\n賛同した課題の一覧で📝アイコンからメモを残したり、\n'
                  '課題にコメントすると、ここで振り返れます',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ),
            );
          }

          final challengeById = {for (final c in challenges) c.id: c};

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _JournalEntryCard(
                entry: entry,
                challenge: challengeById[entry.challengeId],
              );
            },
          );
        },
      ),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  final _JournalEntry entry;
  final Challenge? challenge;

  const _JournalEntryCard({required this.entry, required this.challenge});

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
    final isMemo = entry.type == _EntryType.memo;

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
                  Icon(
                    isMemo ? Icons.sticky_note_2 : Icons.forum,
                    size: 13,
                    color: isMemo ? AppColors.primary : AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isMemo ? 'メモ' : 'コメント',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isMemo ? AppColors.primary : AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 8),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (entry.timestamp != null)
                    Text(
                      _formatDate(entry.timestamp!),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                entry.text,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontStyle: isMemo ? FontStyle.italic : FontStyle.normal,
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
