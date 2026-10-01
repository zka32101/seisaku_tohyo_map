import 'package:flutter_test/flutter_test.dart';
import 'package:nihon_future_map/application/usecases/compute_party_match.dart';
import 'package:nihon_future_map/application/usecases/load_party_platforms.dart';

void main() {
  group('ComputePartyMatch', () {
    test('賛同していない課題の対策案選択は比較対象から除外される', () {
      final results = ComputePartyMatch.call(
        votedChallengeIds: {},
        selectedPolicyOptions: {'money_in_politics': 'a'},
      );

      for (final r in results) {
        expect(r.comparableCount, 0);
        expect(r.matchRate, 0);
      }
    });

    test('賛同・対策案選択が両方ある課題だけが比較対象になり、一致度が正しく計算される', () {
      final results = ComputePartyMatch.call(
        votedChallengeIds: {'money_in_politics'},
        selectedPolicyOptions: {'money_in_politics': 'a'},
      );

      // 全政党が対象（LoadPartyPlatforms.partiesの数と一致）
      expect(results.length, LoadPartyPlatforms.parties.length);

      for (final r in results) {
        expect(r.comparableCount, 1);
        final expectedMatch =
            LoadPartyPlatforms.stancesFor(
              r.partyKey,
            )['money_in_politics']!.closestOptionId ==
            'a';
        expect(r.matchCount, expectedMatch ? 1 : 0);
        expect(r.matchRate, expectedMatch ? 1.0 : 0.0);
      }
    });

    test('一致度の高い政党順にソートされる', () {
      final results = ComputePartyMatch.call(
        votedChallengeIds: {'money_in_politics'},
        selectedPolicyOptions: {'money_in_politics': 'a'},
      );

      for (var i = 0; i < results.length - 1; i++) {
        expect(
          results[i].matchRate,
          greaterThanOrEqualTo(results[i + 1].matchRate),
        );
      }
    });

    test('政党の立場データが無い（closestOptionIdがnull）課題は比較対象から除外される', () {
      // jcpはpension_crisisで3択いずれとも一致しないためnullを返す
      final results = ComputePartyMatch.call(
        votedChallengeIds: {'pension_crisis'},
        selectedPolicyOptions: {'pension_crisis': 'a'},
      );

      final jcp = results.firstWhere((r) => r.partyKey == 'jcp');
      expect(jcp.comparableCount, 0);
    });

    test('入力が空の場合、全政党で比較件数0になる', () {
      final results = ComputePartyMatch.call(
        votedChallengeIds: {},
        selectedPolicyOptions: {},
      );

      expect(results.length, LoadPartyPlatforms.parties.length);
      for (final r in results) {
        expect(r.comparableCount, 0);
        expect(r.details, isEmpty);
      }
    });
  });
}
