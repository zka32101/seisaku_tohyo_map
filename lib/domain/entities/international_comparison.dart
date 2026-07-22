class CountryValue {
  final String label; // 例: "ドイツ", "OECD平均", "アメリカ（2023）"
  final double value;

  const CountryValue({required this.label, required this.value});
}

/// 課題・良くなっていることの各テーマについて、日本の数値を他国と比べるためのデータ
class InternationalComparison {
  final String id;
  final String targetId; // challengeId または GoodNewsItem.id
  final String metricLabel;
  final double japanValue;
  final String japanLabel; // 例: "日本（2025年推計）"
  final List<CountryValue> comparisons;
  final String unit;
  final String note; // 順位や傾向の補足
  final String source;
  final String sourceUrl;
  final String asOfDate;

  const InternationalComparison({
    required this.id,
    required this.targetId,
    required this.metricLabel,
    required this.japanValue,
    required this.japanLabel,
    required this.comparisons,
    required this.unit,
    required this.note,
    required this.source,
    required this.sourceUrl,
    required this.asOfDate,
  });
}
