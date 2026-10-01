import '../../domain/entities/party_stance.dart';
import '../../domain/entities/political_party.dart';

/// 主要6政党について、各課題（社会課題）の3つの対策案のうち、
/// 実際にどれが政党の公式な立場に最も近いかを、公式マニフェスト等を
/// Web検索で調査してまとめたデータ。
///
/// 【重要な注意】
/// - これは政党の公式見解ではなく、公開情報を基にした簡易的な分析です。
/// - 対策案は3択に単純化されているため、実際の政党の立場を完全には
///   表現できていません。特にconfidenceがlowの項目は、公式な言明が
///   見つからず、政党の一般的な傾向から推測したものです。
/// - 政党の立場は政治情勢により変化するため、調査基準日以降の
///   変化は反映されていません。
class LoadPartyPlatforms {
  LoadPartyPlatforms._();

  static const String researchedAt = '2026年9月';

  static const List<PoliticalParty> parties = [
    PoliticalParty(key: 'ldp', name: '自由民主党'),
    PoliticalParty(key: 'cdp', name: '立憲民主党'),
    PoliticalParty(key: 'ishin', name: '日本維新の会'),
    PoliticalParty(key: 'komeito', name: '公明党'),
    PoliticalParty(key: 'dpfp', name: '国民民主党'),
    PoliticalParty(key: 'jcp', name: '日本共産党'),
  ];

  /// 指定した政党の、課題ID→立場のマップ
  static Map<String, PartyStance> stancesFor(String partyKey) =>
      _stanceData[partyKey] ?? const {};

  /// 指定した政党が調査時に参照した情報源のURL一覧
  static List<String> sourcesFor(String partyKey) =>
      _sources[partyKey] ?? const [];

  static final Map<String, Map<String, PartyStance>> _stanceData = {
    'ldp': {
      'silver_democracy': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note:
            'ドメイン投票制のような急進的制度は自民党の主張に見当たらず、主権者教育や投票環境整備など若年層の投票率向上策という穏健路線が党の一般的傾向に近いと推測される。',
      ),
      'low_labor_productivity': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note:
            '自民党はDX投資促進税制・賃上げ促進税制・半導体等への設備投資減税・補助を経済対策の柱に据えており、DX・設備投資支援が党の一貫した方針である。',
      ),
      'unmarried_structure': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note:
            '国（自民党政権）は2021年度から自治体のAI婚活支援事業に補助金を出しており、出会い・マッチング支援への公的関与を少子化対策として推進してきた。',
      ),
      'reform_deferral': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note:
            '独立評価機関の新設のような抜本策より、痛みを伴う改革を激変緩和措置付きで段階的に進める手法が自民党の伝統的な政策運営スタイルに近いと考えられる。',
      ),
      'bureaucracy_influence': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note:
            '内閣人事局創設や官邸主導の政策決定強化など、官僚統制に対しては政治主導の強化で対応してきたのが自民党（特に安倍・菅政権以降）の路線である。',
      ),
      'money_in_politics': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note:
            '2024年の政治資金規正法再改正で自民党は企業・団体献金禁止には踏み込まず、政治資金のオンライン公開義務化（デジタル完全公開）を柱とした。',
      ),
      'press_independence': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note:
            '明確な党方針は見当たらないが、NHK改革論議など公共放送のあり方に継続的に関与してきた経緯から、この選択肢が党の関心領域に最も近いと推測される。',
      ),
      'electoral_wasted_votes': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note:
            '自民党は比例代表拡大や中選挙区制復活には一貫して否定的で、政権の安定性を理由に現行の小選挙区比例代表並立制の維持を志向してきた。',
      ),
      'amakudari_structure': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note:
            '安倍政権下で各省庁による斡旋を禁止する一方、官民人材交流センターを設け官民の人材交流を前提とした再就職支援の枠組みへ移行した経緯がある。',
      ),
      'local_fiscal_dependency': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note:
            '小泉政権の「三位一体の改革」に代表されるように、自民党は国庫補助金削減・交付税改革とあわせて税源移譲による地方税拡充を進めてきた。',
      ),
      'policy_evaluation_weakness': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '内閣府を中心にEBPM（証拠に基づく政策立案）の推進が政府の行政改革方針として明記され、自民党政権下で制度化が進められている。',
      ),
      'vote_value_disparity': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note:
            '衆院はアダムズ方式を導入しつつ、参院では合区拡大に地方の反発が強く、自民党は合区を増やす抜本改革より特定枠のような別の仕組みでの対応を選んできた。',
      ),
      'hereditary_politicians': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note:
            '2024年の政治資金規正法改正で自民党は、政治家関連団体の代表者や寄付先を配偶者・三親等以内の親族に引き継ぐことを制限する規定を導入した。',
      ),
      'ministry_silos': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: 'デジタル庁・こども家庭庁・GX実行会議など、自民党政権は縦割り打破のため官邸直属の横断的な司令塔機能を次々と新設してきた。',
      ),
      'kantei_led_politics': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '森友・加計問題以降、自民党政権は公文書管理に関するガイドライン改定など文書管理の厳格化で対応してきた実績がある。',
      ),
      'non_regular_employment': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note:
            '安倍政権の働き方改革関連法（2018年）で同一労働同一賃金が法制化されており、非正規雇用の待遇是正の柱として位置づけられてきた。',
      ),
      'low_startup_rate': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '岸田政権の「スタートアップ育成5か年計画」は公的資金の呼び込み・税制優遇など資金調達環境の整備を中心政策としている。',
      ),
      'caregiver_shortage': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '自民党政権は介護職員処遇改善加算を繰り返し拡充しており、賃上げによる処遇改善が一貫した対応策となっている。',
      ),
      'single_parent_poverty': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '「こども未来戦略」加速化プランで児童扶養手当の第3子加算拡大・所得制限緩和が盛り込まれ、給付拡充が中心的施策となっている。',
      ),
      'tokyo_concentration': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note:
            '石破政権が掲げる「地方創生2.0」は二地域居住の推進を目玉政策としており、リモートワーク・多拠点居住への制度支援が最新の重点分野である。',
      ),
      'foreign_worker_coexistence': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note:
            '技能実習制度を廃止し育成就労制度を創設した2024年入管法改正は、在留資格を特定技能へ段階的に移行させるキャリアパスの明確化が主眼である。',
      ),
      'local_assembly_shortage': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '2023年の地方自治法改正で議員の兼業規制緩和が図られるなど、報酬・兼業ルールの見直しが対応の中心となってきた。',
      ),
      'candidacy_deposit_barrier': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note:
            '供託金の大幅引き下げには与党として慎重な姿勢がうかがえ、明確な公約は見当たらないため、没収基準の緩和など小幅な見直しにとどまると推測する。',
      ),
      'defense_budget_funding': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note:
            '政府・自民党は防衛費増額財源の4分の3を歳出改革・剰余金活用でまかない、増税（法人税等）は4分の1にとどめ実施時期も先送りする方針を取った。',
      ),
      'special_account_opacity': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '小泉・第一次安倍政権期の行政改革推進法により特別会計を31から大幅に統廃合した実績があり、自民党の伝統的アプローチと言える。',
      ),
      'income_stagnation': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note:
            '石破首相は所信表明で2020年代に全国平均最低賃金1500円という数値目標を明言しており、最低賃金引き上げが明確な党の方針である。',
      ),
      'pension_crisis': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note:
            '2025年成立の年金制度改革法は厚生年金・基礎年金のマクロ経済スライド調整期間を揃え基礎年金を底上げする仕組みで、受給開始年齢の一律引き上げは見送られた。',
      ),
      'population_decline': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '「異次元の少子化対策」「こども未来戦略」は自民党の人口減少対策の中心であり、子育て支援の抜本拡充を最優先課題としている。',
      ),
      'politician_salary': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note:
            '2024年政治資金規正法改正では政策活動費の将来公開などが盛り込まれ、報酬・経費の情報公開強化が自民党の対応の基本線となっている。',
      ),
      'national_debt': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note:
            '自民党財政政策検討本部は単年度PB黒字化への機械的なこだわりを見直し対GDP債務比率の安定化を掲げ、高市政権も成長重視の積極財政路線を志向している。',
      ),
      'child_poverty': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: 'こども未来戦略のもとで児童扶養手当の拡充や大学等授業料後払い制度・給付型奨学金の拡大が具体策として進められている。',
      ),
      'regional_extinction': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '「まち・ひと・しごと創生」以来の地方創生交付金はUIJターンや企業誘致・移住促進を中心的な手段としてきた。',
      ),
      'healthcare_cost': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note:
            '2026年の自民・維新による社会保障改革合意は年齢によらない応能負担の実現に向け高齢者の窓口負担見直しを打ち出しており、自己負担割合の見直しが焦点である。',
      ),
      'education_gap': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note: '2024年度から多子世帯の大学授業料無償化を開始するなど、給付型奨学金・授業料減免の拡大が近年の目玉政策となっている。',
      ),
      'women_in_politics': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note:
            '自民党はクオータ制導入には否定的で、女性候補擁立政党への助成や党役員への女性登用など候補者育成・支援策で対応する立場を取ってきた。',
      ),
      'energy_dependency': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note: 'GX実行会議の方針通り、自民党は原子力を重要なベースロード電源と位置づけ、安全性確認済みの原発の再稼働を推進している。',
      ),
      'elderly_medical_burden': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note:
            '2026年の社会保障改革骨子は現役世代の保険料負担軽減を狙い、高齢者の窓口負担・支援金負担のあり方を応能負担の観点で見直すとした。',
      ),
      'foreign_direct_investment': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '対日直接投資推進会議は行政手続きの英語対応・ワンストップ化など規制緩和・手続簡素化をビジネス環境整備の柱としてきた。',
      ),
      'voter_turnout_decline': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note: '自民党はセキュリティ上のリスクからオンライン投票導入には慎重で、期日前投票や投票所の利便性向上など漸進的な対応を重視してきた。',
      ),
      'housing_vacancy': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note:
            '2023年の空家対策特別措置法改正で「管理不全空家」制度を新設し、管理不十分な空き家の固定資産税優遇を解除できる仕組みを導入した。',
      ),
      'childcare_waitlist': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note: '2016年創設の企業主導型保育事業は認可外の多様な保育形態を活用し待機児童解消を図る自民党政権の主要施策である。',
      ),
      'sme_succession_crisis': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '事業承継税制の特例措置（2018年～）と中小企業M&A支援の拡充は自民党の後継者不足対策の中心的な柱となっている。',
      ),
      'gender_pay_gap': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '2022年の女性活躍推進法改正で301人以上企業に男女間賃金格差の公表を義務化しており、情報公開が政策の起点となっている。',
      ),
      'disaster_recovery_cost': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '国土強靭化基本法・5か年加速化対策・15か年計画など、事前防災とインフラ強靭化への大規模投資は自民党の看板政策である。',
      ),
      'regional_healthcare_gap': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note: '厚労省の医師偏在対策（2024年～）は診療報酬上の経済的インセンティブによる地方勤務誘導を柱の一つとしている。',
      ),
      'climate_change_response': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note:
            'GX基本方針は原子力活用と省エネを両輪としつつ、本格的な炭素税ではなく緩やかなGX賦課金にとどめており自民党の慎重姿勢を示している。',
      ),
      'young_carers': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note:
            '2024年の子ども・若者育成支援推進法改正でヤングケアラーを法律上定義し支援対象に明記するなど、法制度化による対応が進められた。',
      ),
      'digital_divide': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: 'マイナンバーカードと健康保険証の一体化など、カードの利便性拡大は自民党政権のデジタル行政改革の中心施策であり続けている。',
      ),
      'isolated_elderly': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note:
            '厚労省が進める地域包括ケア・地域共生社会づくりの方針から、地域コミュニティ・居場所づくりの強化が党の基本姿勢に近いと推測される。',
      ),
      'finance_ministry_narrative_control': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note:
            '「ザイム真理教」論争への明確な党公式見解は確認できないが、対立を煽る改革より財政・経済教育の充実といった穏健な対応が自民党の姿勢に近いと推測する。',
      ),
    },
    'cdp': {
      'silver_democracy': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '党の主権者教育・投票環境改善路線から若年層の投票率向上策が最も近いと推測されるが、ドメイン投票制など直接の言及は見当たらない。',
      ),
      'low_labor_productivity': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note: '連合系労組を支持基盤とする立憲は長時間労働是正・働き方改革を一貫して重視しており、労働時間規制強化が最も近い。',
      ),
      'unmarried_structure': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '子ども・子育てビジョンで非正規雇用の解消と賃上げ加速を掲げており、若年層の雇用安定・所得向上重視の姿勢が読み取れる。',
      ),
      'reform_deferral': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '独立財政機関構想など第三者的評価機関の設置を志向する傾向から推測した低確度の判断。',
      ),
      'bureaucracy_influence': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '民主党政権以来の「脱官僚・政治主導」路線（国家戦略局構想など）を継承しており、政治主導の政策立案機能強化が近い。',
      ),
      'money_in_politics': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '企業・団体献金禁止法案を提出するなど、企業・団体献金の廃止を政治改革の最重要項目として掲げている。',
      ),
      'press_independence': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: 'NHK人事への政権関与や放送への政治圧力を批判しており、公共放送の独立性強化路線に近い。',
      ),
      'electoral_wasted_votes': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '多様な民意反映やクオータ制支持など多元的代表制志向から比例重視と推測されるが、明確な制度改革案は確認できなかった。',
      ),
      'amakudari_structure': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '「脱官僚」路線の系譜から天下り規制の実効性強化を重視する立場と考えられる。',
      ),
      'local_fiscal_dependency': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '地方主権・地域主権を掲げる党是から税源移譲による地方税拡充路線が近いと判断（所属議員の三位一体改革批判等）。',
      ),
      'policy_evaluation_weakness': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '行政監視・第三者機関重視の姿勢からの推測で、直接の政策文言は確認できなかった。',
      ),
      'vote_value_disparity': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '合区解消のための改憲には反対し、法改正（アダムズ方式の徹底など）での是正を志向している。',
      ),
      'hereditary_politicians': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '候補者公募を広く行ってきた党の慣行から、公募・予備選挙拡大路線が近いと推測。',
      ),
      'ministry_silos': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '民主党政権期の国家戦略局構想など、首相官邸主導の横断的司令塔機能強化を志向する系譜がある。',
      ),
      'kantei_led_politics': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '森友・加計・桜を見る会等の公文書改ざん問題を一貫して追及しており、公文書管理の厳格化を重視している。',
      ),
      'non_regular_employment': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '連合と連携し同一労働同一賃金の実効性強化を重視する労働政策を掲げている。',
      ),
      'low_startup_rate': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: 'セーフティーネット重視の社会保障観からの推測で、開業支援に関する具体的言及は確認できなかった。',
      ),
      'caregiver_shortage': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '2025年8月に介護報酬の期中改定を厚労相へ要請し、全産業平均に向けた処遇改善（賃上げ）の継続を明確に主張している。',
      ),
      'single_parent_poverty': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '児童手当の所得制限撤廃・拡充を掲げる子育て政策の延長として、児童扶養手当拡充路線が近い。',
      ),
      'tokyo_concentration': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '地域主権・地方分権志向から企業・政府機関の地方移転促進が近いと推測される。',
      ),
      'foreign_worker_coexistence': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '独自の「外国人労働者安心就労法案」を提出し、在留資格や就労の安心確保を重視する姿勢を示している。',
      ),
      'local_assembly_shortage': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '多様な人材の政治参画を促す立場から議員報酬・兼業規制の見直しが近いと推測。',
      ),
      'candidacy_deposit_barrier': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '政治参加の障壁除去を重視する立場から供託金引き下げが近いと推測される。',
      ),
      'defense_budget_funding': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '防衛費増額の根拠不明確さやFMS調達・イージスアショア等の無駄を批判しており、歳出改革優先の姿勢が読み取れる。',
      ),
      'special_account_opacity': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '野党として国会審議の実質化・監視機能強化を重視する立場からの推測。',
      ),
      'income_stagnation': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '中小企業支援を前提に最低賃金を早期に全国1500円以上へ引き上げる公約を掲げている。',
      ),
      'pension_crisis': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note:
            '2025年の年金改革法案で自公とともにマクロ経済スライドを維持する法案に賛成しており、積立方式移行や支給開始年齢引き上げは主張していない。',
      ),
      'population_decline': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '児童手当所得制限撤廃、教育無償化等を柱とする「子ども・子育てビジョン」で子育て支援の抜本拡充を掲げている。',
      ),
      'politician_salary': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '政治資金の完全公開を重視する政治改革路線の延長として、議員報酬・経費の情報公開強化が近い。',
      ),
      'national_debt': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '消費税の逆進性是正や富裕層・金融所得への課税強化など応能負担的な歳入確保を志向する傾向がある。',
      ),
      'child_poverty': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '児童手当拡充や給付型奨学金拡大を重視する子育て政策の柱と整合的。',
      ),
      'regional_extinction': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '「選択と集中」型の拠点強化より、地方分権・広範な地域振興を志向する党の姿勢から推測。',
      ),
      'healthcare_cost': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '高額療養費の自己負担増や後期高齢者の窓口負担2割化に反対する立場から、自己負担増より予防医療重視と推測。',
      ),
      'education_gap': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '幼児期から高等教育までの無償化・給付型奨学金拡充を教育政策の柱として掲げている。',
      ),
      'women_in_politics': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '国政選挙における候補者男女均等のクオータ制導入に賛成し、パリテ実現を掲げている。',
      ),
      'energy_dependency': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '原発の新増設を認めず、2030年に再エネ電源比率50%を目指す「自然エネルギー立国」ロードマップを掲げている。',
      ),
      'elderly_medical_burden': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '後期高齢者の窓口負担2割化に反対し、高所得高齢者の保険料上限引き上げで財源を賄う対案を提示、現役世代の負担軽減を志向している。',
      ),
      'foreign_direct_investment': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note: '法人減税より人材育成・インフラ整備等の公共投資を重視する党の経済観からの推測。',
      ),
      'voter_turnout_decline': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note: '投票環境の改善（期日前投票拡充など）を重視する一般的な野党姿勢からの推測。',
      ),
      'housing_vacancy': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '具体的な言及は確認できず、公共投資・補助による対応を重視する一般傾向からの推測。',
      ),
      'childcare_waitlist': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '保育士の配置基準見直しなど保育士の処遇・人員拡充を子育て政策の柱の一つとして掲げている。',
      ),
      'sme_succession_crisis': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '税制優遇より人材支援・研修等の支援型施策を志向する傾向からの推測。',
      ),
      'gender_pay_gap': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note: '非正規雇用の待遇改善・同一労働同一賃金を労働政策の柱としており、賃金格差是正の主軸と位置づけていると考えられる。',
      ),
      'disaster_recovery_cost': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '能登復興予算の増額を求めるなど公共投資拡充を重視する姿勢から事前防災投資寄りと推測。',
      ),
      'regional_healthcare_gap': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '地域医療の公的確保を重視する社会保障観からの推測で、直接の政策文言は確認できなかった。',
      ),
      'climate_change_response': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '2030年再エネ50%・脱原発を掲げる「自然エネルギー立国」構想が気候変動対応の柱となっている。',
      ),
      'young_carers': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note: '各種社会課題への議員立法提出を重視する党の手法から、法制度化路線が近いと推測。',
      ),
      'digital_divide': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: 'マイナンバー制度の性急な運用拡大に慎重な立場を取ってきており、デジタル弱者支援の重視が近いと考えられる。',
      ),
      'isolated_elderly': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '地域包括ケア等コミュニティベースの福祉を重視する姿勢からの推測。',
      ),
      'finance_ministry_narrative_control': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '政治改革全般で審議会・有識者会議の透明化を重視する姿勢からの推測で、直接の言及は確認できなかった。',
      ),
    },
    'ishin': {
      'silver_democracy': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note:
            '維新はEBPMやサンセット条項など制度的な評価・検証の仕組み化を好む傾向があり、シルバー民主主義対策も世代別インパクト評価の制度化に親和的と推測されるが、この論点への直接の公約は確認できなかった。',
      ),
      'low_labor_productivity': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note: '維新は結党以来「労働市場の流動化」を掲げ、転職支援や職業訓練を通じた市場重視の生産性向上を志向してきた。',
      ),
      'unmarried_structure': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note:
            '維新の経済政策は減税・成長重視で若年層の所得・雇用の安定化に主眼を置いており、婚姻支援より経済的基盤強化を優先すると推測される。',
      ),
      'reform_deferral': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '維新は政治主導・EBPMを重視し、独立財政機関(IFI)構想など第三者的な評価機関の設置を志向する傾向があるため。',
      ),
      'bureaucracy_influence': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note:
            '維新は「政治主導」を統治機構改革の柱としており、財務省など官僚機構への対抗軸として政治主導の政策立案機能強化を一貫して主張している。',
      ),
      'money_in_politics': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note:
            '維新は党内規則で企業・団体献金を全面禁止しており、2024年以降の政治改革大綱でも企業・団体献金と政策活動費の廃止を明記している。',
      ),
      'press_independence': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '橋下徹氏を中心に大阪市長時代から記者クラブの開放(フリー・海外メディアへの門戸開放)を実践・主張してきた経緯がある。',
      ),
      'electoral_wasted_votes': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note:
            '維新は比例代表の議席拡大ではなく逆に比例削減(45議席減)を自民との連立合意に盛り込んでおり、小選挙区中心の現行制度維持・政権安定を志向している。',
      ),
      'amakudari_structure': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note:
            '2026年の公務員制度改革提言では国家公務員志望者減少を背景に官民人材交流を軸としたキャリアパス整備を打ち出しており、単純な天下り禁止より人材循環路線に近い。',
      ),
      'local_fiscal_dependency': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '道州制・大阪都構想など統治機構改革の核心は地方への税源移譲による財政的自立であり、維新の一貫した理念に合致する。',
      ),
      'policy_evaluation_weakness': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note: '大阪維新行政では期限付き施策・サンセット条項的な運用を好む傾向があり、EBPMより制度的な期限設定を重視すると推測される。',
      ),
      'vote_value_disparity': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note:
            '維新は身を切る改革や定数是正など制度のルール化・機械的な是正を志向しており、アダムズ方式による定期的な定数見直しの徹底と整合的。',
      ),
      'hereditary_politicians': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '維新は候補者を公募・予備選挙的な手続きで選ぶことを党の伝統としており、世襲によらない候補者選定を体現してきた。',
      ),
      'ministry_silos': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '統治機構改革における政治主導・司令塔機能強化路線の延長として、省庁横断の強力な司令塔機能を志向すると考えられる。',
      ),
      'kantei_led_politics': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '森友・加計問題等を受け、維新は国会審議で公文書管理の厳格化を強く求めてきた経緯があり、透明性重視の姿勢と整合的。',
      ),
      'non_regular_employment': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note: '自民・維新の連立合意は「全世代型社会保障」を掲げ、雇用形態によらない社会保険の適用拡大を志向する路線と整合的。',
      ),
      'low_startup_rate': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note:
            '維新は規制緩和・成長戦略を重視する立場から起業環境整備(資金調達支援等)を志向すると推測されるが、本論点への直接の言及は確認できなかった。',
      ),
      'caregiver_shortage': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note:
            '維新はDX推進を統治機構改革・行政効率化の柱としており、増税を伴う恒常的な賃上げ財源確保よりロボット・ICT活用による効率化を志向すると推測される。',
      ),
      'single_parent_poverty': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note: '維新は労働市場の流動化や自立支援を重視する立場から、給付拡充より就労・スキルアップ支援を通じた自立促進を志向すると考えられる。',
      ),
      'tokyo_concentration': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '維新の看板政策である「副首都構想」は大阪等への政府機関・企業機能の移転を明文化しており、直接的に合致する。',
      ),
      'foreign_worker_coexistence': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note:
            '維新は外国人労働者の受け入れについて「特定技能2号」等の資格要件の厳格化や外国人人口比率の上限設定を求めており、在留資格・キャリアパスの明確化を重視する立場が確認できる。',
      ),
      'local_assembly_shortage': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note: '大阪府議会定数を109から79へ削減した実績があり、広域連合・広域議会構想を通じた議員定数の見直しが党の一貫した路線。',
      ),
      'candidacy_deposit_barrier': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '既存候補者に有利な高額供託金の是正案として供託金の大幅引き下げが提案されており、新規参入を促す維新の反既得権益志向と整合的。',
      ),
      'defense_budget_funding': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note:
            '2022年は防衛増税に反対していたが、2025年10月の自民との連立合意書で目的を明確にした「防衛特別所得税」導入に合意しており、現在の実際の立場はbに合致する。',
      ),
      'special_account_opacity': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note:
            '維新・橋下氏は特別会計の「埋蔵金」問題を繰り返し批判してきており、積立金・剰余金の定期公開と使途説明の徹底を志向する透明性重視路線と整合的。',
      ),
      'income_stagnation': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note:
            '食料品消費税ゼロ等、減税による可処分所得増加を一貫して主張しており、最低賃金の強制的引き上げには2012年綱領で慎重姿勢を示した経緯もある。',
      ),
      'pension_crisis': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note:
            '維新は公的年金の「積立方式」への移行を看板政策として掲げ、マクロ経済スライド温存に反対して2025年の年金改革法案に反対票を投じた。',
      ),
      'population_decline': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note:
            '教育・保育の完全無償化(所得制限撤廃)を看板政策とし、外国人受け入れには人口比上限を求める等慎重であるため、子育て支援の抜本拡充が最も近い。',
      ),
      'politician_salary': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note: '「身を切る改革」として歳費2割自主カットを継続し、議員定数・報酬の3割カットを公約としており、直接合致する。',
      ),
      'national_debt': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '医療費4兆円削減など社会保障費の効率化を通じた歳出改革を一貫して掲げ、財政健全化とプライマリーバランス黒字化を重視している。',
      ),
      'child_poverty': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '給付型奨学金を含む教育の完全無償化路線が維新の一貫した重点政策であるため。',
      ),
      'regional_extinction': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '道州制・広域連合構想など行政サービスの広域連携・集約を統治機構改革の柱としているため。',
      ),
      'healthcare_cost': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note:
            '「医療費を4兆円削減し現役世代の社保料を6万円軽減」を参院選公約に掲げ、年齢によらない応能負担への窓口負担見直しを推進している。',
      ),
      'education_gap': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note: '所得制限のない高校無償化や給付型奨学金拡充、大学無償化推進など、授業料減免・奨学金拡充策が維新の代表的な教育政策。',
      ),
      'women_in_politics': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note:
            '維新は「性別を問わず有能な人材の政治参画」を強調しクオータ制導入には距離があり、公募制度の伝統から政治教育・候補者育成支援がより近い。',
      ),
      'energy_dependency': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note: '維新代表(松井氏ら)は原発の早期再稼働を繰り返し主張し、安全基準確認を前提とした再稼働推進を明確に掲げている。',
      ),
      'elderly_medical_burden': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note:
            '自民・維新連立合意書に「医療費窓口負担に関する年齢によらない真に公平な応能負担の実現」が明記され、現役世代の支援金負担のあり方見直しに直結する。',
      ),
      'foreign_direct_investment': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '維新の経済政策の基軸は規制緩和であり、行政手続きの簡素化を通じた投資環境整備を志向すると考えられる。',
      ),
      'voter_turnout_decline': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: 'マイナンバー活用等デジタル化を重視する維新の姿勢から、オンライン投票導入に親和的と考えられる。',
      ),
      'housing_vacancy': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '市場メカニズムを通じた流通促進を好む維新の姿勢から、空き家バンク等の流通促進策がより近いと推測される。',
      ),
      'childcare_waitlist': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '大阪維新行政では企業主導型保育等多様な保育形態の活用に積極的で、規制緩和路線と整合的。',
      ),
      'sme_succession_crisis': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '成長戦略・税制優遇を重視する維新の経済政策の延長として、事業承継税制やM&A支援の拡充が近いと推測される。',
      ),
      'gender_pay_gap': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note:
            'クオータ制のような数値割当には慎重な一方、政治資金の完全公開など情報開示を重視する姿勢から、賃金格差の情報公開義務化が近いと推測される。',
      ),
      'disaster_recovery_cost': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note:
            '自民との連立合意にも国土強靱化関連施策が含まれており、事前防災・インフラ強靭化投資路線が穏当な推測となるが、維新固有の直接公約は確認できなかった。',
      ),
      'regional_healthcare_gap': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '行政・医療のDX推進を一貫して重視する維新の姿勢から、オンライン診療・遠隔医療拡充が近いと考えられる。',
      ),
      'climate_change_response': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note: '原発再稼働推進と省エネ技術投資の両輪という組み合わせは、維新のエネルギー政策(原発活用+新税導入への慎重姿勢)と直接整合する。',
      ),
      'young_carers': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '新規の給付制度創設より既存の介護・福祉サービス供給拡大による対応を志向すると推測されるが、直接の公約は確認できなかった。',
      ),
      'digital_divide': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '自民・維新連立合意はマイナ保険証移行など行政デジタル化を推進しており、マイナンバーカードの利便性拡大路線と整合的。',
      ),
      'isolated_elderly': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note:
            '小さな政府・DX重視の維新の姿勢から、公務員(民生委員)増員より見守りサービス・IoT機器活用による対応を志向すると推測される。',
      ),
      'finance_ministry_narrative_control': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '記者クラブ開放を主張してきた維新の透明性志向の延長として、財務省の記者レクの記録・公開徹底が近いと考えられる。',
      ),
    },
    'komeito': {
      'silver_democracy': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '公明党青年委員会は若者への政策アンケート等で若年層の政治参加・投票率向上を重視しており、その延長線上の推測。',
      ),
      'low_labor_productivity': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '中小企業の賃上げ原資確保のため生産性向上投資やDX支援を重視する公明党の中小企業政策から推測。',
      ),
      'unmarried_structure': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note:
            '「子育て応援トータルプラン」で結婚支援を少子化対策の柱の一つに掲げ、地方議員が結婚新生活支援・婚活支援事業を推進してきた実績から。',
      ),
      'reform_deferral': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '急激な負担増を避け激変緩和措置を重視する公明党の漸進的な改革姿勢からの推測。',
      ),
      'bureaucracy_influence': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '政治資金や予算の透明化を重視する公明党の「情報公開」志向からの推測。',
      ),
      'money_in_politics': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note:
            '2025年10月に自民との連立離脱の主因が企業・団体献金規制への不満で、2026年に国民民主と共同で献金規制強化法案を提出した。',
      ),
      'press_independence': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '公共放送のあり方に関する明確な政策方針は確認できず、一般的な公共性重視の立場からの推測。',
      ),
      'electoral_wasted_votes': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '比例代表議席に基盤を持つ党として、都道府県別非拘束名簿式比例代表制など比例重視の制度改革を議論している。',
      ),
      'amakudari_structure': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '直接の言及は見つからず、情報公開重視の党の姿勢からの推測。',
      ),
      'local_fiscal_dependency': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '地方議員数最大の党として地方税源の充実・地方分権を志向する傾向からの推測。',
      ),
      'policy_evaluation_weakness': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '現場の声をアンケートで集め政策に反映する手法（「小さな声を聴く力」）から、根拠に基づく政策立案志向を推測。',
      ),
      'vote_value_disparity': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '自公連立下でアダムズ方式が衆院選挙区割りに導入された経緯があり、その延長線上の立場と考えられる。',
      ),
      'hereditary_politicians': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '創価学会を支持母体とし家系による世襲慣行が薄い党であり、公募型の候補者選定を志向すると推測。',
      ),
      'ministry_silos': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '公明党はデジタル庁創設を主導し、府省横断の「司令塔機能」強化を明確に推進した。',
      ),
      'kantei_led_politics': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '森友問題等を経て公文書管理の適正化を重視する「クリーンな政治」の党是からの推測。',
      ),
      'non_regular_employment': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note: '「年収の壁」対策等で雇用形態によらない社会保険適用拡大を重視する社会保障政策の方向性と一致。',
      ),
      'low_startup_rate': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '中小企業・小規模事業者支援を重視する党の姿勢からセーフティーネット整備を推測。',
      ),
      'caregiver_shortage': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '2026年度介護報酬改定で処遇改善加算の対象拡大を厚労省と協議するなど、継続的な処遇改善を主導している。',
      ),
      'single_parent_poverty': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '児童扶養手当の第3子加算増額など、ひとり親家庭支援として同手当の拡充を一貫してリードしてきた。',
      ),
      'tokyo_concentration': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: 'デジタル田園都市国家構想を推進した連立与党の一角として、デジタル活用による多拠点居住支援を志向すると推測。',
      ),
      'foreign_worker_coexistence': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '技能実習制度を廃止し人材育成・確保を目的とする育成就労制度の創設を提言、転籍要件緩和などキャリアパス明確化を主導した。',
      ),
      'local_assembly_shortage': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '全国最大の地方議員数を持つ党として、なり手確保のため議員報酬見直しや兼業要件緩和を支持すると考えられる。',
      ),
      'candidacy_deposit_barrier': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '女性・若者の立候補障壁低減を重視する党の姿勢から供託金引き下げを支持すると推測。',
      ),
      'defense_budget_funding': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note:
            '防衛費増額の財源として法人・所得・たばこ税による目的を明確にした増税を自公で決定し、税制調査会長も安定財源の必要性を強調している。',
      ),
      'special_account_opacity': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note: '剰余金・積立金の使途説明責任を重視する財政透明化志向からの推測。',
      ),
      'income_stagnation': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '最低賃金を5年以内に全国平均1500円へ引き上げる目標を掲げ、青年委員会の政策提言で最低賃金引き上げを一貫して主導してきた。',
      ),
      'pension_crisis': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note:
            '2004年の「100年安心年金」改革でマクロ経済スライドの仕組み導入を主導した党であり、その枠組み維持・強化を志向すると考えられる。',
      ),
      'population_decline': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '児童手当の抜本拡充など「子育て応援トータルプラン」を掲げ、少子化対策としての子育て支援拡充を党の最重要政策としている。',
      ),
      'politician_salary': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '政治とカネ問題への対応として議員の経費・資金の情報公開強化を重視する立場と一致する。',
      ),
      'national_debt': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note:
            '2025年参院選重点政策は「物価高を乗り越える経済と社会保障の構築」を掲げ、賃上げと経済成長を通じた税収増を重視し増税には慎重。',
      ),
      'child_poverty': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '児童扶養手当の拡充や給付型奨学金拡大など、子どもの貧困対策として経済的給付の拡充を一貫して主導している。',
      ),
      'regional_extinction': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '地方創生・移住促進策を重視する連立与党としての立場からの推測。',
      ),
      'healthcare_cost': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '自己負担増に慎重な福祉重視の党として予防医療・健診強化を優先すると推測。',
      ),
      'education_gap': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note: '高等教育費の負担軽減拡充、高校無償化拡大、給付型奨学金拡充を2024衆院選公約の柱としている。',
      ),
      'women_in_politics': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '政党アンケートでクオータ制導入に「賛成」と回答し、党内でも女性国会議員比率30%（将来50%）の目標を掲げている。',
      ),
      'energy_dependency': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note:
            '「省エネ、再生可能エネルギー、蓄電池などの活用を思い切って進めるべきだ」と代表が発言するなど再エネ拡大を基本方針としている（既存原発の再稼働は容認）。',
      ),
      'elderly_medical_burden': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '介護・医療分野で予防・重症化予防への投資を重視する社会保障政策の一貫した方向性から推測。',
      ),
      'foreign_direct_investment': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '直接的な言及は見つからず、規制改革を重視する連立与党としての一般的立場からの推測。',
      ),
      'voter_turnout_decline': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note: '強力な地上組織を持つ党として期日前投票の利便性向上など実務的な投票環境整備を支持すると推測。',
      ),
      'housing_vacancy': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note:
            '2013年に党内に空き家対策プロジェクトチームを設置し、空き家バンク制度の導入を全国の地方議員ネットワークで推進、空家対策特別措置法制定を主導した。',
      ),
      'childcare_waitlist': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '保育士等の処遇改善（月額賃上げ）を政府に提言し実現、「こども誰でも通園制度」など保育の受け皿拡充を一貫して推進している。',
      ),
      'sme_succession_crisis': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '中小企業支援を重視する党として事業承継税制の延長・拡充を毎年度支持してきた税制調査会の姿勢から推測。',
      ),
      'gender_pay_gap': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '既存の男女間賃金格差の情報公開義務化制度と整合的な、透明化を重視する党の一般傾向からの推測。',
      ),
      'disaster_recovery_cost': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '「防災・減災・国土強靱化」は公明党（太田昭宏氏ら）が長年主導してきた看板政策であり、事前防災投資を一貫して重視している。',
      ),
      'regional_healthcare_gap': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: 'マイナ保険証やデジタル化を重視する党の傾向からオンライン診療拡充を推測。',
      ),
      'climate_change_response': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note:
            '2022年参院選公約でカーボンニュートラルに向け再エネ最大限導入を掲げ、GX脱炭素電源法にも賛成し「再エネ拡大」を基本方針としている。',
      ),
      'young_carers': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note:
            '「子育て応援トータルプラン」でヤングケアラー支援強化を掲げ、改正児童福祉法で支援対象への法的位置付けや18歳以降の継続支援を主導した。',
      ),
      'digital_divide': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: 'マイナンバーカードの普及促進と各種給付・手続きのオンライン化による利便性向上を、デジタル庁創設とあわせて重視している。',
      ),
      'isolated_elderly': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '「地域共生社会推進本部」を設置するなど、地域コミュニティを基盤とした支援体制づくりを重視する党の姿勢と一致する。',
      ),
      'finance_ministry_narrative_control': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '政治とカネ問題で情報公開・透明化を重視してきた党の一貫した姿勢から、レクの記録・公開徹底を推測。',
      ),
    },
    'dpfp': {
      'silver_democracy': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note:
            '国民民主党は世代間の不公平是正を党の中核メッセージとしているが、投票制度改革の具体案は確認できず、世代別政策インパクト評価的な発想と親和的と推測した推論。',
      ),
      'low_labor_productivity': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '2025年参院選政策でAI・半導体への投資減税やDX投資支援を明確に掲げており、設備投資減税路線が明確。',
      ),
      'unmarried_structure': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '「手取りを増やす」を党の最重要スローガンとし若年層の所得向上を一貫して訴えており、所得・雇用安定重視の立場と整合的。',
      ),
      'reform_deferral': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note:
            '玉木代表は経済学者出身でエビデンスに基づく政策立案（EBPM）を重視する発言が多く、独立した政策評価機関的な発想に親和的と推論。',
      ),
      'bureaucracy_influence': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '「ザイム真理教」論争で財務省の影響力を批判し政治主導の強化を繰り返し訴えており、政治主導路線が明確。',
      ),
      'money_in_politics': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note: '公明党と共同で国会に「政治資金監視委員会」設置法案を提出しており、第三者機関による監査強化の立場が明確。',
      ),
      'press_independence': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '直接の言及は確認できず、既存メディアの構造的閉鎖性に批判的な同党の改革志向から記者クラブ開放寄りと推論。',
      ),
      'electoral_wasted_votes': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note: '現行制度の抜本改革を優先課題としている証拠は見当たらず、政治資金・世襲対策等を優先する現状の姿勢から現行制度維持寄りと推論。',
      ),
      'amakudari_structure': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '政治資金のデジタル公開など情報公開重視の党姿勢から、天下り情報の完全公開・データベース化路線が近いと推論。',
      ),
      'local_fiscal_dependency': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '民主党以来の「地域主権」路線を引き継ぎ地方分権を重視する系譜から、税源移譲による地方税拡充路線が近いと推論。',
      ),
      'policy_evaluation_weakness': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '経済学者出身の玉木代表がエビデンスに基づく政策立案（EBPM）を繰り返し強調しており、制度化路線と整合的。',
      ),
      'vote_value_disparity': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '直接の言及は確認できず、法定のアダムズ方式を前提に既存制度の適正運用を重視する穏健な立場と推論。',
      ),
      'hereditary_politicians': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '参院選候補者を公募で選定する事例（香川選挙区など）が確認でき、公募・予備選挙拡大路線と整合的。',
      ),
      'ministry_silos': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '「政治主導」を掲げ官邸・司令塔機能強化を志向する同党の基本姿勢から、横断的司令塔機能強化路線が近いと推論。',
      ),
      'kantei_led_politics': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '民主党政権下の公文書問題等を踏まえ透明性を重視する系譜から、公文書管理厳格化路線が近いと推論。',
      ),
      'non_regular_employment': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note: '106万円・130万円の「壁」是正など就労形態にかかわらない社会保険適用拡大が「手取りを増やす」政策と密接に関連。',
      ),
      'low_startup_rate': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '投資減税や成長戦略を重視する経済政策の方向性から、起業資金調達環境整備を優先する立場と推論。',
      ),
      'caregiver_shortage': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '各分野での処遇改善・賃上げを一貫して重視する「手取りを増やす」路線の延長として介護職員の処遇改善継続が整合的。',
      ),
      'single_parent_poverty': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '政策パンフレットで児童手当の増額・支給期間延長や所得制限撤廃を明記しており、手当拡充路線が明確。',
      ),
      'tokyo_concentration': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '直接の言及は確認できないが、DXを重視する同党の姿勢からリモートワーク・多拠点居住支援路線が近いと推論。',
      ),
      'foreign_worker_coexistence': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '技能実習制度の見直しを求め、在留資格や受け入れ上限、待遇確保など制度面の整備を強く主張している。',
      ),
      'local_assembly_shortage': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '処遇改善を重視する同党の一貫した姿勢から、議員報酬見直し・兼業ルール緩和路線が近いと推論。',
      ),
      'candidacy_deposit_barrier': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '直接の言及は確認できず、政治参加の裾野拡大を志向する改革政党としての立場から供託金引き下げ路線と推論。',
      ),
      'defense_budget_funding': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '消費税減税やガソリン税廃止など一貫して増税に慎重な姿勢を示しており、歳出改革優先・増税最小限路線と整合的。',
      ),
      'special_account_opacity': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note: '財務省の情報の不透明さを批判し政治資金でも徹底したデジタル公開を求める姿勢から、剰余金等の定期公開路線が近い。',
      ),
      'income_stagnation': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note: '「103万円の壁」を178万円へ引き上げる公約を柱に「手取りを増やす」を党是としており、減税による可処分所得増加が中心政策。',
      ),
      'pension_crisis': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note:
            '受給開始年齢引き上げや積立方式移行を明言した証拠はなく、最低保障年金構想と両立しうる現行のマクロ経済スライド強化路線に近いと推論。',
      ),
      'population_decline': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '教育国債による子育て・教育予算倍増や児童手当拡充など、子育て支援の抜本拡充を政策の柱としている。',
      ),
      'politician_salary': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '政治資金監視委員会設置法案など政治とカネの情報公開強化を一貫して求めており、透明性強化路線と整合的。',
      ),
      'national_debt': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note: '「高圧経済」論や2035年実質GDP1000兆円達成など経済成長を通じた税収増を重視する積極財政路線を明確に掲げている。',
      ),
      'child_poverty': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '給付型奨学金の所得制限撤廃や児童手当拡充を明記しており、手当・奨学金拡充路線が明確。',
      ),
      'regional_extinction': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '民主党以来の地域重視路線から、選択と集中よりも幅広い地方への企業誘致・移住促進策を志向すると推論。',
      ),
      'healthcare_cost': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '「年齢ではなく負担能力に応じた窓口負担」を掲げており、自己負担割合の見直し路線が明確。',
      ),
      'education_gap': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note: '高校までの教育費完全無償化や奨学金の所得制限撤廃を明記しており、給付型奨学金・授業料減免拡大路線が中心。',
      ),
      'women_in_politics': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: 'クオータ制への明確な支持表明は確認できず、公募中心の候補者選定方針から両立支援等の環境整備路線に近いと推論。',
      ),
      'energy_dependency': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.high,
        note: '安全基準を満たした原発の再稼働・建て替え・新増設推進と再エネ賦課金停止を明記しており、原発活用継続路線が明確。',
      ),
      'elderly_medical_burden': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '現役世代の社会保険料軽減と負担能力に応じた窓口負担を掲げ、現役世代の支援金負担割合見直しを明確に志向している。',
      ),
      'foreign_direct_investment': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: 'AI・半導体への投資減税など税制インセンティブを重視する成長戦略路線と整合的。',
      ),
      'voter_turnout_decline': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '直接の言及は確認できないが、デジタル化重視の党の姿勢からオンライン投票導入路線に親和的と推論。',
      ),
      'housing_vacancy': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '補助金より市場メカニズムを重視する同党の傾向から、空き家バンク等の流通促進策路線に近いと推論。',
      ),
      'childcare_waitlist': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '3歳からの義務教育化による待機児童ゼロを掲げるなど施設・保育士増員に近い方向性を示している。',
      ),
      'sme_succession_crisis': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '直接の言及は確認できないが、税制を通じた経済対策を重視する党の傾向から事業承継税制・M&A支援路線に近いと推論。',
      ),
      'gender_pay_gap': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note: 'クオータ制等の数値目標より非正規雇用の待遇改善・同一労働同一賃金を重視する労働政策の方向性から推論。',
      ),
      'disaster_recovery_cost': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '積極財政・投資重視の経済政策の方向性から、事前防災・インフラ強靱化投資路線に近いと推論。',
      ),
      'regional_healthcare_gap': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: 'デジタル化・DXを重視する党の姿勢から、オンライン診療・遠隔医療拡充路線に親和的と推論。',
      ),
      'climate_change_response': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note: '原発再稼働推進と再エネ賦課金停止を掲げる一方、炭素税導入には慎重であり、原子力活用と省エネ投資の両輪路線が近い。',
      ),
      'young_carers': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note: '政治資金監視委員会法案など具体的立法による課題解決を好む党の手法から、法制度化路線に近いと推論。',
      ),
      'digital_divide': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note: '行政効率化・DXを重視する党の一般的姿勢から、行政システムの標準化・共通化路線に近いと推論。',
      ),
      'isolated_elderly': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: 'デジタル技術活用を重視する党の傾向から、見守りサービス・IoT機器普及支援路線に近いと推論。',
      ),
      'finance_ministry_narrative_control': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note: '玉木代表は自らデータを用いて財務省の説明に反論する発信を続けており、一次データを読み解く財政・経済教育充実の方向性と整合的。',
      ),
    },
    'jcp': {
      'silver_democracy': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: 'ドメイン投票制のような特殊な制度提案は確認できず、主権者教育・投票環境整備を重視する党の一般姿勢からの推測。',
      ),
      'low_labor_productivity': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note: '1日7時間・週35時間労働の実現など長時間労働是正・労働時間規制の強化を一貫して掲げている。',
      ),
      'unmarried_structure': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '非正規雇用の是正や最低賃金引き上げなど若者の雇用安定・所得向上を未婚化・少子化対策の柱としている。',
      ),
      'reform_deferral': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note: '直接の記述は見当たらないが、国民参加・合意形成を重視する党の姿勢から世代間合意形成プロセスの制度化に近いと推測。',
      ),
      'bureaucracy_influence': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '財務省主導の不透明な予算編成への批判（ザイム真理教論争等）から、予算編成過程の透明化・公開を志向すると判断。',
      ),
      'money_in_politics': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '2024年11月に「企業・団体献金全面禁止法案」を提出するなど、企業・団体献金の全面禁止を党の最重点政策としている。',
      ),
      'press_independence': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: 'しんぶん赤旗が原子力規制委員会や万博協会の記者会見から排除された経緯を批判し、記者クラブの開放（会見排除の撤廃）を求めてきた。',
      ),
      'electoral_wasted_votes': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '小選挙区制を廃止し比例代表を中心とした制度に抜本改革すべきだと主張しており、比例代表の議席比率拡大に最も近い。',
      ),
      'amakudari_structure': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '天下りを厳しく批判してきた党の姿勢から、再就職規制の実効性強化を志向すると推測。',
      ),
      'local_fiscal_dependency': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '「地方分権の最大の課題は国から地方への税源移譲」と一貫して主張し、税源移譲による地方税拡充を求めている。',
      ),
      'policy_evaluation_weakness': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '直接の言及は乏しいが、政治資金等での第三者機関による監査強化を求める姿勢から第三者評価の義務化に近いと推測。',
      ),
      'vote_value_disparity': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '一票の平等を重視し違憲状態の是正を求める立場から、頻繁な定数配分見直し（アダムズ方式徹底）に近いと判断。',
      ),
      'hereditary_politicians': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note: '政治とカネ・後援会組織による特権的な地盤継承を問題視する党の姿勢から、資金・後援会組織の引き継ぎ制限が近いと推測。',
      ),
      'ministry_silos': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '官邸主導の権力集中には批判的な立場のため、司令塔機能強化より予算の一括計上・共同事業化が近いと推測（明確な言及は確認できず）。',
      ),
      'kantei_led_politics': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '公文書の隠蔽・改ざん問題を繰り返し批判し、公文書管理法の抜本改正・保存期間の抜け穴是正を求めている。',
      ),
      'non_regular_employment': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '「同一価値労働同一賃金と均等待遇」をメーデースローガン等で明確に掲げている。',
      ),
      'low_startup_rate': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '起業支援そのものへの重点は薄く、失業・生活保障などセーフティーネット重視の一般路線から推測。',
      ),
      'caregiver_shortage': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '配置基準緩和ではなく介護報酬引き上げ等による処遇改善（賃上げ）こそ必要だと明確に主張している。',
      ),
      'single_parent_poverty': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '児童扶養手当をはじめとする現金給付の拡充を重視する党の一貫した福祉拡充路線から判断。',
      ),
      'tokyo_concentration': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note: '全国一律最低賃金や地域経済・中小企業支援による地方の雇用安定を重視しており、地方就労支援拡充に近いと推測。',
      ),
      'foreign_worker_coexistence': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '人権侵害の温床となっている技能実習制度の廃止と外国人受け入れ制度の抜本改正（在留資格の明確化）を求めている。',
      ),
      'local_assembly_shortage': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '地方議員のなり手不足について明確な政策は確認できないが、庶民が議員になりやすい環境整備を重視する立場から推測。',
      ),
      'candidacy_deposit_barrier': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '300万円の供託金を「世界に例をみないほど異常に高額」「反民主主義の制度」と批判し、引き下げ・改革を求めている。',
      ),
      'defense_budget_funding': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '43兆円の大軍拡自体と防衛特別税に反対しており、増税を最小限にする方向性が相対的に近いが、実際は軍拡自体の撤回を主張している。',
      ),
      'special_account_opacity': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '国会審議・行政監視の実質化を重視する党の姿勢から、特別会計の個別審査強化が近いと判断。',
      ),
      'income_stagnation': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '「今すぐ最低賃金1500円、さらに1700円へ」を明確に掲げている。',
      ),
      'pension_crisis': PartyStance(
        closestOptionId: null,
        confidence: StanceConfidence.high,
        note:
            '支給開始年齢引き上げにもマクロ経済スライド強化にも積立方式移行にも反対し、高所得者の保険料負担引き上げ等独自財源で「減らない年金」を主張しており、3択いずれにも一致しない。',
      ),
      'population_decline': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '子育て支援の抜本拡充（学費無償化・保育拡充・児童手当拡充等）を人口減少対策の中心に据えている。',
      ),
      'politician_salary': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '政治資金の透明化・情報公開を重視する一方、議員定数削減には「民意を切り捨てる」として断固反対しており、情報公開強化が最も近い。',
      ),
      'national_debt': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: '社会保障費削減には反対し、大企業・富裕層への課税強化など歳入確保（増税）路線を重視している。',
      ),
      'child_poverty': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '児童扶養手当拡充・給付型奨学金創設（自宅4万円・自宅外8万円等）を具体的に提案している。',
      ),
      'regional_extinction': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '「選択と集中」による地方切り捨て政策を批判しており、消去法的に企業誘致・移住促進策が相対的に近いと推測。',
      ),
      'healthcare_cost': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '後期高齢者の窓口負担2割化に反対するなど自己負担増に一貫して反対しており、予防医療重視の方向性が近いと判断。',
      ),
      'education_gap': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '35人学級の推進など少人数学級を含む公教育への投資拡大を継続的に求めている。',
      ),
      'women_in_politics': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '党自身が候補者の50%以上を女性にするなど実践しており、候補者男女均等（クオータ制的発想）を重視していると判断。',
      ),
      'energy_dependency': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '原発ゼロ・再稼働反対を掲げ、2030年までに電力の40%を再エネで賄う目標を明確にしている。',
      ),
      'elderly_medical_burden': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '給付削減や負担増につながる「効率化」路線に批判的なため、予防・重症化予防への投資が相対的に近いと推測。',
      ),
      'foreign_direct_investment': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note: '規制緩和・法人減税路線には批判的な立場のため、人材・インフラ整備による環境整備が消去法的に近いと推測。',
      ),
      'voter_turnout_decline': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.medium,
        note: '地方での投票所削減に反対するなど投票アクセスの利便性維持を重視する立場から判断。',
      ),
      'housing_vacancy': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '明確な政策は確認できないが、公的支援による対応を重視する一般路線から解体・再活用への補助が近いと推測。',
      ),
      'childcare_waitlist': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '公的責任での認可保育所整備・保育士増員、配置基準改善（2024年4月実現）を一貫して重視している。',
      ),
      'sme_succession_crisis': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '中小企業支援を重視する党の一般路線から、公的な人材バンク・研修整備が市場主導のM&A支援より近いと推測。',
      ),
      'gender_pay_gap': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.high,
        note: '「低く抑え込まれてきた女性の賃金を引き上げ男女賃金格差を是正する」として非正規の待遇改善・同一労働同一賃金を明示している。',
      ),
      'disaster_recovery_cost': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '公共投資による防災・インフラ整備を重視する党の一般路線から、事前防災投資が近いと判断。',
      ),
      'regional_healthcare_gap': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.low,
        note: '公的医療体制の計画的整備を重視する立場から、地方勤務医師への公的支援・義務化的制度が近いと推測。',
      ),
      'climate_change_response': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.high,
        note: '原発に頼らず再生可能エネルギーへの投資を加速することを気候変動・エネルギー政策の柱としている。',
      ),
      'young_carers': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.low,
        note: '介護・福祉人材不足の解消と公的サービス供給拡大を重視する党の路線から、福祉サービス供給拡大が近いと推測。',
      ),
      'digital_divide': PartyStance(
        closestOptionId: 'b',
        confidence: StanceConfidence.medium,
        note: 'マイナンバー制度の強制的な普及には反対しており、デジタル弱者への人的サポート拡充が党の姿勢に近い。',
      ),
      'isolated_elderly': PartyStance(
        closestOptionId: 'c',
        confidence: StanceConfidence.low,
        note: '公的福祉人員の拡充を一貫して重視する党の路線から、民生委員・訪問支援の人員拡充が近いと推測。',
      ),
      'finance_ministry_narrative_control': PartyStance(
        closestOptionId: 'a',
        confidence: StanceConfidence.medium,
        note: '財界代表偏重の審議会構成を批判してきた党の姿勢から、審議会・有識者会議の人選多様化・公開が近いと判断。',
      ),
    },
  };

  static final Map<String, List<String>> _sources = {
    'ldp': [
      'https://www.jimin.jp/policy/',
      'https://www.jimin.jp/policy/pamphlet/',
      'https://www.jimin.jp/news/policy/210775.html',
      'https://www.jimin.jp/news/policy/210945.html',
      'https://www.nri.com/jp/media/column/kiuchi/20240926.html',
      'https://diamond.jp/articles/-/350864',
      'https://www.nli-research.co.jp/files/topics/36476_ext_18_0.pdf?site=nli',
      'https://www.jcp.or.jp/akahata/aik24/2024-12-25/2024122501_03_0.html',
      'https://www.nri.com/jp/media/column/kiuchi/20231205.html',
      'https://www.hokkaido-np.co.jp/article/1248639/',
      'https://ryukyushimpo.jp/editorial/entry-261037.html',
      'https://www.moneypost.jp/1286612',
      'https://kumanichi.com/articles/1939741',
      'https://www.hokkaido-np.co.jp/article/1271394/',
      'https://www.oanda.jp/lab-education/market_news/kn_2026061801001102/',
      'https://sp.m.jiji.com/english/show/7279',
      'https://www.dir.co.jp/report/research/economics/japan/20241017_024674.pdf',
      'https://www.kobe-np.co.jp/opinion/202410/0018248482.shtml',
      'https://www.kobe-np.co.jp/opinion/202502/0018675585.shtml',
      'https://toyokeizai.net/articles/-/5127?display=b',
      'https://www.sakigake.jp/news/article/20260707CO0061/',
      'https://diamond-fudosan.jp/articles/-/1113044',
      'https://www.shugiin.go.jp/Internet/itdb_rchome.nsf/html/rchome/Horitsu/seijikaikaku67F6C857BF00892B49258CC700314A39.htm',
      'https://www.businessinsider.jp/article/288432/',
    ],
    'cdp': [
      'https://cdp-japan.jp/assets/pdf/visions/diet-report_2025/diet-report_2025_all.pdf',
      'https://cdp-japan.jp/files/download/34Io/nSMu/WJTd/sbwl/34IonSMuWJTdsbwlkpLWejlX.pdf',
      'https://cdp-japan.jp/files/download/S55H/9IT5/hRfx/IDgL/S55H9IT5hRfxIDgLvA1NO69H.pdf',
      'https://cdp-japan.jp/files/download/fKPV/AXyE/MQqC/c2QQ/fKPVAXyEMQqCc2QQrddo7t5c.pdf',
      'https://cdp-japan.jp/files/download/8Lob/C9rI/EIjP/dKpi/8LobC9rIEIjPdKpiOUkdE4og.pdf',
      'https://newparty.cdp-japan.jp/files/download/YG1F/2apz/gTTw/Yu76/YG1F2apzgTTwYu769HwvEUBl.pdf',
      'https://nccu.gr.jp/wp-content/uploads/2025/08/来年4月の介護・障害福祉サービス等報酬の引き上げ等を求める要請20250819.pdf',
      'https://www.sakigake.jp/news/article/20251218AK0004/',
      'https://www.hokkaido-np.co.jp/article/1265117/',
      'https://www.gender.go.jp/policy/seijibunya/pdf/r06.pdf',
      'https://ryukyushimpo.jp/editorial/entry-1318009.html',
      'https://www.sakigake.jp/news/article/20260422CO0126/',
      'https://www.jtuc-rengo.or.jp/activity/seisaku_jitsugen/teigen/?p=2183',
      'https://www.nri.com/jp/media/column/kiuchi/20250804_2.html',
      'https://cdp-japan.jp/files/download/gLJ7/LgJ8/vULF/xkbC/gLJ7LgJ8vULFxkbCAu9E578p.pdf',
      'https://www.jcp.or.jp/akahata/aik25/2025-06-13/2025061301_02_0.html',
    ],
    'ishin': [
      'https://o-ishin.jp/policy/pdf/ishinhassaku2024CorePolicy.pdf',
      'https://www.sakigake.jp/news/article/20260121CO0052/',
      'https://www.nri.com/jp/media/column/kiuchi/20251020_2.html',
      'https://www.kobe-np.co.jp/opinion/202512/0019779418.shtml',
      'https://www.jcp.or.jp/akahata/aik25/2025-10-24/2025102402_01_0.html',
      'https://www.jcp.or.jp/akahata/aik24/2024-11-28/2024112802_02_0.html',
      'https://www.jcp.or.jp/akahata/aik25/2025-05-31/2025053101_03_0.html',
      'https://president.jp/articles/-/93300',
      'https://www.sakigake.jp/news/article/20251018CO0113/',
      'https://www.jcp.or.jp/akahata/aik25/2025-12-20/2025122001_03_0.php',
      'https://www.hokkaido-np.co.jp/article/1229335/',
      'https://www.kobe-np.co.jp/opinion/202601/0019964368.shtml',
      'https://sp.m.jiji.com/english/show/20619',
      'https://www.sakigake.jp/news/article/20251204CO0116/',
      'https://www.sakigake.jp/news/article/20260707CO0061/',
      'https://gentosha-go.com/articles/-/51482?page=2',
      'https://www.tkfd.or.jp/research/detail.php?id=1035',
      'https://www.jcp.or.jp/akahata/aik24/2024-10-22/2024102204_01_0.html',
      'https://www.hokkaido-np.co.jp/article/1302472/',
      'https://www.pref.osaka.lg.jp/documents/55512/chukanrontenseiri.pdf',
    ],
    'komeito': [
      'https://www.komei.or.jp/komeinews/p372041/',
      'https://www.komei.or.jp/komeinews/p415467/',
      'https://www.komei.or.jp/km/otsu-sato-hiroshi/2025/05/13/%E3%80%90%E7%89%A9%E4%BE%A1%E9%AB%98%E5%AF%BE%E7%AD%96%E3%81%AF%E6%B6%88%E8%B2%BB%E7%A8%8E%E6%B8%9B%E7%A8%8E%E3%81%8C%E5%9F%BA%E6%9C%AC%E3%80%91%E5%85%AC%E6%98%8E%E5%85%9A-%E6%94%BF%E8%AA%BF%E4%BC%9A/',
      'https://www.komei.or.jp/komeinews/p436580/',
      'https://www.komei.or.jp/km/maehigashi/2026/07/01/%E6%94%BF%E6%B2%BB%E3%81%A8%E3%82%AB%E3%83%8D%E3%80%80%E6%B1%BA%E7%9D%80%E3%81%A4%E3%81%91%E3%82%8B/',
      'https://www.sakigake.jp/news/article/20251012CO0036/',
      'https://www.komei.or.jp/komeinews/p469031/',
      'https://www.komei.or.jp/komeinews/p298426/',
      'https://ryukyushimpo.jp/editorial/entry-1414848.html',
      'https://www.komei.or.jp/km/taniguchi-mutsuo-kariya/2026/08/14/%E3%83%A4%E3%83%B3%E3%82%B0%E3%82%B1%E3%82%A2%E3%83%A9%E3%83%BC%E6%94%AF%E6%8F%B4%E3%80%80%EF%BC%91%EF%BC%98%E6%AD%B3%E4%BB%A5%E9%99%8D%E3%81%A8%E5%AE%B6%E6%97%8F%E3%82%82%E5%88%87%E3%82%8C%E7%9B%AE/',
      'https://www.komei.or.jp/iwoman/woman/20241007tayounakoewoseijini.html',
      'https://www.komei.or.jp/iwoman/woman/20240405kosodateouen.html',
      'https://www.komei.or.jp/news/detail/20150527_17060',
      'https://www.komei.or.jp/komeinews/p473858/',
      'https://kumanichi.com/articles/1912051',
      'https://www.jcp.or.jp/akahata/aik25/2025-06-13/2025061301_02_0.html',
      'https://www.komei.or.jp/km/takatsuki-yoshida-akihiro/2021/08/30/',
    ],
    'dpfp': [
      'https://www.dpfp.or.jp/download/41022.pdf',
      'https://president.jp/articles/-/90750',
      'https://www.nri.com/jp/media/column/kiuchi/20251112_2.html',
      'https://www.hokkaido-np.co.jp/article/1157113/',
      'https://sp.m.jiji.com/english/show/20426',
      'https://www.dpfp.or.jp/download/47621.pdf',
      'https://resemom.jp/article/2026/01/29/84837.html',
      'https://www.minshin.or.jp/download/38040.pdf',
      'https://www.newsweekjapan.jp/articles/-/45262?page=2',
      'https://www.dpfp.or.jp/download/40744.pdf',
      'https://gendai.media/articles/-/149890',
      'https://gendai.media/articles/-/143397',
      'https://bunshun.jp/bungeishunju/articles/h12603',
      'https://www.moomoo.com/jp/learn/how-will-the-national-democratic-party-s-fiscal-mobilization-affect-the-economy-and-the-market',
      'https://toyokeizai.net/articles/-/846804?display=b',
      'https://news.ksb.co.jp/ann/article/16706046',
      'https://www.kobe-np.co.jp/opinion/202507/0019237218.shtml',
      'https://www.dpfp.or.jp/assets/election2019/downloads/seisaku-index-2019_20190630.pdf',
      'https://gendai.media/articles/-/168624',
      'https://www.jetro.go.jp/biznews/2026/06/927997cb5944ae54.html',
    ],
    'jcp': [
      'https://www.jcp.or.jp/web_policy/12665.html',
      'https://www.jcp.or.jp/akahata/aik24/2024-11-27/2024112703_01_0.html',
      'https://www.jcp.or.jp/web_policy/2024/11/post-995.html',
      'https://www.jcp.or.jp/web_policy/12107.html',
      'https://www.jcp.or.jp/akahata/aik25/2025-07-17/2025071703_01_0.html',
      'https://jcp-kyoto.jp/jcp2016/wp-content/uploads/2025/02/b36666d365433d3f96cf22f921d4e7f8.pdf',
      'https://www.jcp.or.jp/akahata/aik25/2025-04-28/2025042803_01_0.html',
      'https://www.jcp-tokyo.net/wordpress/wp-content/uploads/2019/06/190625macroslide.pdf',
      'https://www.jcp.or.jp/akahata/aik19/2019-06-28/2019062801_01_1.html',
      'https://www.jcp.or.jp/akahata/aik26/2026-09-10/2026091002_01_0.php',
      'https://www.jcp.or.jp/web_policy/2024/10/202410-bunya32.html',
      'https://www.jcp.or.jp/akahata/aik25/2025-07-06/2025070601_03_0.html',
      'https://www.jcp.or.jp/web_policy/2022/12/post-939.html',
      'https://www.jcp.or.jp/akahata/aik25/2025-12-27/2025122702_01_0.php',
      'https://www.jcp.or.jp/web_policy/15976.html',
      'https://www.jcp.or.jp/akahata/aik26/2026-05-29/2026052902_04_0.php',
      'https://www.jcp.or.jp/akahata/aik23/2023-06-01/2023060103_01_0.html',
      'https://www.jcp.or.jp/web_policy/2024/10/202410-bunya65.html',
      'https://www.jcp.or.jp/web_policy/2024/10/202410-bunya25.html',
      'https://www.jcp.or.jp/cms/wp-content/uploads/2026/01/202601-hoiku-bira-n.pdf',
      'https://www.jcp.or.jp/web_policy/2023/06/post-957.html',
      'https://www.jcp.or.jp/web_policy/11703.html',
      'https://www.jcp.or.jp/web_policy/16348.html',
      'https://www.jcp.or.jp/akahata/aik25/2025-08-25/2025082502_01_0.html',
      'https://www.jcp.or.jp/akahata/aik18/2019-03-25/2019032504_09_1.html',
      'https://www.jcp.or.jp/akahata/aik22/2022-10-01/2022100101_03_0.html',
      'https://www.jcp.or.jp/akahata/aik21/2021-06-04/2021060401_04_1.html',
      'https://www.jcp.or.jp/akahata/aik21/2021-09-01/2021090102_02_0.html',
      'https://www.jcp.or.jp/akahata/aik23/2023-05-24/2023052403_01_0.html',
      'https://www.jcp.or.jp/akahata/aik23/2023-10-02/2023100204_02_0.html',
      'https://www.jcp.or.jp/akahata/aik26/2026-05-16/2026051602_04_0.php',
      'https://www.jcp.or.jp/web_policy/2024/12/post-997.html',
      'https://www.jcp.or.jp/seisaku/seitou-jyoseikin/jyoseikin-no.html',
      'https://www.jcp.or.jp/akahata/aik24/2024-12-18/2024121802_01_0.html',
      'https://www.jcp.or.jp/akahata/aik25/2025-12-05/2025120503_01_0.php',
      'https://www.jcp.or.jp/akahata/aik25/2025-06-13/2025061301_02_0.html',
      'https://www.jcp.or.jp/web_policy/16168.html',
      'https://www.jcp.or.jp/web_policy/12516.html',
      'https://www.jcp.or.jp/akahata/aik16/2017-03-11/2017031104_02_1.html',
      'https://www.jcp.or.jp/akahata/aik25/2025-04-20/2025042002_01_0.html',
      'https://www.jcp.or.jp/akahata/aik21/2021-08-12/2021081201_05_0.html',
    ],
  };
}
