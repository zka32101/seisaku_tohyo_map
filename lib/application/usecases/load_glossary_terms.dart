import '../../domain/entities/glossary_term.dart';

/// アプリ内の各コンテンツに登場する専門用語の解説データ
class LoadGlossaryTerms {
  static List<GlossaryTerm> call() {
    return const [
      GlossaryTerm(
        id: 'real_wage',
        term: '実質賃金',
        reading: 'じっしつちんぎん',
        definition:
            '物価の変動を考慮した、実際に買えるモノやサービスの量で見た賃金。'
            '給料の額面（名目賃金）が増えても、物価がそれ以上に上がると実質賃金は下がる。',
        category: 'economy',
      ),
      GlossaryTerm(
        id: 'nominal_wage',
        term: '名目賃金',
        reading: 'めいもくちんぎん',
        definition: '物価の変動を考慮せず、実際に受け取る金額そのままで見た賃金。給与明細に書かれている金額。',
        category: 'economy',
      ),
      GlossaryTerm(
        id: 'pay_as_you_go',
        term: '賦課方式',
        reading: 'ふかほうしき',
        definition:
            '現役世代が納めた保険料を、そのまま今の高齢者への年金支払いに充てる仕組み。'
            '日本の公的年金はこの方式が基本で、少子高齢化が進むと現役世代1人あたりの負担が増える。',
        category: 'welfare',
      ),
      GlossaryTerm(
        id: 'funded_system',
        term: '積立方式',
        reading: 'つみたてほうしき',
        definition:
            '自分が納めた保険料を積み立てて運用し、将来自分が受け取る仕組み。'
            '少子高齢化の影響を受けにくいが、インフレや運用リスクの影響を受けやすい。',
        category: 'welfare',
      ),
      GlossaryTerm(
        id: 'pension_reserve',
        term: '年金積立金',
        reading: 'ねんきんつみたてきん',
        definition: '将来の年金給付に備えて積み立てられている資金。GPIF（年金積立金管理運用独立行政法人）が運用している。',
        category: 'welfare',
      ),
      GlossaryTerm(
        id: 'gdp',
        term: 'GDP（国内総生産）',
        reading: 'じーでぃーぴー',
        definition: '一定期間内に国内で新たに生み出されたモノやサービスの付加価値の合計。国の経済規模を表す代表的な指標。',
        category: 'economy',
      ),
      GlossaryTerm(
        id: 'national_debt',
        term: '国債',
        reading: 'こくさい',
        definition: '国が財源不足を補うために発行する借金の証書。国債残高が積み上がると、将来世代の税負担や利払い費の増加につながる。',
        category: 'debt',
      ),
      GlossaryTerm(
        id: 'fiscal_deficit',
        term: '財政赤字',
        reading: 'ざいせいあかじ',
        definition: '国や自治体の1年間の収入（主に税収）よりも支出が多く、不足分を借金（国債発行など）で賄っている状態。',
        category: 'debt',
      ),
      GlossaryTerm(
        id: 'relative_poverty',
        term: '相対的貧困',
        reading: 'そうたいてきひんこん',
        definition:
            'その国の世帯所得の中央値の半分（貧困線）を下回る所得で暮らしている状態。'
            '生きるのに最低限必要な水準を下回る「絶対的貧困」とは異なり、その社会の平均的な生活水準と比べた格差を表す。',
        category: 'welfare',
      ),
      GlossaryTerm(
        id: 'birth_rate',
        term: '合計特殊出生率',
        reading: 'ごうけいとくしゅしゅっしょうりつ',
        definition:
            '1人の女性が生涯に産む子供の数の平均的な見込み値。人口を維持するには2.07程度が必要とされるが、日本は近年1.2前後で推移している。',
        category: 'demographic',
      ),
      GlossaryTerm(
        id: 'aging_society',
        term: '少子高齢化',
        reading: 'しょうしこうれいか',
        definition:
            '生まれる子供の数（出生率）が減る一方、平均寿命が延びて高齢者の割合が増えていく現象。'
            '現役世代1人あたりが支える高齢者の数が増え、社会保障や労働力の面で影響が大きい。',
        category: 'demographic',
      ),
      GlossaryTerm(
        id: 'social_security',
        term: '社会保障',
        reading: 'しゃかいほしょう',
        definition: '年金・医療・介護・生活保護など、病気・老後・失業といったリスクに備えて国民の生活を支える公的な仕組みの総称。',
        category: 'welfare',
      ),
      GlossaryTerm(
        id: 'consumption_tax',
        term: '消費税',
        reading: 'しょうひぜい',
        definition:
            'モノやサービスを購入した際にかかる税金。所得の多い少ないに関わらず同じ税率がかかるため、'
            '低所得者ほど負担割合が重くなる「逆進性」があるとされる。',
        category: 'economy',
      ),
      GlossaryTerm(
        id: 'ruling_party',
        term: '与党',
        reading: 'よとう',
        definition: '内閣を組織し政権を担当している政党。予算案や法案の決定に大きな影響力を持つ。対義語は「野党」。',
        category: 'politics',
      ),
      GlossaryTerm(
        id: 'childcare_waitlist_term',
        term: '待機児童',
        reading: 'たいきじどう',
        definition:
            '保育園などへの入園を希望しているが、定員オーバーなどの理由で入園できずに待機している子供。都市部で特に問題になりやすい。',
        category: 'welfare',
      ),
      GlossaryTerm(
        id: 'business_succession',
        term: '後継者不足',
        reading: 'こうけいしゃぶそく',
        definition:
            '経営者の高齢化が進む一方、事業を引き継ぐ後継者が見つからず、黒字であっても廃業に追い込まれる中小企業が増えている問題。',
        category: 'economy',
      ),
      GlossaryTerm(
        id: 'gender_pay_gap_term',
        term: '男女の賃金格差',
        reading: 'だんじょのちんぎんかくさ',
        definition:
            '同じように働いても男性と女性の間で平均賃金に差が生じている状態。管理職比率や勤続年数、非正規雇用比率の違いなどが要因とされる。',
        category: 'economy',
      ),
      GlossaryTerm(
        id: 'medical_expenses',
        term: '国民医療費',
        reading: 'こくみんいりょうひ',
        definition: '1年間に国民全体が病気やケガの治療のために使った医療費の総額。高齢化に伴い年々増加している。',
        category: 'welfare',
      ),
      GlossaryTerm(
        id: 'late_elderly',
        term: '後期高齢者',
        reading: 'こうきこうれいしゃ',
        definition: '75歳以上の高齢者のこと。医療費がかかりやすく、現役世代が納める「支援金」によって医療費の一部が支えられている。',
        category: 'welfare',
      ),
      GlossaryTerm(
        id: 'support_contribution',
        term: '支援金',
        reading: 'しえんきん',
        definition:
            '後期高齢者医療制度を支えるために、現役世代が加入する健康保険から拠出されるお金。現役世代の保険料負担を押し上げる要因の一つ。',
        category: 'welfare',
      ),
      GlossaryTerm(
        id: 'energy_self_sufficiency',
        term: 'エネルギー自給率',
        reading: 'えねるぎーじきゅうりつ',
        definition:
            '国内で消費するエネルギーのうち、自国で生産できている割合。日本は化石燃料の大半を輸入に頼っており、主要国の中でも低水準。',
        category: 'economy',
      ),
      GlossaryTerm(
        id: 'fdi',
        term: '対内直接投資',
        reading: 'たいないちょくせつとうし',
        definition:
            '海外の企業や投資家が、日本国内の企業に出資したり工場を作ったりすること。雇用創出や技術移転につながるが、日本は主要国と比べて少ない。',
        category: 'economy',
      ),
      GlossaryTerm(
        id: 'voter_turnout',
        term: '投票率',
        reading: 'とうひょうりつ',
        definition: '選挙で投票権を持つ有権者のうち、実際に投票した人の割合。日本では長期的に低下傾向にあり、特に若年層で低い。',
        category: 'politics',
      ),
      GlossaryTerm(
        id: 'vacant_house',
        term: '空き家率',
        reading: 'あきやりつ',
        definition: '住宅総数に占める、人が住んでいない空き家の割合。人口減少や地方からの人口流出に伴って上昇が続いている。',
        category: 'demographic',
      ),
      GlossaryTerm(
        id: 'extinction_municipality',
        term: '消滅可能性自治体',
        reading: 'しょうめつかのうせいじちたい',
        definition:
            '20〜39歳の若年女性人口が将来大きく減少し、人口を維持できなくなる可能性が高いと分析された自治体。地方の人口減少を象徴する言葉。',
        category: 'demographic',
      ),
      GlossaryTerm(
        id: 'income_stagnation_term',
        term: '所得の停滞',
        reading: 'しょとくのていたい',
        definition:
            '経済が成長しても、働く人の給料（実質賃金）がほとんど増えない状態が長期間続くこと。日本ではこの30年ほど顕著に見られる。',
        category: 'economy',
      ),
      GlossaryTerm(
        id: 'gdp_ratio',
        term: 'GDP比',
        reading: 'じーでぃーぴーひ',
        definition:
            '国債残高などの金額を、その国のGDP（経済規模）で割った比率。国の経済力に対して借金がどれくらい大きいかを国際比較する際によく使われる。',
        category: 'debt',
      ),
      GlossaryTerm(
        id: 'disaster_recovery',
        term: '災害復旧費',
        reading: 'さいがいふっきゅうひ',
        definition:
            '地震・台風・豪雨などの自然災害からの復旧・復興のために国や自治体が支出する費用。近年の災害の激甚化で増加傾向にある。',
        category: 'debt',
      ),
      GlossaryTerm(
        id: 'regional_healthcare_gap_term',
        term: '医師偏在',
        reading: 'いしへんざい',
        definition:
            '医師の数が都市部に集中し、地方では人口あたりの医師数が少なくなっている状態。必要な医療を受けにくい地域が生じる原因になる。',
        category: 'welfare',
      ),
      GlossaryTerm(
        id: 'generation_gap',
        term: '世代間格差',
        reading: 'せだいかんかくさ',
        definition:
            '年金や社会保障などの負担と給付のバランスが、生まれた年代によって異なること。'
            '一般に高齢世代ほど負担に比べて給付が手厚く、若い世代ほど負担が重くなる傾向が指摘されている。',
        category: 'welfare',
      ),
      GlossaryTerm(
        id: 'career_gap',
        term: '子供の貧困',
        reading: 'こどものひんこん',
        definition:
            '子供が経済的に厳しい家庭環境で育ち、教育や体験の機会が制限されてしまう状態。将来の進学や就職の選択肢の狭まりにもつながる。',
        category: 'welfare',
      ),
      GlossaryTerm(
        id: 'education_gap_term',
        term: '教育格差',
        reading: 'きょういくかくさ',
        definition: '家庭の所得や住んでいる地域によって、受けられる教育の質や進学率に差が生じること。',
        category: 'economy',
      ),
      GlossaryTerm(
        id: 'carbon_neutral',
        term: 'カーボンニュートラル',
        reading: 'かーぼんにゅーとらる',
        definition:
            '温室効果ガスの排出量と、森林などによる吸収量を差し引きゼロにすること。'
            '日本は2050年までの実現を目標に掲げている。',
        category: 'debt',
      ),
      GlossaryTerm(
        id: 'border_carbon_tax',
        term: '国境炭素税',
        reading: 'こっきょうたんそぜい',
        definition:
            '温室効果ガスの排出規制が緩い国から輸入される製品に対して、規制が厳しい国が上乗せして課す税・関税。'
            '脱炭素対応が遅れると、輸出企業がこの負担を受けやすくなる。',
        category: 'debt',
      ),
      GlossaryTerm(
        id: 'young_carer_term',
        term: 'ヤングケアラー',
        reading: 'やんぐけあらー',
        definition:
            '本来大人が担うような家事・家族の世話・介護などを日常的に行っている18歳未満（場合によっては20代の若者を含む）のこと。'
            '学業や友人関係に影響が出やすいが、家庭内のことのため周囲に気づかれにくい。',
        category: 'welfare',
      ),
      GlossaryTerm(
        id: 'digital_divide_term',
        term: 'デジタルデバイド',
        reading: 'でじたるでばいど',
        definition:
            'インターネットやデジタル機器を使いこなせる人と、そうでない人との間に生じる情報・機会の格差。'
            '高齢者や低所得層が不利益を受けやすいとされる。',
        category: 'politics',
      ),
      GlossaryTerm(
        id: 'isolated_death',
        term: '孤立死',
        reading: 'こりつし',
        definition:
            '誰にも看取られずに一人で亡くなり、しばらく発見されないケース。'
            '一人暮らし高齢者の増加や地域とのつながりの希薄化を背景に、都市部を中心に増加傾向にあるとされる。',
        category: 'demographic',
      ),
      GlossaryTerm(
        id: 'minsei_iin',
        term: '民生委員',
        reading: 'みんせいいいん',
        definition:
            '地域の高齢者・障害者・子育て家庭などの相談に応じ、行政サービスとの橋渡しを行う、'
            '厚生労働大臣から委嘱される非常勤・無報酬の地域ボランティア。',
        category: 'welfare',
      ),
    ];
  }
}
