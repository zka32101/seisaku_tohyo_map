import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model for user analytics
class UserAnalytics {
  final String userId;
  final int totalVotes;
  final Map<String, int> categoryCounts;
  final List<InterestTrend> interestTrends;
  final int realizedCount;
  final double realizationRate;
  final Map<String, int> monthlyVoteCounts;

  UserAnalytics({
    required this.userId,
    required this.totalVotes,
    required this.categoryCounts,
    required this.interestTrends,
    required this.realizedCount,
    required this.realizationRate,
    required this.monthlyVoteCounts,
  });
}

/// Model for interest trends over time
class InterestTrend {
  final String category;
  final int lastMonthCount;
  final int thisMonthCount;

  InterestTrend({
    required this.category,
    required this.lastMonthCount,
    required this.thisMonthCount,
  });

  get trend => thisMonthCount - lastMonthCount;
}

/// Riverpod provider for user analytics
final analyticsProvider =
    FutureProvider.family<UserAnalytics, String>((ref, userId) async {
  final firestore = FirebaseFirestore.instance;

  try {
    // Get all votes for this user
    final votesSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('votes')
        .get();

    int totalVotes = 0;
    final categoryCounts = <String, int>{};
    final monthlyVoteCounts = <String, int>{};
    int realizedCount = 0;

    final now = DateTime.now();
    final twoMonthsAgo = DateTime(now.year, now.month - 2, 1);
    final oneMonthAgo = DateTime(now.year, now.month - 1, 1);
    final thisMonth = DateTime(now.year, now.month, 1);

    for (final doc in votesSnapshot.docs) {
      final data = doc.data();
      final category = data['category'] as String? ?? '';
      final createdAt =
          (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
      final isRealized = data['realized'] as bool? ?? false;

      totalVotes++;

      // Count by category
      categoryCounts.update(category, (v) => v + 1, ifAbsent: () => 1);

      // Count realized
      if (isRealized) realizedCount++;

      // Count monthly
      if (createdAt.isAfter(thisMonth)) {
        final monthKey = 'this_month';
        monthlyVoteCounts.update(monthKey, (v) => v + 1, ifAbsent: () => 1);
      } else if (createdAt.isAfter(oneMonthAgo)) {
        final monthKey = 'one_month_ago';
        monthlyVoteCounts.update(monthKey, (v) => v + 1, ifAbsent: () => 1);
      } else if (createdAt.isAfter(twoMonthsAgo)) {
        final monthKey = 'two_months_ago';
        monthlyVoteCounts.update(monthKey, (v) => v + 1, ifAbsent: () => 1);
      }
    }

    // Calculate interest trends
    final interestTrends = <InterestTrend>[];
    for (final category in categoryCounts.keys) {
      // This is simplified; in production, fetch from subcollections
      final lastMonthCount = (categoryCounts[category] ?? 0) ~/ 2;
      final thisMonthCount = (categoryCounts[category] ?? 0) - lastMonthCount;

      interestTrends.add(
        InterestTrend(
          category: category,
          lastMonthCount: lastMonthCount,
          thisMonthCount: thisMonthCount,
        ),
      );
    }

    final realizationRate = totalVotes > 0 ? (realizedCount / totalVotes) : 0.0;

    return UserAnalytics(
      userId: userId,
      totalVotes: totalVotes,
      categoryCounts: categoryCounts,
      interestTrends: interestTrends,
      realizedCount: realizedCount,
      realizationRate: realizationRate,
      monthlyVoteCounts: monthlyVoteCounts,
    );
  } catch (e) {
    return UserAnalytics(
      userId: userId,
      totalVotes: 0,
      categoryCounts: {},
      interestTrends: [],
      realizedCount: 0,
      realizationRate: 0.0,
      monthlyVoteCounts: {},
    );
  }
});
