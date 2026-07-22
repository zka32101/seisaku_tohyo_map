class PensionCalculation {
  final int age;
  final double totalContributions; // 納める金額
  final double totalBenefits; // 受け取る金額
  final double netLoss; // 損失（負数なら黒字）
  final String category; // 世代分類: 20s/30s/40s/50s/60s+

  PensionCalculation({
    required this.age,
    required this.totalContributions,
    required this.totalBenefits,
    required this.netLoss,
    required this.category,
  });

  // 損失率を計算（%）
  double get lossRate {
    if (totalContributions == 0) return 0;
    return (netLoss / totalContributions * 100).abs();
  }

  // 黒字か赤字かを判定
  bool get isInTheMinus => netLoss > 0;

  @override
  String toString() =>
      'PensionCalculation(age: $age, contributions: ¥${totalContributions.toStringAsFixed(0)}, '
      'benefits: ¥${totalBenefits.toStringAsFixed(0)}, loss: ¥${netLoss.toStringAsFixed(0)})';
}
