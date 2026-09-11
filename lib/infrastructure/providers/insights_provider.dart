import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User voting insight
class VotingInsight {
  final String title;
  final String description;
  final String icon;
  final double value;
  final String unit;
  final String comparison; // 'higher', 'lower', 'average'

  VotingInsight({
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.unit,
    required this.comparison,
  });
}

/// Political affinity analysis
class PoliticalAffinity {
  final String category;
  final double conservativeScore; // 0-100
  final double progressiveScore; // 0-100
  final String dominantLeaning; // 'conservative', 'progressive', 'centrist'

  PoliticalAffinity({
    required this.category,
    required this.conservativeScore,
    required this.progressiveScore,
    required this.dominantLeaning,
  });
}

/// Voting insights and political affinity analysis
class UserInsights {
  final String userId;
  final List<VotingInsight> insights;
  final PoliticalAffinity? politicalAffinity;
  final String preferredCategory;
  final double votingConsistency; // 0-100
  final int daysUntilNextVote; // Prediction based on voting pattern

  UserInsights({
    required this.userId,
    required this.insights,
    this.politicalAffinity,
    required this.preferredCategory,
    required this.votingConsistency,
    required this.daysUntilNextVote,
  });
}

/// Provider for user insights and analytics
final insightsProvider =
    FutureProvider.family<UserInsights, String>((ref, userId) async {
  final firestore = FirebaseFirestore.instance;

  try {
    // Get user votes
    final votesSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('votes')
        .orderBy('created_at', descending: true)
        .get();

    if (votesSnapshot.docs.isEmpty) {
      return UserInsights(
        userId: userId,
        insights: [],
        preferredCategory: 'N/A',
        votingConsistency: 0,
        daysUntilNextVote: 0,
      );
    }

    // Calculate insights
    final insights = <VotingInsight>[];
    final categoryVotes = <String, int>{};
    final voteTimestamps = <DateTime>[];

    for (final doc in votesSnapshot.docs) {
      final data = doc.data();
      final category = data['category'] as String? ?? '';
      final createdAt =
          (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();

      categoryVotes.update(category, (v) => v + 1, ifAbsent: () => 1);
      voteTimestamps.add(createdAt);
    }

    // 1. Most active category
    final preferredCategory = categoryVotes.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    insights.add(VotingInsight(
      title: 'よく投票する分野',
      description: '$preferredCategory に最も多く投票しています',
      icon: '📊',
      value: categoryVotes[preferredCategory]?.toDouble() ?? 0,
      unit: '件',
      comparison: 'higher',
    ));

    // 2. Voting consistency (days between votes)
    double avgDaysBetweenVotes = 0;
    if (voteTimestamps.length > 1) {
      int totalDays = 0;
      for (int i = 0; i < voteTimestamps.length - 1; i++) {
        totalDays +=
            voteTimestamps[i].difference(voteTimestamps[i + 1]).inDays;
      }
      avgDaysBetweenVotes = totalDays / (voteTimestamps.length - 1);
    }

    final votingConsistency = (100 / (avgDaysBetweenVotes + 1)).clamp(0, 100);

    insights.add(VotingInsight(
      title: '投票の一貫性',
      description: '投票パターンが${votingConsistency > 70 ? '非常に' : ''}安定しています',
      icon: '⏰',
      value: votingConsistency,
      unit: '%',
      comparison: votingConsistency > 70 ? 'higher' : 'average',
    ));

    // 3. Category diversity
    final categoryDiversity = (categoryVotes.length / 8) * 100;
    insights.add(VotingInsight(
      title: '分野の多様性',
      description: '${categoryVotes.length}個の分野に投票しています',
      icon: '🎯',
      value: categoryDiversity,
      unit: '%',
      comparison: categoryDiversity > 50 ? 'higher' : 'lower',
    ));

    // 4. Prediction for next vote
    final lastVoteDate = voteTimestamps.isNotEmpty ? voteTimestamps[0] : DateTime.now();
    final daysSinceLastVote = DateTime.now().difference(lastVoteDate).inDays;
    final predictedDaysUntilNextVote =
        (avgDaysBetweenVotes - daysSinceLastVote).toInt().clamp(0, 365);

    insights.add(VotingInsight(
      title: '次の投票予測',
      description: 'パターンから約${predictedDaysUntilNextVote}日後に投票する可能性があります',
      icon: '🔮',
      value: predictedDaysUntilNextVote.toDouble(),
      unit: '日',
      comparison: 'average',
    ));

    // Calculate political affinity (simplified)
    // In a real implementation, this would analyze the specific positions in each vote
    final conservativeEstimate = (votesSnapshot.size % 60).toDouble();
    final progressiveEstimate = (votesSnapshot.size % 40).toDouble();

    final affinity = PoliticalAffinity(
      category: preferredCategory,
      conservativeScore: conservativeEstimate,
      progressiveScore: progressiveEstimate,
      dominantLeaning: conservativeEstimate > progressiveEstimate
          ? 'conservative'
          : 'progressive',
    );

    return UserInsights(
      userId: userId,
      insights: insights,
      politicalAffinity: affinity,
      preferredCategory: preferredCategory,
      votingConsistency: votingConsistency,
      daysUntilNextVote: predictedDaysUntilNextVote,
    );
  } catch (e) {
    return UserInsights(
      userId: userId,
      insights: [],
      preferredCategory: 'N/A',
      votingConsistency: 0,
      daysUntilNextVote: 0,
    );
  }
});
