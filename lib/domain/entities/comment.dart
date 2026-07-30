class Comment {
  final String id;
  final String challengeId;
  final String text;
  final DateTime createdAt;
  final int likeCount;
  final String? userId; // 投稿者の匿名認証UID（削除・通報・ブロック機能に使用）

  Comment({
    required this.id,
    required this.challengeId,
    required this.text,
    required this.createdAt,
    this.likeCount = 0,
    this.userId,
  });
}
