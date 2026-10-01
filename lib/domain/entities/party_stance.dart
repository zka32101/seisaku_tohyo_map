/// 政党の立場の確信度。
/// - high: 公式マニフェスト・政策ページに明示的な記載がある
/// - medium: 関連する政策表明から推測できる
/// - low: 政党の一般的な傾向からの推測（直接の根拠は見つからなかった）
enum StanceConfidence { high, medium, low }

/// ある課題について、政党の実際の立場が3つの対策案（a/b/c）のうち
/// どれに最も近いかを表す。closestOptionIdがnullの場合は、
/// いずれの対策案も政党の実際の立場と一致しないと判断されたことを示す。
class PartyStance {
  final String? closestOptionId;
  final StanceConfidence confidence;
  final String note;

  const PartyStance({
    required this.closestOptionId,
    required this.confidence,
    required this.note,
  });
}
