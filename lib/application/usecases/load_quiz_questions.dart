import '../../domain/entities/quiz.dart';

class LoadQuizQuestions {
  static List<QuizQuestion> call() {
    return [
      QuizQuestion(
        id: 'politician_salary',
        question: '国会議員の年収は、歳費だけでいくら？',
        unit: '万円',
        correctAnswer: 2180,
        explanation:
            '国会議員の歳費（給与）は年間約2,180万円。これに文書通信費・政党交付金等を加えると、実質的な受取額はさらに大きくなるとの試算もあります。',
        category: 'politics',
      ),
      QuizQuestion(
        id: 'social_security_ratio',
        question: '国の予算のうち、社会保障費は何%？',
        unit: '%',
        correctAnswer: 35.1,
        explanation:
            '2026年度の一般会計予算のうち、社会保障費が占める割合は約35.1%。予算の3分の1以上が社会保障に使われています。',
        category: 'economy',
      ),
      QuizQuestion(
        id: 'population_2070',
        question: '2070年の日本の人口は何百万人になる？',
        unit: '百万人',
        correctAnswer: 104,
        explanation:
            '国立社会保障・人口問題研究所の中位推計によると、2070年の人口は約104百万人（2023年比で約17%減少）と予測されています。',
        category: 'demographic',
      ),
      QuizQuestion(
        id: 'national_debt_ratio',
        question: '日本の国債残高は、GDP比で何%？',
        unit: '%',
        correctAnswer: 264,
        explanation:
            '日本の国債残高は対GDP比で約264%。これは先進国の中で最悪の水準であり、財政健全化が大きな課題となっています。',
        category: 'debt',
      ),
      QuizQuestion(
        id: 'non_regular_employment',
        question: '働く人のうち、非正規雇用の割合は何%？',
        unit: '%',
        correctAnswer: 39.8,
        explanation:
            '日本の労働者全体のうち、非正規雇用（パート・契約・派遣等）が占める割合は約39.8%。働く人の4割近くが非正規雇用です。',
        category: 'economy',
      ),
      QuizQuestion(
        id: 'child_poverty_rate',
        question: '子供の相対的貧困率は何%？',
        unit: '%',
        correctAnswer: 11.5,
        explanation: '子供の相対的貧困率は約11.5%で、およそ9人に1人が該当します。ひとり親世帯に限ると4倍以上の水準になります。',
        category: 'welfare',
      ),
      QuizQuestion(
        id: 'women_in_diet',
        question: '衆議院議員に占める女性の割合は何%？',
        unit: '%',
        correctAnswer: 10.3,
        explanation:
            '衆議院に占める女性議員の割合は約10.3%。主要国の中でも低い水準にあり、政治の意思決定層の多様性が課題となっています。',
        category: 'politics',
      ),
      QuizQuestion(
        id: 'aging_rate',
        question: '日本の高齢化率（65歳以上人口の割合）は何%？',
        unit: '%',
        correctAnswer: 29.1,
        explanation: '日本の高齢化率は約29.1%で世界最高水準。約3.4人に1人が65歳以上という計算になります。',
        category: 'demographic',
      ),
      QuizQuestion(
        id: 'university_enrollment',
        question: '大学進学率は何%？',
        unit: '%',
        correctAnswer: 57.2,
        explanation:
            '大学進学率は全体平均で約57.2%。ただし世帯年収400万円未満の層に限ると約37.5%まで下がり、所得による格差があります。',
        category: 'economy',
      ),
      QuizQuestion(
        id: 'medical_cost_gdp',
        question: '国民医療費は何兆円？',
        unit: '兆円',
        correctAnswer: 47.0,
        explanation: '国民医療費は年間約47兆円。高齢化の進行に伴い増加を続けており、現役世代の保険料負担増加の要因となっています。',
        category: 'welfare',
      ),
      QuizQuestion(
        id: 'energy_self_sufficiency_rate',
        question: '日本のエネルギー自給率は何%？',
        unit: '%',
        correctAnswer: 13.3,
        explanation:
            '日本のエネルギー自給率は約13.3%。化石燃料の大半を輸入に依存しており、資源価格の変動に経済が左右されやすい構造です。',
        category: 'economy',
      ),
      QuizQuestion(
        id: 'voter_turnout',
        question: '直近の衆議院議員選挙の投票率は何%？',
        unit: '%',
        correctAnswer: 55.9,
        explanation:
            '直近の衆議院議員選挙の投票率は約55.9%。特に20代の投票率は30%台にとどまり、世代間の格差が大きい状況です。',
        category: 'politics',
      ),
      QuizQuestion(
        id: 'vacant_house_rate',
        question: '日本の空き家率は何%？',
        unit: '%',
        correctAnswer: 13.8,
        explanation: '日本の空き家率は約13.8%で、住宅の7〜8戸に1戸が空き家という計算になります。人口減少地域では特に深刻です。',
        category: 'demographic',
      ),
      QuizQuestion(
        id: 'elderly_medical_cost',
        question: '後期高齢者医療費の給付費総額は何兆円？',
        unit: '兆円',
        correctAnswer: 18.4,
        explanation: '後期高齢者医療費の給付費総額は約18.4兆円。この財源の一部は現役世代の保険料からの支援金で賄われています。',
        category: 'welfare',
      ),
      QuizQuestion(
        id: 'fdi_gdp_ratio',
        question: '対内直接投資残高は、GDP比で何%？',
        unit: '%',
        correctAnswer: 5.2,
        explanation:
            '日本の対内直接投資残高は対GDP比で約5.2%。OECD主要国の平均（約50%）と比べて極めて低い水準にとどまっています。',
        category: 'economy',
      ),
    ];
  }

  // 「社会課題マスター」判定者向けの上級問題（より細かい数値・馴染みの薄い指標）
  static List<QuizQuestion> advanced() {
    return [
      QuizQuestion(
        id: 'general_budget_total',
        question: '国の一般会計予算の総額は何兆円？',
        unit: '兆円',
        correctAnswer: 114.4,
        explanation: '2026年度の一般会計予算総額は約114.4兆円。社会保障・国債費・地方交付税で全体の7割近くを占めています。',
        category: 'debt',
        difficulty: 'advanced',
      ),
      QuizQuestion(
        id: 'welfare_recipients',
        question: '生活保護を受給している人は何万人？',
        unit: '万人',
        correctAnswer: 200.0,
        explanation: '生活保護受給者数は約200万人（全人口の約1.6%）。高齢者世帯の受給割合が年々増加しています。',
        category: 'welfare',
        difficulty: 'advanced',
      ),
      QuizQuestion(
        id: 'male_life_expectancy',
        question: '日本人男性の平均寿命は何歳？',
        unit: '歳',
        correctAnswer: 81.5,
        explanation:
            '日本人男性の平均寿命は約81.5歳（女性は約87.6歳）で、世界トップクラスの水準です。長寿化は年金・医療費の増加要因の一つでもあります。',
        category: 'welfare',
        difficulty: 'advanced',
      ),
      QuizQuestion(
        id: 'consumption_tax_revenue',
        question: '消費税収は年間何兆円？',
        unit: '兆円',
        correctAnswer: 23.4,
        explanation: '消費税収は年間約23.4兆円で、所得税・法人税と並ぶ国の基幹税収の一つ。社会保障費の重要な財源とされています。',
        category: 'economy',
        difficulty: 'advanced',
      ),
      QuizQuestion(
        id: 'municipalities_count',
        question: '日本の市区町村の数はいくつ？',
        unit: '',
        correctAnswer: 1718.0,
        explanation:
            '日本の市区町村数は1,718（2026年時点）。平成の大合併で1999年の約3,200から大幅に減少しました。人口減少で今後さらなる再編の議論もあります。',
        category: 'demographic',
        difficulty: 'advanced',
      ),
    ];
  }
}
