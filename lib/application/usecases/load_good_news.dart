import '../../domain/entities/challenge_data.dart';
import '../../domain/entities/good_news_item.dart';

/// 社会課題の裏側で、実際に改善している動きを伝えるコンテンツ
/// （数値はWeb検索で確認した時点のスナップショット。定期的な更新が必要）
class LoadGoodNews {
  static List<GoodNewsItem> call() {
    return _items;
  }

  static final List<GoodNewsItem> _items = [
    GoodNewsItem(
      id: 'childcare_waitlist_improving',
      title: '待機児童が8年連続で減少',
      summary: '保育園に入れず「待機」する子供の数が、2017年の2万6千人超から2025年には2千人台まで減少している',
      category: 'welfare',
      detailedDescription:
          '待機児童数は2017年（平成29年）の26,081人をピークに8年連続で減少し、2025年4月時点では2,254人と、'
          '調査開始以来の最少を更新し続けている。保育の受け皿拡大や少子化による申込者数そのものの減少が'
          '背景にあるとみられる。一方で、認可保育所に入れず求職活動を諦めたなどの理由で数に含まれない'
          '「隠れ待機児童」は約7万人と高止まりしており、数字だけでは見えない課題も残っている。',
      source: 'こども家庭庁 保育所等関連状況取りまとめ',
      sourceUrl:
          'https://www.cfa.go.jp/assets/contents/node/basic_page/field_ref_resources/b0a8057b-34bf-4c20-84fb-ae592708ca9b/c853cacb/20250828_policies_hoiku_torimatome_r7_01.pdf',
      unit: '人（待機児童数・全国）',
      trend: [
        ChallengeDataPoint(year: 2017, value: 26081),
        ChallengeDataPoint(year: 2023, value: 2680),
        ChallengeDataPoint(year: 2024, value: 2567),
        ChallengeDataPoint(year: 2025, value: 2254),
      ],
      tags: ['子育て', '福祉'],
    ),
    GoodNewsItem(
      id: 'renewable_energy_progress',
      title: '再生可能エネルギーの比率が2倍以上に',
      summary: '発電量に占める再生可能エネルギーの割合が、2013年度の10.9%から2024年には26.7%まで拡大している',
      category: 'economy',
      detailedDescription:
          '東日本大震災以降、太陽光発電を中心に再生可能エネルギーの導入が進み、発電量に占める割合は'
          '2013年度の10.9%から2024年には26.7%まで上昇した。特に太陽光発電は1.2%から9.8%へと'
          '約8倍に拡大している。政府は2030年度に再エネ比率36〜38%を目標に掲げており、'
          'エネルギー自給率の向上や脱炭素の観点から、この流れは今後も続く見通し。',
      source: 'ISEP 環境エネルギー政策研究所',
      sourceUrl: 'https://www.isep.or.jp/archives/library/15325',
      unit: '%（発電量に占める再生可能エネルギーの割合）',
      trend: [
        ChallengeDataPoint(year: 2013, value: 10.9),
        ChallengeDataPoint(year: 2023, value: 22.9),
        ChallengeDataPoint(year: 2024, value: 26.7),
      ],
      tags: ['エネルギー', '経済'],
    ),
    GoodNewsItem(
      id: 'women_employment_progress',
      title: '女性の就業率が過去最高水準に',
      summary:
          '15〜64歳女性の就業率が、1986年の53.1%から2024年には74.1%まで上昇し、いわゆる「M字カーブ」もほぼ解消された',
      category: 'economy',
      detailedDescription:
          '結婚・出産期にあたる30代で就業率が落ち込む「M字カーブ」は、日本の女性労働の長年の課題とされてきたが、'
          '近年は大きく改善している。15〜64歳女性の就業率は1986年の53.1%から2016年に66.0%、'
          '2024年には74.1%まで上昇し、かつて谷になっていた35〜39歳の労働参加率も80%を超える水準となった。'
          '保育の受け皿拡大や共働き世帯の増加、企業の両立支援制度の普及が背景にあるとみられる。',
      source: '内閣府男女共同参画局／厚生労働省',
      sourceUrl:
          'https://www.gender.go.jp/about_danjo/whitepaper/r07/zentai/html/honpen/b1_s02_01.html',
      unit: '%（15〜64歳女性の就業率）',
      trend: [
        ChallengeDataPoint(year: 1986, value: 53.1),
        ChallengeDataPoint(year: 2016, value: 66.0),
        ChallengeDataPoint(year: 2024, value: 74.1),
      ],
      tags: ['雇用', 'ジェンダー'],
    ),
    GoodNewsItem(
      id: 'crime_rate_long_term_decline',
      title: '刑法犯認知件数は長期的には大きく減少',
      summary: '「治安が悪くなった」と感じる人が増えている一方、刑法犯の認知件数は2002年のピークから2020年にかけて約8割減少した',
      category: 'politics',
      detailedDescription:
          '刑法犯の認知件数は2002年に戦後最多の約285万件を記録した後、防犯カメラの普及や地域の防犯活動の強化などを背景に'
          '一貫して減少し、2020年には約61万件まで減った。ただし2022年以降は3年連続で前年を上回り、'
          '2024年は約73.8万件となっている。世論調査では「治安が悪くなった」と回答する人が2025年時点で約8割にのぼり、'
          '長期的な改善傾向と体感治安との間には大きなギャップがある。',
      source: '警察庁 犯罪情勢統計',
      sourceUrl:
          'https://www.npa.go.jp/publications/statistics/kikakubunseki/r6_jyosei.pdf',
      unit: '万件（刑法犯認知件数）',
      trend: [
        ChallengeDataPoint(year: 2002, value: 285.0),
        ChallengeDataPoint(year: 2020, value: 61.0),
        ChallengeDataPoint(year: 2024, value: 73.8),
      ],
      tags: ['政治', '治安'],
    ),
  ];
}
