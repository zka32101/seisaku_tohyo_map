import '../../domain/entities/macro_dashboard.dart';

class LoadMacroDashboard {
  static MacroDashboard call() {
    return MacroDashboard(
      populationTrend: _generatePopulationTrend(),
      budgetAllocation: _generateBudgetAllocation(),
      distressStatistics: _generateDistressStatistics(),
      energySelfSufficiency: _generateEnergySelfSufficiency(),
      healthcareCostTrend: _generateHealthcareCostTrend(),
    );
  }

  /// 人口推移（2023年→2070年）
  /// 参考: 国立社会保障・人口問題研究所の中位推計
  static List<PopulationData> _generatePopulationTrend() {
    return [
      PopulationData(year: 2023, population: 125.1),
      PopulationData(year: 2030, population: 123.0),
      PopulationData(year: 2040, population: 119.7),
      PopulationData(year: 2050, population: 115.1),
      PopulationData(year: 2060, population: 109.9),
      PopulationData(year: 2070, population: 104.4),
    ];
  }

  /// 予算配分（2026年度一般会計）
  /// 参考: 財務省・令和8年度予算案
  static List<BudgetItem> _generateBudgetAllocation() {
    return [
      BudgetItem(category: '社会保障', amount: 36.2, percentage: 35.1),
      BudgetItem(category: '利息・その他', amount: 24.7, percentage: 23.9),
      BudgetItem(category: '公債費', amount: 15.3, percentage: 14.8),
      BudgetItem(category: '防衛', amount: 9.2, percentage: 8.9),
      BudgetItem(category: '教育・科学', amount: 8.5, percentage: 8.2),
      BudgetItem(category: 'その他', amount: 9.1, percentage: 8.8),
    ];
  }

  /// 困窮状況（2025年推計）
  /// 参考: 厚労省・統計局
  static List<DistressItem> _generateDistressStatistics() {
    return [
      DistressItem(label: '低収入（年300万以下）', count: 15.0, percentage: 12.5),
      DistressItem(label: '失業・未就職', count: 8.0, percentage: 6.8),
      DistressItem(label: '非正規雇用（全労働者の4割）', count: 48.0, percentage: 39.8),
      DistressItem(label: '65歳以上の就業希望者', count: 7.5, percentage: 6.2),
      DistressItem(label: '生活保護受給者', count: 2.1, percentage: 1.7),
    ];
  }

  /// エネルギー自給率の推移
  /// 参考: 経産省 エネルギー白書
  static List<EnergyData> _generateEnergySelfSufficiency() {
    return [
      EnergyData(year: 2000, selfSufficiencyRate: 20.2),
      EnergyData(year: 2010, selfSufficiencyRate: 19.9),
      EnergyData(year: 2015, selfSufficiencyRate: 7.4),
      EnergyData(year: 2020, selfSufficiencyRate: 11.3),
      EnergyData(year: 2025, selfSufficiencyRate: 13.3),
    ];
  }

  /// 国民医療費の推移
  /// 参考: 厚労省 国民医療費
  static List<HealthcareCostData> _generateHealthcareCostTrend() {
    return [
      HealthcareCostData(year: 2000, totalCost: 30.1),
      HealthcareCostData(year: 2010, totalCost: 37.4),
      HealthcareCostData(year: 2020, totalCost: 42.9),
      HealthcareCostData(year: 2025, totalCost: 47.0),
    ];
  }
}
