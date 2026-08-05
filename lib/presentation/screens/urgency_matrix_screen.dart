import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/firebase_provider.dart';
import '../../application/usecases/load_urgency_importance.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/urgency_importance.dart';
import '../theme/app_theme.dart';
import 'age_input_screen.dart';
import 'challenge_detail_screen.dart';

/// 緊急重要マトリクス（アイゼンハワー・マトリクス）
///
/// 日本にとっての課題を「緊急度」「重要度」の2軸で4象限にマッピングし、
/// どの課題から向き合うべきかの優先順位を直感的につかめるようにする。
/// 各チップをタップすると課題詳細画面に遷移する。
class UrgencyMatrixScreen extends ConsumerWidget {
  const UrgencyMatrixScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(challengesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('緊急重要マトリクス')),
      body: challengesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
        data: (challenges) {
          final byId = {for (final c in challenges) c.id: c};
          final grouped = <UrgencyQuadrant, List<Challenge>>{
            for (final q in UrgencyQuadrant.values) q: [],
          };
          for (final item in LoadUrgencyImportance.all()) {
            final challenge = byId[item.challengeId];
            if (challenge == null) continue;
            grouped[item.quadrant]!.add(challenge);
          }
          for (final list in grouped.values) {
            list.sort((a, b) => b.voteCount.compareTo(a.voteCount));
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Center(
                child: Image.asset(
                  'assets/images/urgency_matrix_header.png',
                  height: 88,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                '「緊急度」×「重要度」の2軸で、日本の課題を4つに整理しました。'
                'タップすると詳細を見られます。',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: AppSpacing.lg),
              _QuadrantCard(
                title: '今すぐ向き合うべき',
                subtitle: '緊急 × 重要',
                icon: Icons.priority_high,
                color: AppColors.danger,
                challenges: grouped[UrgencyQuadrant.doNow]!,
              ),
              const SizedBox(height: AppSpacing.md),
              _QuadrantCard(
                title: '計画的に取り組むべき',
                subtitle: '重要 × 緊急ではない',
                icon: Icons.event_note,
                color: AppColors.primary,
                challenges: grouped[UrgencyQuadrant.plan]!,
              ),
              const SizedBox(height: AppSpacing.md),
              _QuadrantCard(
                title: '対応は必要（影響は限定的）',
                subtitle: '緊急 × 重要ではない',
                icon: Icons.schedule,
                color: AppColors.pensionOrange,
                challenges: grouped[UrgencyQuadrant.delegate]!,
              ),
              const SizedBox(height: AppSpacing.md),
              _QuadrantCard(
                title: '相対的に優先度は低い',
                subtitle: '緊急ではない × 重要ではない',
                icon: Icons.low_priority,
                color: AppColors.textMuted,
                challenges: grouped[UrgencyQuadrant.later]!,
              ),
              const SizedBox(height: AppSpacing.md),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  '※ 緊急度・重要度は運営による定性的な目安です。一次データによる機械的な算出値ではありません。',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          );
        },
      ),
    );
  }
}

class _QuadrantCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Challenge> challenges;

  const _QuadrantCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.challenges,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${challenges.length}件',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (challenges.isEmpty)
            const Text(
              '該当する課題はありません',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: challenges
                  .map((c) => _ChallengeChip(challenge: c, color: color))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ChallengeChip extends StatelessWidget {
  final Challenge challenge;
  final Color color;

  const _ChallengeChip({required this.challenge, required this.color});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(challenge.name, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        if (challenge.id == 'my_pension_balance') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AgeInputScreen()),
          );
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChallengeDetailScreen(challenge: challenge),
          ),
        );
      },
      backgroundColor: Colors.white,
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
