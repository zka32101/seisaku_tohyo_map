class AgencyContact {
  final String id;
  final String challengeId;
  final String agencyName; // 問い合わせ先（省庁・部署・窓口名）
  final String method; // 例: 意見フォーム、メール、電話
  final String status; // 例: 送付済み（回答待ち）、回答あり、未対応
  final String summary; // 問い合わせた内容の要約
  final String? responseSummary; // 先方からの回答内容の要約（あれば）
  final String contactDate; // 問い合わせた時点（例: 2026年7月）
  // この問い合わせが特定の対策案（PolicyOption）に紐づく場合に設定する。
  // nullの場合は課題全体への問い合わせ（対策案を特定しない一般的な問い合わせ）を表す。
  final String? policyOptionId;

  const AgencyContact({
    required this.id,
    required this.challengeId,
    required this.agencyName,
    required this.method,
    required this.status,
    required this.summary,
    this.responseSummary,
    required this.contactDate,
    this.policyOptionId,
  });
}
