import 'challenge_data.dart';

/// 課題（悪くなっていること）だけでなく、実際に改善している社会の動きを伝えるコンテンツ
class GoodNewsItem {
  final String id;
  final String title;
  final String summary;
  final String category; // economy/welfare/demographic/politics/debt
  final String detailedDescription;
  final String source;
  final String sourceUrl;
  final String unit;
  final List<ChallengeDataPoint> trend;
  final List<String> tags;

  const GoodNewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.detailedDescription,
    required this.source,
    required this.sourceUrl,
    required this.unit,
    required this.trend,
    required this.tags,
  });
}
