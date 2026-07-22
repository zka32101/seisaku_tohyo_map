class DietBill {
  final String id;
  final String challengeId;
  final String billName;
  final String status; // 例: 成立、審議中、一部施行済み
  final String summary;
  final String effect; // 想定される効果・影響（メリットだけでなく懸念点も含む）
  final String sourceLabel;
  final String sourceUrl;
  final String asOfDate; // 情報時点（例: 2026年7月）

  const DietBill({
    required this.id,
    required this.challengeId,
    required this.billName,
    required this.status,
    required this.summary,
    required this.effect,
    required this.sourceLabel,
    required this.sourceUrl,
    required this.asOfDate,
  });
}
