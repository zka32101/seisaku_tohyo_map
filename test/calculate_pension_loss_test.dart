import 'package:flutter_test/flutter_test.dart';
import 'package:nihon_future_map/application/usecases/calculate_pension_loss.dart';

void main() {
  group('CalculatePensionLoss', () {
    test('30歳の男性: 年金損失を正しく計算', () {
      final result = CalculatePensionLoss.call(30);

      expect(result.age, 30);
      expect(result.category, '30s');
      expect(result.isInTheMinus, true); // 損失（赤字）

      // 35年間（30歳→65歳）納める
      // 月額約33万円 * 保険料9.15% = 約30,195円/月
      // 昇給率年2%を考慮: 約18百万円
      expect(result.totalContributions, greaterThan(17000000));
      expect(result.totalContributions, lessThan(20000000));

      // 20年間（65歳→85歳）受け取る
      // 月額6万円 * 12 * 20年 = 1,440万円
      expect(result.totalBenefits, 14400000); // 1,440万円

      // 損失 = 納めた額 - 受け取った額
      expect(result.netLoss, greaterThan(0));
      expect(result.lossRate, greaterThan(15)); // 損失率15%以上
    });

    test('25歳の若者: 長期納付による影響', () {
      final result25 = CalculatePensionLoss.call(25);
      final result30 = CalculatePensionLoss.call(30);

      expect(result25.age, 25);
      expect(result30.age, 30);

      // 25歳は40年、30歳は35年納める
      // 納付期間が長いが、初期給与が低いため大きな差がない
      expect(result25.totalContributions, greaterThan(15000000));
      expect(result30.totalContributions, greaterThan(15000000));
    });

    test('60歳: わずか5年間の納付', () {
      final result = CalculatePensionLoss.call(60);

      expect(result.age, 60);
      expect(result.category, '60s+');

      // 60歳→65歳: 5年間のみ納める
      // 月額35万円 * 9.15% = 約32,025円/月
      // 32,025 * 12 * 5 = 約192万円
      expect(result.totalContributions, lessThan(3000000));

      // 納付期間が短いため受け取る額に近い（損失は少ない）
      expect(result.netLoss, lessThan(result.totalContributions * 0.5));
    });

    test('20歳: 最長45年間の納付期間', () {
      final result = CalculatePensionLoss.call(20);

      expect(result.age, 20);
      expect(result.category, '20s');

      // 20歳→65歳: 45年間納める
      // 月額27万円 * 9.15% = 約24,705円/月
      // 昇給率年2%を考慮: 約21百万円
      expect(result.totalContributions, greaterThan(20000000));
      expect(result.totalContributions, lessThan(23000000));

      // 最長納付期間なので最大の損失
      expect(result.lossRate, greaterThan(30));
    });

    test('各年代カテゴリの給与が正しく適用される', () {
      final result20s = CalculatePensionLoss.call(25);
      final result30s = CalculatePensionLoss.call(35);
      final result40s = CalculatePensionLoss.call(45);
      final result50s = CalculatePensionLoss.call(55);
      final result60s = CalculatePensionLoss.call(65);

      expect(result20s.category, '20s');
      expect(result30s.category, '30s');
      expect(result40s.category, '40s');
      expect(result50s.category, '50s');
      expect(result60s.category, '60s+');
    });

    test('損失率の計算が正確', () {
      final result = CalculatePensionLoss.call(30);

      // 損失率 = (netLoss / totalContributions) * 100
      final expectedLossRate =
          (result.netLoss / result.totalContributions * 100);
      expect(result.lossRate, expectedLossRate);
    });

    test('無効な年齢は例外をスロー', () {
      expect(() => CalculatePensionLoss.call(19), throwsArgumentError);
      expect(() => CalculatePensionLoss.call(81), throwsArgumentError);
    });

    test('toString形式が適切', () {
      final result = CalculatePensionLoss.call(30);
      final str = result.toString();

      expect(str, contains('30'));
      expect(str, contains('contributions'));
      expect(str, contains('benefits'));
    });
  });
}
