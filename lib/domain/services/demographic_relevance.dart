import '../entities/challenge.dart';

/// 課題が「どの所得層・どの地域に強く関係するか」を推定するサービス。
///
/// generationAgreement（世代別の賛同度）とは異なり、こちらは実際の投票・調査データではなく、
/// カテゴリとタグから機械的に算出した「関連度の推定値」。
/// UI上では必ず「推定」であることを明示し、実データと混同させないこと。
class DemographicRelevance {
  DemographicRelevance._();

  /// 所得層別の関連度（0.0〜1.0）。 low = 低所得層, mid = 中所得層, high = 高所得層
  static Map<String, double> incomeRelevance(Challenge challenge) {
    final scores = Map<String, double>.from(
      _incomeBaseByCategory[challenge.category] ?? _incomeDefault,
    );

    for (final tag in challenge.tags) {
      final adjustments = _incomeTagAdjustments[tag];
      if (adjustments == null) continue;
      adjustments.forEach((key, delta) {
        scores[key] = (scores[key] ?? 0) + delta;
      });
    }

    return scores.map((key, value) => MapEntry(key, value.clamp(0.0, 1.0)));
  }

  /// 地域別の関連度（0.0〜1.0）。 urban = 大都市, local = 地方都市, rural = 過疎地域
  static Map<String, double> regionRelevance(Challenge challenge) {
    final scores = Map<String, double>.from(
      _regionBaseByCategory[challenge.category] ?? _regionDefault,
    );

    for (final tag in challenge.tags) {
      final adjustments = _regionTagAdjustments[tag];
      if (adjustments == null) continue;
      adjustments.forEach((key, delta) {
        scores[key] = (scores[key] ?? 0) + delta;
      });
    }

    return scores.map((key, value) => MapEntry(key, value.clamp(0.0, 1.0)));
  }

  static const _incomeDefault = {'low': 0.50, 'mid': 0.60, 'high': 0.50};

  static const _incomeBaseByCategory = {
    'welfare': {'low': 0.85, 'mid': 0.55, 'high': 0.30},
    'economy': {'low': 0.55, 'mid': 0.65, 'high': 0.55},
    'debt': {'low': 0.55, 'mid': 0.65, 'high': 0.60},
    'demographic': {'low': 0.55, 'mid': 0.60, 'high': 0.45},
    'politics': {'low': 0.45, 'mid': 0.55, 'high': 0.55},
    'structural': {'low': 0.50, 'mid': 0.60, 'high': 0.50},
  };

  static const _incomeTagAdjustments = {
    '貧困': {'low': 0.20},
    '格差': {'low': 0.15, 'high': -0.10},
    '税金': {'high': 0.10},
    '財政': {'high': 0.10},
    '中小企業': {'mid': 0.15, 'low': 0.05},
    '住宅': {'low': 0.10},
    '介護': {'low': 0.10, 'mid': 0.05},
    '医療': {'low': 0.10, 'mid': 0.05},
    '年金': {'low': 0.10, 'mid': 0.05},
    '教育': {'mid': 0.10},
    '子育て': {'mid': 0.10},
    '雇用': {'low': 0.05, 'mid': 0.05},
  };

  static const _regionDefault = {'urban': 0.55, 'local': 0.50, 'rural': 0.40};

  static const _regionBaseByCategory = {
    'structural': {'urban': 0.50, 'local': 0.55, 'rural': 0.55},
  };

  static const _regionTagAdjustments = {
    '地方': {'local': 0.25, 'rural': 0.30, 'urban': -0.10},
    '防災': {'local': 0.10, 'rural': 0.15},
    '介護': {'rural': 0.10},
    '医療': {'rural': 0.10},
    '住宅': {'urban': 0.15},
    '雇用': {'local': 0.05, 'rural': 0.05},
    '中小企業': {'local': 0.10, 'rural': 0.05},
  };
}
