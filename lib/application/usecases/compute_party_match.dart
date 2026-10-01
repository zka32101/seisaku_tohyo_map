import '../../domain/entities/party_stance.dart';
import 'load_party_platforms.dart';

/// 1つの課題についての、あなたの選択と政党の立場の比較結果
class ChallengeMatchDetail {
  final String challengeId;
  final String yourOptionId;
  final PartyStance partyStance;
  final bool isMatch;

  const ChallengeMatchDetail({
    required this.challengeId,
    required this.yourOptionId,
    required this.partyStance,
    required this.isMatch,
  });
}

/// 1つの政党についての一致度計算結果
class PartyMatchResult {
  final String partyKey;
  final String partyName;
  final int matchCount;
  final int comparableCount;
  final List<ChallengeMatchDetail> details;

  const PartyMatchResult({
    required this.partyKey,
    required this.partyName,
    required this.matchCount,
    required this.comparableCount,
    required this.details,
  });

  double get matchRate =>
      comparableCount == 0 ? 0 : matchCount / comparableCount;
}

/// 「賛同した(○)課題」かつ「対策案を選んだ」課題だけを対象に、
/// 各政党の実際の立場（LoadPartyPlatforms）と比較して一致度を計算する。
///
/// 課題への賜同だけでは政党間の差はほとんど出ない（どの政党も「これは問題だ」
/// という立場を取ることが多いため）。実際の立場の違いは「その課題にどう対応
/// すべきか」という対策案の選択に表れるため、一致度はそこで比較する。
/// 賜同していない（まだ問題意識を持っていない）課題は、対策案を選んでいても
/// 対象から除外し、賜同した課題に絞ることで「あなたが実際に関心を持って
/// いる課題」だけを反映するようにしている。
class ComputePartyMatch {
  static List<PartyMatchResult> call({
    required Set<String> votedChallengeIds,
    required Map<String, String> selectedPolicyOptions,
  }) {
    final targetChallengeIds = selectedPolicyOptions.keys
        .where((id) => votedChallengeIds.contains(id))
        .toSet();

    final results = LoadPartyPlatforms.parties.map((party) {
      final stances = LoadPartyPlatforms.stancesFor(party.key);
      var matchCount = 0;
      final details = <ChallengeMatchDetail>[];

      for (final challengeId in targetChallengeIds) {
        final stance = stances[challengeId];
        if (stance == null || stance.closestOptionId == null) continue;
        final yourOption = selectedPolicyOptions[challengeId]!;
        final isMatch = yourOption == stance.closestOptionId;
        if (isMatch) matchCount++;
        details.add(
          ChallengeMatchDetail(
            challengeId: challengeId,
            yourOptionId: yourOption,
            partyStance: stance,
            isMatch: isMatch,
          ),
        );
      }

      return PartyMatchResult(
        partyKey: party.key,
        partyName: party.name,
        matchCount: matchCount,
        comparableCount: details.length,
        details: details,
      );
    }).toList();

    results.sort((a, b) => b.matchRate.compareTo(a.matchRate));
    return results;
  }
}
