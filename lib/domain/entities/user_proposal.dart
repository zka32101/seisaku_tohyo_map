/// 政府への提出状況
enum SubmissionStatus {
  none, // まだ提出していない（投票受付中 or 採用検討中）
  submitted, // 提出済み
  responded, // 提出先から回答があった
  adopted, // 採択された
  declined, // 見送りとなった
}

extension SubmissionStatusLabel on SubmissionStatus {
  String get label {
    switch (this) {
      case SubmissionStatus.none:
        return '未提出';
      case SubmissionStatus.submitted:
        return '提出済み';
      case SubmissionStatus.responded:
        return '回答待ち';
      case SubmissionStatus.adopted:
        return '採択された';
      case SubmissionStatus.declined:
        return '見送りとなった';
    }
  }

  static SubmissionStatus fromString(String? value) {
    return SubmissionStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => SubmissionStatus.none,
    );
  }
}

class UserProposal {
  final String id;
  final String title;
  final String description;
  final String category; // economy/welfare/demographic/politics/debt
  final int voteCount;
  final DateTime createdAt;
  final SubmissionStatus submissionStatus;
  final String? submissionNote; // 提出先・経緯などの自由記述
  final String? submissionUrl; // 提出した先の一次情報（あれば）
  final DateTime? submissionDate;
  final String? userId; // 投稿者の匿名認証UID（削除・通報・ブロック機能に使用）

  const UserProposal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.voteCount,
    required this.createdAt,
    this.submissionStatus = SubmissionStatus.none,
    this.submissionNote,
    this.submissionUrl,
    this.submissionDate,
    this.userId,
  });

  // この投票数を超えると「正式課題候補」として一覧の上部に表示される
  static const promotionThreshold = 20;

  bool get isPromoted => voteCount >= promotionThreshold;
}
