import '../../domain/entities/prefecture_aging_stat.dart';

/// 都道府県別高齢化率データの提供元
class LoadPrefectureAgingStats {
  LoadPrefectureAgingStats._();

  static const sourceLabel = '総務省統計局「人口推計」2024年10月1日現在（確定値）';

  static const List<PrefectureAgingStat> all = [
    PrefectureAgingStat(
      code: '01',
      name: '北海道',
      region: '北海道',
      agingRatePercent: 33.3,
    ),
    PrefectureAgingStat(
      code: '02',
      name: '青森県',
      region: '東北',
      agingRatePercent: 35.7,
    ),
    PrefectureAgingStat(
      code: '03',
      name: '岩手県',
      region: '東北',
      agingRatePercent: 35.4,
    ),
    PrefectureAgingStat(
      code: '04',
      name: '宮城県',
      region: '東北',
      agingRatePercent: 29.6,
    ),
    PrefectureAgingStat(
      code: '05',
      name: '秋田県',
      region: '東北',
      agingRatePercent: 39.5,
    ),
    PrefectureAgingStat(
      code: '06',
      name: '山形県',
      region: '東北',
      agingRatePercent: 35.6,
    ),
    PrefectureAgingStat(
      code: '07',
      name: '福島県',
      region: '東北',
      agingRatePercent: 33.7,
    ),
    PrefectureAgingStat(
      code: '08',
      name: '茨城県',
      region: '関東',
      agingRatePercent: 30.9,
    ),
    PrefectureAgingStat(
      code: '09',
      name: '栃木県',
      region: '関東',
      agingRatePercent: 30.5,
    ),
    PrefectureAgingStat(
      code: '10',
      name: '群馬県',
      region: '関東',
      agingRatePercent: 31.1,
    ),
    PrefectureAgingStat(
      code: '11',
      name: '埼玉県',
      region: '関東',
      agingRatePercent: 27.5,
    ),
    PrefectureAgingStat(
      code: '12',
      name: '千葉県',
      region: '関東',
      agingRatePercent: 28.1,
    ),
    PrefectureAgingStat(
      code: '13',
      name: '東京都',
      region: '関東',
      agingRatePercent: 22.7,
    ),
    PrefectureAgingStat(
      code: '14',
      name: '神奈川県',
      region: '関東',
      agingRatePercent: 26.0,
    ),
    PrefectureAgingStat(
      code: '15',
      name: '新潟県',
      region: '中部',
      agingRatePercent: 34.2,
    ),
    PrefectureAgingStat(
      code: '16',
      name: '富山県',
      region: '中部',
      agingRatePercent: 33.2,
    ),
    PrefectureAgingStat(
      code: '17',
      name: '石川県',
      region: '中部',
      agingRatePercent: 30.7,
    ),
    PrefectureAgingStat(
      code: '18',
      name: '福井県',
      region: '中部',
      agingRatePercent: 31.8,
    ),
    PrefectureAgingStat(
      code: '19',
      name: '山梨県',
      region: '中部',
      agingRatePercent: 32.0,
    ),
    PrefectureAgingStat(
      code: '20',
      name: '長野県',
      region: '中部',
      agingRatePercent: 32.9,
    ),
    PrefectureAgingStat(
      code: '21',
      name: '岐阜県',
      region: '中部',
      agingRatePercent: 31.4,
    ),
    PrefectureAgingStat(
      code: '22',
      name: '静岡県',
      region: '中部',
      agingRatePercent: 31.2,
    ),
    PrefectureAgingStat(
      code: '23',
      name: '愛知県',
      region: '中部',
      agingRatePercent: 25.8,
    ),
    PrefectureAgingStat(
      code: '24',
      name: '三重県',
      region: '近畿',
      agingRatePercent: 30.9,
    ),
    PrefectureAgingStat(
      code: '25',
      name: '滋賀県',
      region: '近畿',
      agingRatePercent: 27.3,
    ),
    PrefectureAgingStat(
      code: '26',
      name: '京都府',
      region: '近畿',
      agingRatePercent: 29.8,
    ),
    PrefectureAgingStat(
      code: '27',
      name: '大阪府',
      region: '近畿',
      agingRatePercent: 27.6,
    ),
    PrefectureAgingStat(
      code: '28',
      name: '兵庫県',
      region: '近畿',
      agingRatePercent: 30.2,
    ),
    PrefectureAgingStat(
      code: '29',
      name: '奈良県',
      region: '近畿',
      agingRatePercent: 32.9,
    ),
    PrefectureAgingStat(
      code: '30',
      name: '和歌山県',
      region: '近畿',
      agingRatePercent: 34.5,
    ),
    PrefectureAgingStat(
      code: '31',
      name: '鳥取県',
      region: '中国',
      agingRatePercent: 33.7,
    ),
    PrefectureAgingStat(
      code: '32',
      name: '島根県',
      region: '中国',
      agingRatePercent: 35.2,
    ),
    PrefectureAgingStat(
      code: '33',
      name: '岡山県',
      region: '中国',
      agingRatePercent: 31.2,
    ),
    PrefectureAgingStat(
      code: '34',
      name: '広島県',
      region: '中国',
      agingRatePercent: 30.4,
    ),
    PrefectureAgingStat(
      code: '35',
      name: '山口県',
      region: '中国',
      agingRatePercent: 35.5,
    ),
    PrefectureAgingStat(
      code: '36',
      name: '徳島県',
      region: '四国',
      agingRatePercent: 35.7,
    ),
    PrefectureAgingStat(
      code: '37',
      name: '香川県',
      region: '四国',
      agingRatePercent: 32.8,
    ),
    PrefectureAgingStat(
      code: '38',
      name: '愛媛県',
      region: '四国',
      agingRatePercent: 34.5,
    ),
    PrefectureAgingStat(
      code: '39',
      name: '高知県',
      region: '四国',
      agingRatePercent: 36.6,
    ),
    PrefectureAgingStat(
      code: '40',
      name: '福岡県',
      region: '九州・沖縄',
      agingRatePercent: 28.6,
    ),
    PrefectureAgingStat(
      code: '41',
      name: '佐賀県',
      region: '九州・沖縄',
      agingRatePercent: 32.0,
    ),
    PrefectureAgingStat(
      code: '42',
      name: '長崎県',
      region: '九州・沖縄',
      agingRatePercent: 34.7,
    ),
    PrefectureAgingStat(
      code: '43',
      name: '熊本県',
      region: '九州・沖縄',
      agingRatePercent: 32.6,
    ),
    PrefectureAgingStat(
      code: '44',
      name: '大分県',
      region: '九州・沖縄',
      agingRatePercent: 34.4,
    ),
    PrefectureAgingStat(
      code: '45',
      name: '宮崎県',
      region: '九州・沖縄',
      agingRatePercent: 33.9,
    ),
    PrefectureAgingStat(
      code: '46',
      name: '鹿児島県',
      region: '九州・沖縄',
      agingRatePercent: 34.2,
    ),
    PrefectureAgingStat(
      code: '47',
      name: '沖縄県',
      region: '九州・沖縄',
      agingRatePercent: 24.2,
    ),
  ];

  /// 高齢化率が特に高い地域（過疎・地方消滅系の課題と関連）
  static const List<String> _highAgingChallengeIds = [
    'regional_extinction',
    'caregiver_shortage',
    'isolated_elderly',
  ];

  /// 高齢化率が低い大都市圏（東京一極集中系の課題と関連）
  static const List<String> _lowAgingChallengeIds = ['tokyo_concentration'];

  /// それ以外の地域に共通して関連する課題
  static const List<String> _defaultChallengeIds = ['population_decline'];

  /// 高齢化率に応じて、関連する課題IDを返す（一覧・詳細から遷移するために使用）
  static List<String> relatedChallengeIds(PrefectureAgingStat stat) {
    if (stat.agingRatePercent >= 33.7) return _highAgingChallengeIds;
    if (stat.agingRatePercent <= 28.6) return _lowAgingChallengeIds;
    return _defaultChallengeIds;
  }
}
