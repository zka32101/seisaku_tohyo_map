class IssueAdvocate {
  final String id;
  final String challengeId;
  final String type; // party（政党）/ individual（個人）/ government（政府・与党の公式方針）
  final String name;
  final String stance; // 主張の要約
  final String sourceLabel;
  final String sourceUrl;
  final String asOfDate; // 情報時点（例: 2026年7月）

  const IssueAdvocate({
    required this.id,
    required this.challengeId,
    required this.type,
    required this.name,
    required this.stance,
    required this.sourceLabel,
    required this.sourceUrl,
    required this.asOfDate,
  });
}
