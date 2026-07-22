class PolicyYearData {
  final int year;
  final double baseline; // 現状維持
  final double policyA; // 与党案
  final double policyB; // 野党案
  final double expert; // 専門家案

  PolicyYearData({
    required this.year,
    required this.baseline,
    required this.policyA,
    required this.policyB,
    required this.expert,
  });
}

class PolicySimulation {
  final String id;
  final String title;
  final String unit;
  final bool lowerIsBetter; // 国債残高など、値が小さいほど良い指標の場合true
  final List<PolicyYearData> yearData; // 年ごとの4シナリオ値

  PolicySimulation({
    required this.id,
    required this.title,
    required this.unit,
    required this.yearData,
    this.lowerIsBetter = false,
  });

  PolicyYearData dataForYear(int year) {
    if (year <= minYear) return yearData.first;
    if (year >= maxYear) return yearData.last;
    return yearData.firstWhere(
      (d) => d.year == year,
      orElse: () => yearData.last,
    );
  }

  int get minYear => yearData.first.year;
  int get maxYear => yearData.last.year;
}

enum PolicyType { baseline, policyA, policyB, expert }

extension PolicyTypeLabel on PolicyType {
  String get label {
    switch (this) {
      case PolicyType.baseline:
        return '現状維持';
      case PolicyType.policyA:
        return '与党案';
      case PolicyType.policyB:
        return '野党案';
      case PolicyType.expert:
        return '専門家案';
    }
  }

  double valueAt(PolicyYearData data) {
    switch (this) {
      case PolicyType.baseline:
        return data.baseline;
      case PolicyType.policyA:
        return data.policyA;
      case PolicyType.policyB:
        return data.policyB;
      case PolicyType.expert:
        return data.expert;
    }
  }
}
