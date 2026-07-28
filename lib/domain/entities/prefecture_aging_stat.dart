/// 都道府県別の高齢化率データ（トップ画面の「過疎・高齢化」ランキング表示に使用）
class PrefectureAgingStat {
  final String code; // JIS都道府県コード '01'-'47'
  final String name;
  final String region;
  final double agingRatePercent; // 65歳以上人口の割合(%)

  const PrefectureAgingStat({
    required this.code,
    required this.name,
    required this.region,
    required this.agingRatePercent,
  });
}
