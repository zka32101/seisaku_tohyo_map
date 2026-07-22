import '../../domain/entities/diet_bill.dart';

/// 課題に関連する、実際の国会の法案・議案データ
///
/// 国会の審議状況は日々変化するため、この一覧はWeb検索で確認した時点のスナップショットであり、
/// 定期的な更新が必要。ユーザー向けにも「情報時点」を明示し、一次情報源へのリンクを添えている。
class LoadDietBills {
  static List<DietBill> forChallenge(String challengeId) {
    return _data[challengeId] ?? const [];
  }

  static final Map<String, List<DietBill>> _data = {
    'my_pension_balance': [_pensionReformBill],
    'pension_crisis': [_pensionReformBill],
    'politician_salary': [
      const DietBill(
        id: 'political_funds_control_act_amendment',
        challengeId: 'politician_salary',
        billName: '政治資金規正法等の一部を改正する法律',
        status: '一部施行済み（2026年1月〜）／衆院政治改革特別委員会で追加改正案を審議中',
        summary:
            '政治資金パーティーの対価の公開基準額を「20万円超」から「5万円超」に引き下げ、'
            '国会議員関係政治団体の代表者に確認書の提出を義務付け、政策活動費の支出に関する透明性を強化する内容。'
            '2026年6月には衆議院の政治改革特別委員会で、さらなる改正案の審議が行われている。',
        effect:
            '政治資金パーティー収入の公開基準額引き下げにより、これまで不透明だった小口収入も含めて透明性が高まる。'
            '政策活動費の使途公開強化で、税金や献金がどう使われているか国民が監視しやすくなる。'
            '一方、罰則の実効性や抜け道の有無については引き続き国会で議論が続いており、実際に不透明な支出が減るかは今後の運用次第。',
        sourceLabel: '総務省 資料',
        sourceUrl: 'https://www.soumu.go.jp/main_content/000954678.pdf',
        asOfDate: '2026年7月時点',
      ),
    ],
    'disaster_recovery_cost': [
      const DietBill(
        id: 'disaster_prevention_agency_bill',
        challengeId: 'disaster_recovery_cost',
        billName: '防災庁設置法案',
        status: '衆院通過（2026年5月19日）・参議院で審議中',
        summary:
            '内閣府の防災担当を格上げし、復興庁・デジタル庁と同格の「防災庁」を新設する法案。'
            '首相を長とし専任の担当大臣を置き、他省庁への勧告権を持たせ、予防から復旧・復興までを一元的に担う。'
            '政府は2026年11月の発足を目指している。',
        effect:
            '防災の司令塔機能が一つの組織にまとまることで、災害時の初動対応や省庁間の調整が速くなることが期待される。'
            '事前防災（堤防やインフラの整備等）への投資が充実すれば、中長期的には復旧費用そのものの抑制にもつながりうる。'
            '一方、新組織の立ち上げ・運営には新たな予算・人員が必要で、実際にどこまで縦割りの壁を崩せるかは今後の運用次第。',
        sourceLabel: '日本経済新聞',
        sourceUrl:
            'https://www.nikkei.com/article/DGXZQOUA182SM0Y6A510C2000000/',
        asOfDate: '2026年7月時点',
      ),
    ],
    'childcare_waitlist': [
      const DietBill(
        id: 'child_support_act_amendment',
        challengeId: 'childcare_waitlist',
        billName: '子ども・子育て支援法等の一部を改正する法律',
        status: '2026年4月1日施行済み',
        summary:
            '2026年4月から「子ども・子育て支援金制度」の賦課・徴収が始まり、健康保険料と合わせて'
            '少子化対策の財源を徴収する仕組みが導入された。あわせて、保育所等に通っていない'
            '満3歳未満の子どもを対象とする「こども誰でも通園制度」も創設されている。',
        effect:
            '「こども誰でも通園制度」により、保育所に入っていない未就園児も一時的に保育サービスを利用できるようになり、'
            '在宅育児中の家庭の負担軽減や、待機児童問題の周辺にある「預け先がない」という悩みの緩和が期待される。'
            '一方、支援金制度により健康保険料に上乗せする形で現役世代・企業の負担が新たに発生する。',
        sourceLabel: 'こども家庭庁 資料',
        sourceUrl:
            'https://www.cfa.go.jp/assets/contents/node/basic_page/field_ref_resources/ba94b64b-731f-4f48-97ba-b54a76b0aeb6/a528abca/20240216_councils_shienkin-daijinkonwakai_03.pdf',
        asOfDate: '2026年7月時点',
      ),
    ],
    'digital_divide': [
      const DietBill(
        id: 'my_number_act_amendment',
        challengeId: 'digital_divide',
        billName: 'マイナンバー法等の一部を改正する法律案',
        status: '参議院特別委員会で可決・今国会での成立を目指す',
        summary:
            'マイナンバーカードの全機能をスマートフォンに搭載できるようにし、銀行・証券口座開設時などに'
            '物理カードをかざす必要をなくす内容。マイナンバーの利用範囲を社会保障・税以外の制度にも拡大し、'
            '行政手続きのデジタル完結を進めることが柱となっている。',
        effect:
            'カード機能のスマホ搭載により、物理カードを持ち歩く必要がなくなり利便性が向上する。'
            'マイナンバーの利用範囲拡大で、これまで書類提出や窓口対応が必要だった手続きがオンラインで完結しやすくなる可能性がある。'
            '一方、利用範囲が広がるほど、情報漏えいやなりすまし利用への対策の実効性が今まで以上に問われることになる。',
        sourceLabel: '日本経済新聞',
        sourceUrl:
            'https://www.nikkei.com/article/DGXZQOUA2843I0Y4A520C2000000/',
        asOfDate: '2026年7月時点',
      ),
    ],
    'isolated_elderly': [
      const DietBill(
        id: 'loneliness_isolation_act',
        challengeId: 'isolated_elderly',
        billName: '孤独・孤立対策推進法',
        status: '施行済み（2024年4月1日）',
        summary:
            '孤独・孤立を「社会全体の課題」と法律に明記し、内閣府に首相を本部長とする孤独・孤立対策推進本部を設置。'
            '地方自治体には、関係機関等で構成する「孤独・孤立対策地域協議会」を置くよう努めることを求めている。',
        effect:
            '国・自治体の役割が法律上明確になり、相談支援体制の整備や関係機関の連携が進む契機となる。'
            '一方で理念法としての性格が強く、実際に見守り・相談支援がどこまで充実するかは、'
            '各自治体の予算配分や地域協議会の実際の運用次第という面が大きい。',
        sourceLabel: '内閣官房',
        sourceUrl: 'https://www.cas.go.jp/jp/seisaku/suisinhou/suisinhou.html',
        asOfDate: '2026年7月時点',
      ),
    ],
    'young_carers': [
      const DietBill(
        id: 'young_carer_support_act_amendment',
        challengeId: 'young_carers',
        billName: '子ども・若者育成支援推進法等の改正',
        status: '成立（2024年6月12日）',
        summary:
            'ヤングケアラーを「過度な家事や家族の世話などを日常的に行っている子供・若者」として'
            '法律上初めて明確に定義し、国・自治体に支援の努力義務を課した。従来は法的な位置づけがなく、'
            '都道府県・市区町村のどちらがどこまで支援すべきか曖昧だった状態を整理する内容。',
        effect:
            '法的位置づけが初めて明確になったことで、自治体ごとにばらついていた支援対象の線引きが整理され、'
            '学校や福祉機関が「支援すべき対象」として動きやすくなることが期待される。'
            '一方、家事代行サービスの提供やレスパイトケアなど、具体的な支援メニューの量的拡充は'
            '各自治体の予算・体制に委ねられており、法改正だけで直ちに支援が手厚くなるわけではない。',
        sourceLabel: 'こども家庭庁',
        sourceUrl: 'https://www.cfa.go.jp/policies/young-carer/',
        asOfDate: '2026年7月時点',
      ),
    ],
    'climate_change_response': [
      const DietBill(
        id: 'gx_promotion_act',
        challengeId: 'climate_change_response',
        billName: 'GX推進法（脱炭素成長型経済構造への円滑な移行の推進に関する法律）',
        status: '施行済み（2023年6月）・改正法が2026年4月1日施行予定',
        summary:
            '2050年カーボンニュートラルの実現に向け、今後10年間で150兆円超の官民GX投資を目指す法律。'
            'GX経済移行債（20兆円規模）の発行、成長志向型カーボンプライシングの導入、GX推進機構の設立などを規定する。'
            '2026年4月からの改正法施行により、CO2の直接排出量が一定規模以上の事業者にカーボンプライシングへの'
            '参加が義務化される。',
        effect:
            '官民GX投資の呼び水となり、脱炭素関連技術・産業への投資が加速することが期待される。'
            '一方、カーボンプライシングの義務化はエネルギーコストの上昇という形で企業のコスト増、'
            'さらには製品価格や電気料金を通じて家計にも転嫁される可能性がある。',
        sourceLabel: '経済産業省',
        sourceUrl:
            'https://www.enecho.meti.go.jp/about/special/johoteikyo/gxseisaku2025.html',
        asOfDate: '2026年7月時点',
      ),
    ],
    'regional_healthcare_gap': [
      const DietBill(
        id: 'medical_care_act_amendment_2025',
        challengeId: 'regional_healthcare_gap',
        billName: '改正医療法（医師偏在是正）',
        status: '成立（2025年12月5日）',
        summary:
            '医師が不足する地域を都道府県が「医師偏在対策優先地域」として指定し、そこで働く医師への手当を'
            '保険料を財源に上乗せする。逆に医師が多い「外来医師過多区域」では、新規開業の際に'
            '地域医療への貢献等について届出・勧告・公表を求める仕組みを導入する。一部を除き2027年4月施行。',
        effect:
            '地方で働く医師に経済的インセンティブを与えることで、地方の医師確保に直接的な効果が期待される。'
            '一方、都市部での新規開業には事実上のハードルが課されることになり、開業を目指す医師のキャリア選択や'
            '地域医療機関の経営判断に影響を与える可能性がある。',
        sourceLabel: '参議院 立法と調査',
        sourceUrl:
            'https://www.sangiin.go.jp/japanese/annai/chousa/rippou_chousa/backnumber/2025pdf/20250425014.pdf',
        asOfDate: '2026年7月時点',
      ),
    ],
  };

  static const _pensionReformBill = DietBill(
    id: 'pension_reform_act_2026',
    challengeId: 'pension_crisis',
    billName: '国民年金法等の一部を改正する法律（年金制度改正法）',
    status: '成立（2026年6月13日）',
    summary:
        '被用者保険の適用拡大、在職老齢年金制度の見直し、遺族年金の見直し、標準報酬月額の上限の'
        '段階的引き上げ、iDeCoの加入可能年齢の引き上げ、将来の基礎年金の給付水準の底上げなどを盛り込んだ改正法。'
        '与党と立憲民主党が基礎年金の底上げ措置について合意し、2026年5月30日に衆院本会議で可決された。',
    effect:
        '被用者保険の適用拡大により、これまで対象外だった短時間労働者やパート従業員も厚生年金に加入できるようになり、'
        '将来受け取る年金額の底上げが期待される一方、対象となる企業には保険料負担の増加が生じる。'
        '基礎年金の給付水準底上げは、若い世代ほど深刻とされる将来の年金水準低下に一定の歯止めをかける措置だが、'
        '効果が実感できるのは実際に年金を受け取る数十年後になる。',
    sourceLabel: '参議院 議案情報',
    sourceUrl:
        'https://www.sangiin.go.jp/japanese/joho1/kousei/gian/217/meisai/m217080217059.htm',
    asOfDate: '2026年7月時点',
  );
}
