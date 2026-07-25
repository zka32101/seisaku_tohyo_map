import '../../domain/entities/issue_advocate.dart';

/// 課題に対して、政党・政府・個人が公に示している主張・立場のデータ
///
/// 政治的に機微な内容のため、一次資料（政党公式サイト・政府資料・報道）で
/// 裏取りできたものに限定して掲載している。全ての課題を網羅するものではなく、
/// 明確な出典が確認できた一部の課題のみを対象としたスナップショット。
class LoadIssueAdvocates {
  static List<IssueAdvocate> forChallenge(String challengeId) {
    return _data[challengeId] ?? const [];
  }

  // 政党・個人の主張データが用意されている課題IDの一覧
  static List<String> get challengeIds => _data.keys.toList();

  static final Map<String, List<IssueAdvocate>> _data = {
    'money_in_politics': [
      const IssueAdvocate(
        id: 'money_in_politics_cdp',
        challengeId: 'money_in_politics',
        type: 'party',
        name: '立憲民主党',
        stance: '企業・団体献金を全面禁止する法案を衆院に提出し、政党本部・支部への献金も禁止対象に含めるよう求めている。',
        sourceLabel: '立憲民主党',
        sourceUrl: 'https://cdp-japan.jp/news/20241007_8335',
        asOfDate: '2024年10月時点',
      ),
      const IssueAdvocate(
        id: 'money_in_politics_jcp',
        challengeId: 'money_in_politics',
        type: 'party',
        name: '日本共産党',
        stance: '企業・団体献金の全面禁止に加え、政党助成金制度そのものの廃止を主張している。',
        sourceLabel: '日本共産党',
        sourceUrl: 'https://www.jcp.or.jp/web_policy/16505.html',
        asOfDate: '2026年時点',
      ),
      const IssueAdvocate(
        id: 'money_in_politics_ldp',
        challengeId: 'money_in_politics',
        type: 'party',
        name: '自民党',
        stance: '企業・団体献金の禁止には慎重な立場を維持しており、公明党との連立協議でもこの点が調整の焦点となった。',
        sourceLabel: '日本経済新聞',
        sourceUrl:
            'https://www.nikkei.com/article/DGXZQOUA096IW0Z01C25A0000000/',
        asOfDate: '2025年時点',
      ),
    ],
    'hereditary_politicians': [
      const IssueAdvocate(
        id: 'hereditary_politicians_ishin',
        challengeId: 'hereditary_politicians',
        type: 'party',
        name: '日本維新の会',
        stance: '世襲議員による政治団体・政治資金の親族間継承を規制・課税する立法を早急に策定する方針を掲げている。',
        sourceLabel: '日本維新の会「維新八策2025」',
        sourceUrl: 'https://o-ishin.jp/sangiin2025/manifest/all/',
        asOfDate: '2025年時点',
      ),
      const IssueAdvocate(
        id: 'hereditary_politicians_cdp',
        challengeId: 'hereditary_politicians',
        type: 'party',
        name: '立憲民主党',
        stance: '国会議員の政治資金を親族が引き継ぐことを禁止する「世襲制限」を衆院選の公約に掲げている。',
        sourceLabel: '東京新聞',
        sourceUrl: 'https://www.tokyo-np.co.jp/article/367319',
        asOfDate: '2025年時点',
      ),
      const IssueAdvocate(
        id: 'hereditary_politicians_ldp',
        challengeId: 'hereditary_politicians',
        type: 'party',
        name: '自民党',
        stance: '党内に世襲議員が多いこともあり、世襲制限の議論には後ろ向きな姿勢が指摘されている。',
        sourceLabel: '東京新聞',
        sourceUrl: 'https://www.tokyo-np.co.jp/article/367319',
        asOfDate: '2025年時点',
      ),
    ],
    'women_in_politics': [
      const IssueAdvocate(
        id: 'women_in_politics_cdp',
        challengeId: 'women_in_politics',
        type: 'party',
        name: '立憲民主党',
        stance: '国政選挙でのクオータ制導入を掲げ、国会の男女比を半々にする「パリテ」の実現を目指している。',
        sourceLabel: '立憲民主党 政策集2025',
        sourceUrl: 'https://cdp-japan.jp/visions/policies2025/10',
        asOfDate: '2025年時点',
      ),
      const IssueAdvocate(
        id: 'women_in_politics_jcp',
        challengeId: 'women_in_politics',
        type: 'party',
        name: '日本共産党',
        stance: '候補者の男女同数を目標に掲げ、2022年参院選では女性候補比率55%を実現するなど独自に取り組みを進めている。',
        sourceLabel: '日本共産党大阪府委員会',
        sourceUrl: 'https://www.jcp-osaka.jp/osaka_now/27550',
        asOfDate: '2025年時点',
      ),
      const IssueAdvocate(
        id: 'women_in_politics_gov',
        challengeId: 'women_in_politics',
        type: 'government',
        name: '政府目標（男女共同参画基本計画）',
        stance: '衆参・統一地方選挙での女性候補者の割合を2025年までに35%とする政府目標を掲げていたが、法的拘束力のある制度ではない。',
        sourceLabel: '内閣府男女共同参画局',
        sourceUrl:
            'https://www.gender.go.jp/policy/seijibunya/pdf/pamphlet.pdf',
        asOfDate: '2025年時点',
      ),
    ],
    'defense_budget_funding': [
      const IssueAdvocate(
        id: 'defense_budget_funding_gov',
        challengeId: 'defense_budget_funding',
        type: 'government',
        name: '政府・与党（自民党・公明党）',
        stance:
            '歳出改革や決算剰余金を中心にしつつ、不足分は法人税・所得税・たばこ税の増税で賄う方針を決定し、所得税増税は2027年1月開始予定。',
        sourceLabel: '自由民主党（令和7年度税制改正大綱）',
        sourceUrl: 'https://www.jimin.jp/news/information/209805.html',
        asOfDate: '2026年時点',
      ),
      const IssueAdvocate(
        id: 'defense_budget_funding_dpp',
        challengeId: 'defense_budget_funding',
        type: 'party',
        name: '国民民主党',
        stance:
            '増税には慎重な立場を取り、外国為替資金特別会計の剰余金活用や日銀保有国債の一部永久債化など、増税に頼らない財源確保を優先すべきだと主張している。',
        sourceLabel: '国民民主党「令和7年度税制改革と財源についての考え方」',
        sourceUrl:
            'https://new-kokumin.jp/wp-content/uploads/2024/12/293debc76fd4e0d9d093ad7258acae4e.pdf',
        asOfDate: '2024年12月時点',
      ),
    ],
    'income_stagnation': [
      const IssueAdvocate(
        id: 'income_stagnation_dpp',
        challengeId: 'income_stagnation',
        type: 'party',
        name: '国民民主党',
        stance:
            '「年収の壁」（基礎控除等）を103万円から178万円に引き上げる「手取りを増やす」政策を掲げ、2026年度税制改正で自民党との合意により178万円への引き上げが実現に向けて進んだ。',
        sourceLabel: '日本経済新聞',
        sourceUrl:
            'https://www.nikkei.com/article/DGXZQOUA196CK0Z10C26A1000000/',
        asOfDate: '2026年1月時点',
      ),
    ],
    'finance_ministry_narrative_control': [
      const IssueAdvocate(
        id: 'finance_ministry_narrative_morinaga',
        challengeId: 'finance_ministry_narrative_control',
        type: 'individual',
        name: '森永卓郎氏（経済アナリスト、2025年1月逝去）',
        stance:
            '著書『ザイム真理教』（2023年）で、財務省が40年にわたり「財政均衡」路線を政治家・メディア・国民に浸透させてきたと批判し、警鐘を鳴らした。',
        sourceLabel: 'ダイヤモンド・オンライン',
        sourceUrl: 'https://diamond.jp/articles/-/358466',
        asOfDate: '2023年刊行・2025年1月時点',
      ),
      const IssueAdvocate(
        id: 'finance_ministry_narrative_kishi',
        challengeId: 'finance_ministry_narrative_control',
        type: 'individual',
        name: '岸博幸氏（元通産官僚・慶應義塾大学教授）',
        stance: '「財務省が全部悪い」という単純化した見方を検証し、財政規律の必要性を無視した議論には慎重であるべきだと反論している。',
        sourceLabel: 'ダイヤモンド・オンライン',
        sourceUrl: 'https://diamond.jp/articles/-/370799',
        asOfDate: '2024年時点',
      ),
    ],
  };
}
