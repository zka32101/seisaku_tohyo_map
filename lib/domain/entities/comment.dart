class Comment {
  final String id;
  final String challengeId;
  final String text;
  final DateTime createdAt;
  final int likeCount;

  Comment({
    required this.id,
    required this.challengeId,
    required this.text,
    required this.createdAt,
    this.likeCount = 0,
  });
}
