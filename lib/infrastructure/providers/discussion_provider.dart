import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Discussion comment model
class DiscussionComment {
  final String id;
  final String userId;
  final String userDisplayName;
  final String content;
  final int likes;
  final DateTime createdAt;
  final List<String>? replies;

  DiscussionComment({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    required this.content,
    required this.likes,
    required this.createdAt,
    this.replies,
  });

  factory DiscussionComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiscussionComment(
      id: doc.id,
      userId: data['user_id'] ?? '',
      userDisplayName: data['user_display_name'] ?? '匿名ユーザー',
      content: data['content'] ?? '',
      likes: data['likes'] ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      replies: (data['replies'] as List?)?.cast<String>(),
    );
  }
}

/// Challenge discussion thread model
class ChallengeDiscussion {
  final String challengeId;
  final List<DiscussionComment> comments;
  final int totalComments;
  final DateTime lastCommentAt;

  ChallengeDiscussion({
    required this.challengeId,
    required this.comments,
    required this.totalComments,
    required this.lastCommentAt,
  });
}

/// Provider for challenge discussion
final discussionProvider =
    FutureProvider.family<ChallengeDiscussion, String>((ref, challengeId) async {
  final firestore = FirebaseFirestore.instance;

  try {
    final commentsSnapshot = await firestore
        .collection('challenges')
        .doc(challengeId)
        .collection('discussions')
        .orderBy('created_at', descending: true)
        .limit(50)
        .get();

    final comments = commentsSnapshot.docs
        .map((doc) => DiscussionComment.fromFirestore(doc))
        .toList();

    final lastCommentAt = comments.isNotEmpty
        ? comments.first.createdAt
        : DateTime.now();

    return ChallengeDiscussion(
      challengeId: challengeId,
      comments: comments,
      totalComments: commentsSnapshot.size,
      lastCommentAt: lastCommentAt,
    );
  } catch (e) {
    return ChallengeDiscussion(
      challengeId: challengeId,
      comments: [],
      totalComments: 0,
      lastCommentAt: DateTime.now(),
    );
  }
});

/// Add a comment to a challenge discussion
Future<void> addDiscussionComment({
  required String challengeId,
  required String userId,
  required String displayName,
  required String content,
}) async {
  final firestore = FirebaseFirestore.instance;

  try {
    await firestore
        .collection('challenges')
        .doc(challengeId)
        .collection('discussions')
        .add({
      'user_id': userId,
      'user_display_name': displayName,
      'content': content,
      'likes': 0,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    rethrow;
  }
}

/// Like a discussion comment
Future<void> likeDiscussionComment({
  required String challengeId,
  required String commentId,
}) async {
  final firestore = FirebaseFirestore.instance;

  try {
    await firestore
        .collection('challenges')
        .doc(challengeId)
        .collection('discussions')
        .doc(commentId)
        .update({
      'likes': FieldValue.increment(1),
    });
  } catch (e) {
    rethrow;
  }
}
