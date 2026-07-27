import '../../domain/entities/agency_contact.dart';

/// 運営者（アプリ開発者）が、課題に関連する省庁・窓口に実際に問い合わせた記録
///
/// ここには実際に問い合わせを行った場合のみ記録を追加すること。
/// 「問い合わせたつもり」「まだ送っていない」ものを載せてはいけない
/// （ユーザーに実際の行動として提示されるため、事実と異なる記録は掲載しない）。
class LoadAgencyContacts {
  static List<AgencyContact> forChallenge(String challengeId) {
    return _data[challengeId] ?? const [];
  }

  // 問い合わせ記録が存在する課題IDの一覧（一覧・マップでのバッジ表示判定に使用）
  static List<String> get challengeIds => _data.keys.toList();

  static final Map<String, List<AgencyContact>> _data = {
    // 例:
    // 'defense_budget_funding': [
    //   const AgencyContact(
    //     id: 'defense_budget_funding_mof_2026_08',
    //     challengeId: 'defense_budget_funding',
    //     agencyName: '財務省 主計局 意見受付窓口',
    //     method: '意見フォーム',
    //     status: '送付済み（回答待ち）',
    //     summary: '防衛費増額の財源に関する国民への説明を、一般会計予算の該当ページから'
    //         '直接リンクできるようにしてほしいと要望した。',
    //     contactDate: '2026年8月',
    //   ),
    // ],
  };
}
