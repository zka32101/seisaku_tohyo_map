/// 課題ごとの「緊急度」「重要度」（各1〜5、5が最も高い）
///
/// - urgency（緊急度）: 対応を先送りするほど手遅れになりやすいか・時間的な切迫度
/// - importance（重要度）: 日本社会全体への影響の大きさ・広がり
///
/// いずれも一次データからの機械的な算出値ではなく、各課題の性質を踏まえた
/// 編集上の目安（運営による定性評価）。ユーザーが優先順位を考えるための
/// 補助線として提示する。
class UrgencyImportance {
  final String challengeId;
  final int urgency; // 1-5
  final int importance; // 1-5

  const UrgencyImportance({
    required this.challengeId,
    required this.urgency,
    required this.importance,
  });

  /// 緊急重要マトリクスの象限
  UrgencyQuadrant get quadrant {
    final isUrgent = urgency >= 4;
    final isImportant = importance >= 4;
    if (isUrgent && isImportant) return UrgencyQuadrant.doNow;
    if (!isUrgent && isImportant) return UrgencyQuadrant.plan;
    if (isUrgent && !isImportant) return UrgencyQuadrant.delegate;
    return UrgencyQuadrant.later;
  }
}

enum UrgencyQuadrant {
  /// 緊急×重要：今すぐ手を打つべき
  doNow,

  /// 重要×緊急でない：計画的に取り組むべき
  plan,

  /// 緊急×重要でない：対応は必要だが影響は限定的
  delegate,

  /// 緊急でない×重要でない：優先度は相対的に低い
  later,
}
