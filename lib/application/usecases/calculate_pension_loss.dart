import 'dart:math' as math;

import '../../../domain/entities/pension_calculation.dart';

class CalculatePensionLoss {
  // 2026年現在の被保険者保険料率（労働者負担分）
  static const double insuranceRatePercentage = 9.15;

  // 給与水準（月額・ボーナス込み平均）
  // 参考: 厚労省 賃金構造統計
  static const Map<String, double> avgMonthlyWage = {
    '20s': 270000, // 20-29歳
    '30s': 330000, // 30-39歳
    '40s': 420000, // 40-49歳
    '50s': 480000, // 50-59歳
    '60s+': 350000, // 60歳以上（再雇用想定）
  };

  // モデル計算用の支給額（65歳時の標準額）
  // 参考: 厚労省年金局・2026年度見込み
  static const double monthlyBenefitAt65 = 60000; // 月額約6万円（概算）

  static String _getCategory(int age) {
    if (age < 30) return '20s';
    if (age < 40) return '30s';
    if (age < 50) return '40s';
    if (age < 60) return '50s';
    return '60s+';
  }

  /// ユーザーの年齢から生涯年金損益を計算
  /// 仮定:
  /// - 現在から65歳まで毎月保険料を納める
  /// - 65歳から85歳まで年金を受け取る（20年間）
  /// - 昇給は年2%を想定
  static PensionCalculation call(int age) {
    if (age < 20 || age > 80) {
      throw ArgumentError('Age must be between 20 and 80');
    }

    final category = _getCategory(age);
    final wage = avgMonthlyWage[category] ?? 330000;

    // 1. 納める金額の計算
    final yearsUntil65 = (65 - age).clamp(0, 45);
    double totalContributions = 0;

    for (int i = 0; i < yearsUntil65; i++) {
      // 毎月の保険料（昇給率: 年2%）
      final salaryAtYear = wage * math.pow(1.02, i);
      final monthlyPremium = salaryAtYear * (insuranceRatePercentage / 100);
      totalContributions += monthlyPremium * 12;
    }

    // 2. 受け取る金額の計算
    // 65歳から85歳まで月額約6万円を受け取る
    const benefitYears = 20;
    const monthlyBenefit = monthlyBenefitAt65;
    final totalBenefits = monthlyBenefit * 12 * benefitYears;

    // 3. 損益計算
    final netLoss = totalContributions - totalBenefits;

    return PensionCalculation(
      age: age,
      totalContributions: totalContributions,
      totalBenefits: totalBenefits,
      netLoss: netLoss,
      category: category,
    );
  }
}
