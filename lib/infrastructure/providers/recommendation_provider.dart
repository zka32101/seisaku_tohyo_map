import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Recommended challenge model
class RecommendedChallenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final int voteCount;
  final double relevanceScore;
  final String reason;

  RecommendedChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.voteCount,
    required this.relevanceScore,
    required this.reason,
  });

  factory RecommendedChallenge.fromFirestore(
    DocumentSnapshot doc, {
    required double relevanceScore,
    required String reason,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    return RecommendedChallenge(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      voteCount: data['vote_count'] ?? 0,
      relevanceScore: relevanceScore,
      reason: reason,
    );
  }
}

/// Recommendation provider based on user interests
final recommendationProvider = FutureProvider.family<
    List<RecommendedChallenge>,
    ({
      String userId,
      List<String> userInterests,
      int limit,
    })>((ref, params) async {
  final firestore = FirebaseFirestore.instance;

  try {
    if (params.userInterests.isEmpty) {
      return [];
    }

    // Get all challenges in user's interest categories
    final challengesSnapshot = await firestore
        .collection('challenges')
        .where('category', whereIn: params.userInterests)
        .get();

    // Get user's previous votes to exclude
    final userVotesSnapshot = await firestore
        .collection('users')
        .doc(params.userId)
        .collection('votes')
        .get();

    final votedChallengeIds =
        userVotesSnapshot.docs.map((doc) => doc.id).toSet();

    final recommendations = <RecommendedChallenge>[];

    for (final doc in challengesSnapshot.docs) {
      if (votedChallengeIds.contains(doc.id)) {
        continue; // Skip already voted challenges
      }

      final data = doc.data();
      final category = data['category'] as String? ?? '';

      // Calculate relevance score based on:
      // 1. Category match (primary interest)
      // 2. Vote count (popularity)
      // 3. Recency (created_at)
      final categoryWeight = _getCategoryRelevance(category, params.userInterests);
      final createdAt =
          (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
      final daysSinceCreated = DateTime.now().difference(createdAt).inDays;
      const recencyDecay = 0.95;
      final recencyWeight = daysSinceCreated > 0
          ? recencyDecay ^ (daysSinceCreated / 30) // Decay over months
          : 1.0;

      final voteCount = data['vote_count'] as int? ?? 0;
      final popularityWeight = 1 + (voteCount / 100).clamp(0.0, 3.0);

      final relevanceScore = (categoryWeight * 0.5) +
          (recencyWeight * 0.25) +
          (popularityWeight * 0.25);

      final reason = _generateReason(category, voteCount);

      recommendations.add(
        RecommendedChallenge.fromFirestore(
          doc,
          relevanceScore: relevanceScore,
          reason: reason,
        ),
      );
    }

    // Sort by relevance score and limit results
    recommendations.sort(
      (a, b) => b.relevanceScore.compareTo(a.relevanceScore),
    );

    return recommendations.take(params.limit).toList();
  } catch (e) {
    return [];
  }
});

/// Calculate category relevance to user interests
double _getCategoryRelevance(String category, List<String> userInterests) {
  if (userInterests.contains(category)) {
    return 1.0; // Exact match
  }

  // Related category matches
  final relatedCategories = {
    '経済・財政': ['福祉・医療', '政治構造'],
    '福祉・医療': ['経済・財政', '人口・地域'],
    '人口・地域': ['福祉・医療', '環境・エネルギー'],
    '環境・エネルギー': ['人口・地域', '教育・科学'],
    '政治構造': ['経済・財政', '防衛・外交'],
    '教育・科学': ['環境・エネルギー'],
    '防衛・外交': ['政治構造'],
  };

  final related = relatedCategories[category] ?? [];
  for (final interest in userInterests) {
    if (related.contains(interest)) {
      return 0.6; // Related category
    }
  }

  return 0.2; // Unrelated category
}

/// Generate reason for recommendation
String _generateReason(String category, int voteCount) {
  if (voteCount > 100) {
    return '注目度が高い議案';
  }
  return '関心分野の議案';
}
