import '../../domain/entities/urgency_importance.dart';

/// 全51課題の緊急度・重要度データ（編集部による定性評価、各1〜5）
///
/// 緊急重要マトリクス画面でのみ使用。新しい課題を追加した場合は
/// ここにもエントリーを追加すること（未登録の課題はマトリクスに表示されない）。
class LoadUrgencyImportance {
  static UrgencyImportance? forChallenge(String challengeId) {
    return _data[challengeId];
  }

  static List<UrgencyImportance> all() => _data.values.toList();

  static final Map<String, UrgencyImportance> _data = {
    for (final item in _list) item.challengeId: item,
  };

  static const List<UrgencyImportance> _list = [
    UrgencyImportance(
      challengeId: 'my_pension_balance',
      urgency: 3,
      importance: 4,
    ),
    UrgencyImportance(
      challengeId: 'silver_democracy',
      urgency: 3,
      importance: 4,
    ),
    UrgencyImportance(
      challengeId: 'low_labor_productivity',
      urgency: 3,
      importance: 5,
    ),
    UrgencyImportance(
      challengeId: 'unmarried_structure',
      urgency: 3,
      importance: 5,
    ),
    UrgencyImportance(challengeId: 'reform_deferral', urgency: 3, importance: 4),
    UrgencyImportance(
      challengeId: 'bureaucracy_influence',
      urgency: 2,
      importance: 4,
    ),
    UrgencyImportance(
      challengeId: 'money_in_politics',
      urgency: 3,
      importance: 4,
    ),
    UrgencyImportance(
      challengeId: 'press_independence',
      urgency: 3,
      importance: 4,
    ),
    UrgencyImportance(
      challengeId: 'electoral_wasted_votes',
      urgency: 2,
      importance: 3,
    ),
    UrgencyImportance(
      challengeId: 'amakudari_structure',
      urgency: 2,
      importance: 3,
    ),
    UrgencyImportance(
      challengeId: 'local_fiscal_dependency',
      urgency: 3,
      importance: 4,
    ),
    UrgencyImportance(
      challengeId: 'policy_evaluation_weakness',
      urgency: 2,
      importance: 3,
    ),
    UrgencyImportance(
      challengeId: 'vote_value_disparity',
      urgency: 2,
      importance: 3,
    ),
    UrgencyImportance(
      challengeId: 'hereditary_politicians',
      urgency: 2,
      importance: 3,
    ),
    UrgencyImportance(challengeId: 'ministry_silos', urgency: 3, importance: 4),
    UrgencyImportance(
      challengeId: 'kantei_led_politics',
      urgency: 2,
      importance: 3,
    ),
    UrgencyImportance(
      challengeId: 'income_stagnation',
      urgency: 4,
      importance: 5,
    ),
    UrgencyImportance(challengeId: 'pension_crisis', urgency: 5, importance: 5),
    UrgencyImportance(
      challengeId: 'population_decline',
      urgency: 5,
      importance: 5,
    ),
    UrgencyImportance(
      challengeId: 'politician_salary',
      urgency: 1,
      importance: 2,
    ),
    UrgencyImportance(challengeId: 'national_debt', urgency: 4, importance: 5),
    UrgencyImportance(challengeId: 'child_poverty', urgency: 4, importance: 5),
    UrgencyImportance(
      challengeId: 'regional_extinction',
      urgency: 5,
      importance: 5,
    ),
    UrgencyImportance(challengeId: 'healthcare_cost', urgency: 4, importance: 5),
    UrgencyImportance(challengeId: 'education_gap', urgency: 3, importance: 5),
    UrgencyImportance(
      challengeId: 'women_in_politics',
      urgency: 2,
      importance: 3,
    ),
    UrgencyImportance(
      challengeId: 'energy_dependency',
      urgency: 4,
      importance: 5,
    ),
    UrgencyImportance(
      challengeId: 'elderly_medical_burden',
      urgency: 4,
      importance: 5,
    ),
    UrgencyImportance(
      challengeId: 'foreign_direct_investment',
      urgency: 2,
      importance: 3,
    ),
    UrgencyImportance(
      challengeId: 'voter_turnout_decline',
      urgency: 3,
      importance: 4,
    ),
    UrgencyImportance(challengeId: 'housing_vacancy', urgency: 3, importance: 3),
    UrgencyImportance(
      challengeId: 'childcare_waitlist',
      urgency: 3,
      importance: 4,
    ),
    UrgencyImportance(
      challengeId: 'sme_succession_crisis',
      urgency: 4,
      importance: 4,
    ),
    UrgencyImportance(challengeId: 'gender_pay_gap', urgency: 3, importance: 4),
    UrgencyImportance(
      challengeId: 'disaster_recovery_cost',
      urgency: 4,
      importance: 4,
    ),
    UrgencyImportance(
      challengeId: 'regional_healthcare_gap',
      urgency: 4,
      importance: 4,
    ),
    UrgencyImportance(
      challengeId: 'climate_change_response',
      urgency: 4,
      importance: 5,
    ),
    UrgencyImportance(challengeId: 'young_carers', urgency: 4, importance: 4),
    UrgencyImportance(challengeId: 'digital_divide', urgency: 3, importance: 3),
    UrgencyImportance(challengeId: 'isolated_elderly', urgency: 5, importance: 4),
    UrgencyImportance(
      challengeId: 'non_regular_employment',
      urgency: 3,
      importance: 4,
    ),
    UrgencyImportance(challengeId: 'low_startup_rate', urgency: 2, importance: 4),
    UrgencyImportance(
      challengeId: 'caregiver_shortage',
      urgency: 5,
      importance: 5,
    ),
    UrgencyImportance(
      challengeId: 'single_parent_poverty',
      urgency: 4,
      importance: 4,
    ),
    UrgencyImportance(
      challengeId: 'tokyo_concentration',
      urgency: 3,
      importance: 4,
    ),
    UrgencyImportance(
      challengeId: 'foreign_worker_coexistence',
      urgency: 3,
      importance: 4,
    ),
    UrgencyImportance(
      challengeId: 'local_assembly_shortage',
      urgency: 3,
      importance: 3,
    ),
    UrgencyImportance(
      challengeId: 'candidacy_deposit_barrier',
      urgency: 1,
      importance: 2,
    ),
    UrgencyImportance(
      challengeId: 'defense_budget_funding',
      urgency: 4,
      importance: 4,
    ),
    UrgencyImportance(
      challengeId: 'special_account_opacity',
      urgency: 2,
      importance: 3,
    ),
    UrgencyImportance(
      challengeId: 'finance_ministry_narrative_control',
      urgency: 2,
      importance: 3,
    ),
  ];
}
