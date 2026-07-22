class ChallengeDataPoint {
  final int year;
  final double value;

  ChallengeDataPoint({required this.year, required this.value});
}

class ChallengeDataSeries {
  final String sourceType; // official / private / research
  final String source; // 例: "厚労省" / "XXX研究所"
  final List<ChallengeDataPoint> graphData;
  final String unit;
  final String? note; // 乖離理由

  ChallengeDataSeries({
    required this.sourceType,
    required this.source,
    required this.graphData,
    required this.unit,
    this.note,
  });
}

class ChallengeDetail {
  final String challengeId;
  final String macroConnection; // マクロ→ミクロのつながり説明
  final List<ChallengeDataSeries> dataSeries; // 公式 vs 民間 並行表示
  final String? outlook20Years; // このまま進んだ場合の20年後の見通し（生活影響を含む）
  final String? outlook50Years; // このまま進んだ場合の50年後の見通し（生活影響を含む）
  final String? detailedDescription; // 課題の背景・詳細な説明

  ChallengeDetail({
    required this.challengeId,
    required this.macroConnection,
    required this.dataSeries,
    this.outlook20Years,
    this.outlook50Years,
    this.detailedDescription,
  });
}
