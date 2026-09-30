import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/firebase_provider.dart';
import '../../application/usecases/compute_party_match.dart';
import '../../application/usecases/load_party_platforms.dart';
import '../../application/usecases/load_policy_options.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/party_stance.dart';
import '../../infrastructure/local_storage/activity_store.dart';
import '../theme/app_theme.dart';

/// 賛同した課題で選んだ対策案を、主要政党の実際の立場（公式マニフェスト等を
/// 調査したもの）と比較し、一致度を表示する画面。
///
/// 課題への賜同そのものは政党間でほとんど差が出ない（どの政党も「これは
/// 問題だ」とは言うため）ため、実際に立場が分かれる「対策案の選択」を
/// 比較対象にしている。政党の公式見解ではなく簡易的な分析であることを
/// 明示するため、画面上部に注意書きを常時表示する。
class PartyMatchScreen extends ConsumerWidget {
  const PartyMatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(challengesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('政党との政策一致度')),
      body: challengesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(
          child: Text('読み込めませんでした', style: TextStyle(fontSize: 12)),
        ),
        data: (challenges) {
          final challengeById = {for (final c in challenges) c.id: c};
          final results = ComputePartyMatch.call(
            votedChallengeIds: ActivityStore().votedChallengeIds,
            selectedPolicyOptions: ActivityStore().selectedPolicyOptions,
          );
          final hasAnyComparison = results.any((r) => r.comparableCount > 0);

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const _DisclaimerBanner(),
              const SizedBox(height: AppSpacing.md),
              if (!hasAnyComparison)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text(
                    '賛同した課題で対策案を選ぶと、政党との一致度が表示されます。\n'
                    'まずは気になる課題に賛同し、対策案を選んでみましょう。',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                )
              else
                ...results.asMap().entries.map(
                  (entry) => _PartyMatchCard(
                    result: entry.value,
                    challengeById: challengeById,
                    isTopMatch:
                        entry.key == 0 && entry.value.comparableCount > 0,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'この一致度は、各政党の公式マニフェスト等を基にした簡易的な分析'
              '（調査基準: ${LoadPartyPlatforms.researchedAt}）であり、政党の'
              '公式見解ではありません。対策案は3択に単純化しているため、実際の'
              '立場を完全には表せていません。政党の立場は変化することがあります。',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyMatchCard extends StatelessWidget {
  final PartyMatchResult result;
  final Map<String, Challenge> challengeById;
  final bool isTopMatch;

  const _PartyMatchCard({
    required this.result,
    required this.challengeById,
    this.isTopMatch = false,
  });

  /// 一致度の高さに応じて色を変え、一覧をぱっと見で把握しやすくする。
  static Color _tierColor(double matchRate) {
    if (matchRate >= 0.7) return AppColors.success;
    if (matchRate >= 0.4) return AppColors.primary;
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final percent = (result.matchRate * 100).round();
    final color = result.comparableCount == 0
        ? AppColors.textMuted
        : _tierColor(result.matchRate);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isTopMatch ? AppColors.success : AppColors.border,
          width: isTopMatch ? 1.5 : 1,
        ),
      ),
      child: ExpansionTile(
        enabled: result.comparableCount > 0,
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 4,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        title: Row(
          children: [
            if (isTopMatch) ...[
              const Icon(
                Icons.emoji_events,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                result.partyName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              result.comparableCount == 0 ? '-' : '$percent%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: result.comparableCount == 0 ? 0 : result.matchRate,
                  minHeight: 6,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                result.comparableCount == 0
                    ? '比較できる対策案がまだありません'
                    : '${result.comparableCount}件の対策案で比較（一致 ${result.matchCount}件）',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        children: result.details
            .map(
              (d) => _ChallengeMatchRow(
                detail: d,
                challenge: challengeById[d.challengeId],
                partyName: result.partyName,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ChallengeMatchRow extends StatelessWidget {
  final ChallengeMatchDetail detail;
  final Challenge? challenge;
  final String partyName;

  const _ChallengeMatchRow({
    required this.detail,
    required this.challenge,
    required this.partyName,
  });

  static const _confidenceLabels = {
    StanceConfidence.high: '確信度: 高',
    StanceConfidence.medium: '確信度: 中',
    StanceConfidence.low: '確信度: 低（推測）',
  };

  String _optionTitle(String challengeId, String optionId) {
    final options = LoadPolicyOptions.forChallenge(challengeId);
    for (final o in options) {
      if (o.id == optionId) return o.title;
    }
    return '(不明な対策案)';
  }

  @override
  Widget build(BuildContext context) {
    final yourTitle = _optionTitle(detail.challengeId, detail.yourOptionId);
    final partyTitle = detail.partyStance.closestOptionId == null
        ? '(該当なし)'
        : _optionTitle(detail.challengeId, detail.partyStance.closestOptionId!);

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                detail.isMatch ? Icons.check_circle : Icons.cancel_outlined,
                size: 15,
                color: detail.isMatch ? AppColors.success : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  challenge?.name ?? detail.challengeId,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _confidenceLabels[detail.partyStance.confidence]!,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'あなた: $yourTitle',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '$partyName: $partyTitle',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail.partyStance.note,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
