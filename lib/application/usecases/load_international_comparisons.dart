import '../../domain/entities/international_comparison.dart';

/// 課題・良くなっていることを他国と比べるための国際比較データ
/// （数値はWeb検索で確認した時点のスナップショット。定期的な更新が必要）
class LoadInternationalComparisons {
  static InternationalComparison? forId(String id) => _data[id];

  static final Map<String, InternationalComparison> _data = {
    'national_debt': const InternationalComparison(
      id: 'national_debt_intl',
      targetId: 'national_debt',
      metricLabel: '債務残高の対GDP比',
      japanValue: 214.5,
      japanLabel: '日本',
      comparisons: [
        CountryValue(label: 'イタリア', value: 134.7),
        CountryValue(label: 'アメリカ', value: 122.3),
        CountryValue(label: 'フランス', value: 113.2),
        CountryValue(label: 'カナダ', value: 110.0),
        CountryValue(label: 'イギリス', value: 99.9),
        CountryValue(label: 'ドイツ', value: 62.2),
      ],
      unit: '%（対GDP比）',
      note: 'G7諸国の中で最も高く、他の先進国と比べても突出した水準にある。',
      source: '財務省',
      sourceUrl: 'https://www.mof.go.jp/tax_policy/summary/condition/007.pdf',
      asOfDate: '2026年7月時点',
    ),
    'gender_pay_gap': const InternationalComparison(
      id: 'gender_pay_gap_intl',
      targetId: 'gender_pay_gap',
      metricLabel: '男女の賃金格差',
      japanValue: 21.3,
      japanLabel: '日本',
      comparisons: [CountryValue(label: 'OECD平均', value: 11.0)],
      unit: '%（男女の賃金格差）',
      note: 'OECD加盟36カ国中35位。先進国平均のおよそ2倍の格差が続いている。',
      source: '日本経済新聞／OECD',
      sourceUrl: 'https://www.nikkei.com/article/DGXZQOUD2419F0U3A121C2000000/',
      asOfDate: '2026年7月時点',
    ),
    'energy_dependency': const InternationalComparison(
      id: 'energy_dependency_intl',
      targetId: 'energy_dependency',
      metricLabel: 'エネルギー自給率',
      japanValue: 13.3,
      japanLabel: '日本',
      comparisons: [CountryValue(label: '韓国', value: 18.0)],
      unit: '%（エネルギー自給率）',
      note:
          'OECD加盟38カ国中37位（下から2番目）。ノルウェーやオーストラリアなど100%を超える国もある中、'
          '震災後の原発停止以降、大きく落ち込んだまま低水準が続いている。',
      source: '資源エネルギー庁',
      sourceUrl:
          'https://www.enecho.meti.go.jp/about/pamphlet/energy2024/02.html',
      asOfDate: '2026年7月時点',
    ),
    'voter_turnout_decline': const InternationalComparison(
      id: 'voter_turnout_intl',
      targetId: 'voter_turnout_decline',
      metricLabel: '国政選挙の投票率',
      japanValue: 55.93,
      japanLabel: '日本',
      comparisons: [
        CountryValue(label: 'オーストラリア', value: 89.82),
        CountryValue(label: 'ドイツ', value: 76.6),
        CountryValue(label: 'フランス', value: 73.7),
        CountryValue(label: 'イギリス', value: 67.3),
        CountryValue(label: 'アメリカ', value: 66.8),
      ],
      unit: '%（投票率）',
      note: '世界200の国・地域中158位という低さ。オーストラリアは義務投票制のため特に高い。',
      source: '文春オンライン／IDEA（国際民主主義・選挙支援研究所）',
      sourceUrl: 'https://bunshun.jp/articles/-/72318',
      asOfDate: '2026年7月時点',
    ),
    'renewable_energy_progress': const InternationalComparison(
      id: 'renewable_energy_intl',
      targetId: 'renewable_energy_progress',
      metricLabel: '発電量に占める再生可能エネルギーの比率',
      japanValue: 26.7,
      japanLabel: '日本（2024年）',
      comparisons: [
        CountryValue(label: 'イギリス（2021年）', value: 37.9),
        CountryValue(label: 'ドイツ（2021年）', value: 36.3),
      ],
      unit: '%',
      note: '着実に比率を伸ばしているが、再エネ先進国とされる欧州各国の水準にはまだ届いていない。',
      source: '東京都教育委員会資料',
      sourceUrl:
          'https://www.kyoiku.metro.tokyo.lg.jp/documents/d/kyoiku/5-4-3',
      asOfDate: '2026年7月時点',
    ),
    'population_decline': const InternationalComparison(
      id: 'population_decline_intl',
      targetId: 'population_decline',
      metricLabel: '合計特殊出生率',
      japanValue: 1.15,
      japanLabel: '日本（2024年）',
      comparisons: [
        CountryValue(label: 'フランス（2023年）', value: 1.9),
        CountryValue(label: '韓国（2024年）', value: 0.75),
      ],
      unit: '（合計特殊出生率）',
      note:
          '日本はG7で唯一2を超えていたフランスも1.9まで低下するなど、先進国全体で少子化が進む。'
          '中でも韓国は0.75と世界最低水準で、日本を下回る国も存在する。',
      source: 'エキスパート（Yahoo!ニュース）／厚生労働省',
      sourceUrl:
          'https://news.yahoo.co.jp/expert/articles/5731f136b838f678e9a85b79c9325d1c042135a5',
      asOfDate: '2026年7月時点',
    ),
    'child_poverty': const InternationalComparison(
      id: 'child_poverty_intl',
      targetId: 'child_poverty',
      metricLabel: '相対的貧困率',
      japanValue: 15.4,
      japanLabel: '日本（2021年）',
      comparisons: [
        CountryValue(label: '韓国（2020年）', value: 15.3),
        CountryValue(label: 'アメリカ（2021年）', value: 15.1),
        CountryValue(label: 'OECD平均（2018年）', value: 11.7),
      ],
      unit: '%（相対的貧困率）',
      note: '先進国の中でも高い水準が続いており、特にひとり親世帯の貧困率は44.5%と2人に1人が貧困状態にある。',
      source: 'SBBIT／OECD',
      sourceUrl: 'https://www.sbbit.jp/article/fj/119995',
      asOfDate: '2026年7月時点',
    ),
    'healthcare_cost': const InternationalComparison(
      id: 'healthcare_cost_intl',
      targetId: 'healthcare_cost',
      metricLabel: '医療費（保健医療支出）の対GDP比',
      japanValue: 10.74,
      japanLabel: '日本',
      comparisons: [
        CountryValue(label: 'アメリカ', value: 17.16),
        CountryValue(label: 'ドイツ', value: 12.27),
        CountryValue(label: 'フランス', value: 11.54),
        CountryValue(label: 'イギリス', value: 11.13),
      ],
      unit: '%（対GDP比）',
      note: 'OECD加盟国中4位まで上昇。2000年の7.0%から20年余りで3ポイント以上上昇し、高止まりが続く。',
      source: 'BBT大学院／OECD',
      sourceUrl: 'https://www.ohmae.ac.jp/mbaswitch/medical-costs/',
      asOfDate: '2026年7月時点',
    ),
    'education_gap': const InternationalComparison(
      id: 'education_gap_intl',
      targetId: 'education_gap',
      metricLabel: '高等教育進学率',
      japanValue: 52.0,
      japanLabel: '日本',
      comparisons: [CountryValue(label: 'OECD平均', value: 58.0)],
      unit: '%（高等教育進学率）',
      note: 'OECD平均をやや下回る水準。大学・短大区分など制度の違いにより国際比較の結果は変わりうる点に留意が必要。',
      source: '文部科学省（OECD "Education at a Glance"）',
      sourceUrl:
          'https://www.mext.go.jp/component/b_menu/shingi/giji/__icsFiles/afieldfile/2013/04/17/1333454_11.pdf',
      asOfDate: '2026年7月時点',
    ),
    'women_in_politics': const InternationalComparison(
      id: 'women_in_politics_intl',
      targetId: 'women_in_politics',
      metricLabel: '衆議院（下院）の女性議員比率',
      japanValue: 15.7,
      japanLabel: '日本（2024年）',
      comparisons: [
        CountryValue(label: '世界平均', value: 27.2),
        CountryValue(label: 'フランス', value: 37.3),
        CountryValue(label: 'イギリス', value: 34.8),
      ],
      unit: '%（下院の女性議員比率）',
      note: '2024年の衆院選で過去最多となったが、それでもG7最下位。186カ国・地域中139位という低水準。',
      source: 'Bloomberg／内閣府男女共同参画局',
      sourceUrl:
          'https://www.bloomberg.com/jp/news/articles/2024-10-30/SM1IWGT1UM0W00',
      asOfDate: '2026年7月時点',
    ),
    'foreign_direct_investment': const InternationalComparison(
      id: 'foreign_direct_investment_intl',
      targetId: 'foreign_direct_investment',
      metricLabel: '対内直接投資残高の対GDP比',
      japanValue: 5.0,
      japanLabel: '日本',
      comparisons: [CountryValue(label: 'OECD平均', value: 56.0)],
      unit: '%（対内直接投資残高の対GDP比）',
      note: 'OECD加盟38カ国中最下位。北朝鮮をも下回るとの指摘があるほど、世界的に見て極端に閉鎖的な水準にある。',
      source: 'RIETI／内閣府',
      sourceUrl: 'https://www.rieti.go.jp/jp/columns/s21_0008.html',
      asOfDate: '2026年7月時点',
    ),
    'income_stagnation': const InternationalComparison(
      id: 'income_stagnation_intl',
      targetId: 'income_stagnation',
      metricLabel: '実質賃金の伸び（1991年を100とした場合の2020年の水準）',
      japanValue: 103,
      japanLabel: '日本',
      comparisons: [
        CountryValue(label: 'アメリカ', value: 147),
        CountryValue(label: 'イギリス', value: 144),
      ],
      unit: '（1991年=100とした指数）',
      note:
          '1991年から2020年の30年間で、日本の実質賃金はほぼ横ばい（+3%）だったのに対し、'
          'アメリカやイギリスは4割以上伸びており、G7の中でもイタリアと並んで突出して低い伸び率にとどまる。',
      source: 'ニッセイ基礎研究所',
      sourceUrl:
          'https://www.nli-research.co.jp/report/detail/id=78664?site=nli',
      asOfDate: '2026年7月時点',
    ),
    'women_employment_progress': const InternationalComparison(
      id: 'women_employment_intl',
      targetId: 'women_employment_progress',
      metricLabel: '15〜64歳女性の就業率',
      japanValue: 74.1,
      japanLabel: '日本（2024年）',
      comparisons: [CountryValue(label: 'ドイツ（2023年）', value: 73.7)],
      unit: '%',
      note:
          '2000年代まではOECD平均程度だったが、2010年代以降の伸びが大きく、'
          '主要先進国の中でもドイツに匹敵する水準まで上昇した。ただし北欧・大洋州諸国はさらに高い。',
      source: '内閣府男女共同参画局',
      sourceUrl:
          'https://www.gender.go.jp/about_danjo/whitepaper/r07/zentai/html/honpen/b1_s02_01.html',
      asOfDate: '2026年7月時点',
    ),
  };
}
