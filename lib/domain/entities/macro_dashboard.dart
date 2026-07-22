class MacroDashboard {
  final List<PopulationData> populationTrend; // 2023→2070
  final List<BudgetItem> budgetAllocation; // 予算配分
  final List<DistressItem> distressStatistics; // 困窮状況
  final List<EnergyData> energySelfSufficiency; // エネルギー自給率の推移
  final List<HealthcareCostData> healthcareCostTrend; // 国民医療費の推移

  MacroDashboard({
    required this.populationTrend,
    required this.budgetAllocation,
    required this.distressStatistics,
    required this.energySelfSufficiency,
    required this.healthcareCostTrend,
  });
}

class PopulationData {
  final int year;
  final double population; // 単位: 百万人

  PopulationData({required this.year, required this.population});
}

class BudgetItem {
  final String category; // 社保/利息/防衛等
  final double amount; // 単位: 兆円
  final double percentage;

  BudgetItem({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class DistressItem {
  final String label; // 低収入/失業等
  final double count; // 単位: 百万人
  final double percentage;

  DistressItem({
    required this.label,
    required this.count,
    required this.percentage,
  });
}

class EnergyData {
  final int year;
  final double selfSufficiencyRate; // 単位: %

  EnergyData({required this.year, required this.selfSufficiencyRate});
}

class HealthcareCostData {
  final int year;
  final double totalCost; // 単位: 兆円

  HealthcareCostData({required this.year, required this.totalCost});
}
