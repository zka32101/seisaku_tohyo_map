import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Weekly summary model
class WeeklySummary {
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int votesThisWeek;
  final int votesLastWeek;
  final String topCategory;
  final int topCategoryCount;
  final List<String> newCategoriesVoted;
  final double consistencyScore;
  final String highestTrendingVoted;
  final int highestTrendingRank;

  WeeklySummary({
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    required this.votesThisWeek,
    required this.votesLastWeek,
    required this.topCategory,
    required this.topCategoryCount,
    required this.newCategoriesVoted,
    required this.consistencyScore,
    required this.highestTrendingVoted,
    required this.highestTrendingRank,
  });

  int get voteChange => votesThisWeek - votesLastWeek;
  bool get isConsistent => consistencyScore > 70;
  bool get isIncreasing => voteChange > 0;
}

/// Monthly summary model
class MonthlySummary {
  final String userId;
  final int year;
  final int month;
  final int totalVotes;
  final int totalVotesLastMonth;
  final Map<String, int> categoryBreakdown;
  final double realizationRate;
  final int realizationCount;
  final List<String> topThreeChallenges;
  final String dominantCategory;
  final String keyInsight;

  MonthlySummary({
    required this.userId,
    required this.year,
    required this.month,
    required this.totalVotes,
    required this.totalVotesLastMonth,
    required this.categoryBreakdown,
    required this.realizationRate,
    required this.realizationCount,
    required this.topThreeChallenges,
    required this.dominantCategory,
    required this.keyInsight,
  });

  int get voteChange => totalVotes - totalVotesLastMonth;
  double get growthRate =>
      totalVotesLastMonth > 0 ? (voteChange / totalVotesLastMonth) * 100 : 0;
  bool get isGrowing => voteChange > 0;
}

/// Provider for weekly summary
final weeklySummaryProvider =
    FutureProvider.family<WeeklySummary, String>((ref, userId) async {
  final firestore = FirebaseFirestore.instance;

  try {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = weekStart.subtract(const Duration(days: 1));

    // Get this week's votes
    final thisWeekSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('votes')
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(weekEnd))
        .get();

    // Get last week's votes
    final lastWeekSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('votes')
        .where('created_at',
            isGreaterThanOrEqualTo: Timestamp.fromDate(lastWeekStart))
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(lastWeekEnd))
        .get();

    // Analyze this week's votes
    final categoryCount = <String, int>{};
    final newCategories = <String>{};
    String? topCategory;
    int topCount = 0;

    for (final doc in thisWeekSnapshot.docs) {
      final category = doc['category'] as String? ?? '';
      categoryCount.update(category, (v) => v + 1, ifAbsent: () => 1);

      if ((categoryCount[category] ?? 0) > topCount) {
        topCategory = category;
        topCount = categoryCount[category] ?? 0;
      }
    }

    // Find new categories voted this week
    final lastWeekCategories = lastWeekSnapshot.docs
        .map((doc) => doc['category'] as String? ?? '')
        .toSet();

    for (final category in categoryCount.keys) {
      if (!lastWeekCategories.contains(category)) {
        newCategories.add(category);
      }
    }

    // Calculate consistency score
    final dailyVotes = <int, int>{};
    for (final doc in thisWeekSnapshot.docs) {
      final date = (doc['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
      final dayOfWeek = date.weekday;
      dailyVotes.update(dayOfWeek, (v) => v + 1, ifAbsent: () => 1);
    }

    final daysWithVotes = dailyVotes.length;
    final consistencyScore = (daysWithVotes / 7) * 100;

    return WeeklySummary(
      userId: userId,
      weekStart: weekStart,
      weekEnd: weekEnd,
      votesThisWeek: thisWeekSnapshot.size,
      votesLastWeek: lastWeekSnapshot.size,
      topCategory: topCategory ?? 'N/A',
      topCategoryCount: topCount,
      newCategoriesVoted: newCategories.toList(),
      consistencyScore: consistencyScore,
      highestTrendingVoted: 'N/A',
      highestTrendingRank: 0,
    );
  } catch (e) {
    return WeeklySummary(
      userId: userId,
      weekStart: DateTime.now(),
      weekEnd: DateTime.now(),
      votesThisWeek: 0,
      votesLastWeek: 0,
      topCategory: 'N/A',
      topCategoryCount: 0,
      newCategoriesVoted: [],
      consistencyScore: 0,
      highestTrendingVoted: 'N/A',
      highestTrendingRank: 0,
    );
  }
});

/// Provider for monthly summary
final monthlySummaryProvider =
    FutureProvider.family<MonthlySummary, String>((ref, userId) async {
  final firestore = FirebaseFirestore.instance;

  try {
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthEnd =
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd =
        DateTime(now.year, now.month, 1).subtract(const Duration(days: 1));

    // Get this month's votes
    final thisMonthSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('votes')
        .where('created_at',
            isGreaterThanOrEqualTo: Timestamp.fromDate(thisMonthStart))
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(thisMonthEnd))
        .get();

    // Get last month's votes
    final lastMonthSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('votes')
        .where('created_at',
            isGreaterThanOrEqualTo: Timestamp.fromDate(lastMonthStart))
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(lastMonthEnd))
        .get();

    // Analyze category breakdown
    final categoryBreakdown = <String, int>{};
    int realizationCount = 0;

    for (final doc in thisMonthSnapshot.docs) {
      final category = doc['category'] as String? ?? '';
      final realized = doc['realized'] as bool? ?? false;

      categoryBreakdown.update(category, (v) => v + 1, ifAbsent: () => 1);

      if (realized) realizationCount++;
    }

    final realizationRate = thisMonthSnapshot.size > 0
        ? (realizationCount / thisMonthSnapshot.size) * 100
        : 0.0;

    // Find dominant category
    String dominantCategory = 'N/A';
    int maxCount = 0;
    for (final entry in categoryBreakdown.entries) {
      if (entry.value > maxCount) {
        dominantCategory = entry.key;
        maxCount = entry.value;
      }
    }

    // Generate key insight
    final voteChange = thisMonthSnapshot.size - lastMonthSnapshot.size;
    String keyInsight = '';
    if (voteChange > 10) {
      keyInsight = '投票数が大幅に増加！';
    } else if (voteChange > 0) {
      keyInsight = '投票数が前月比で増加しています';
    } else if (voteChange < -10) {
      keyInsight = '投票数が減少していますが、質の向上を目指しましょう';
    } else if (voteChange < 0) {
      keyInsight = '前月より投票数が減少しています';
    } else {
      keyInsight = '投票活動が安定しています';
    }

    return MonthlySummary(
      userId: userId,
      year: now.year,
      month: now.month,
      totalVotes: thisMonthSnapshot.size,
      totalVotesLastMonth: lastMonthSnapshot.size,
      categoryBreakdown: categoryBreakdown,
      realizationRate: realizationRate,
      realizationCount: realizationCount,
      topThreeChallenges: [], // Would require additional query
      dominantCategory: dominantCategory,
      keyInsight: keyInsight,
    );
  } catch (e) {
    return MonthlySummary(
      userId: userId,
      year: DateTime.now().year,
      month: DateTime.now().month,
      totalVotes: 0,
      totalVotesLastMonth: 0,
      categoryBreakdown: {},
      realizationRate: 0,
      realizationCount: 0,
      topThreeChallenges: [],
      dominantCategory: 'N/A',
      keyInsight: 'データを読み込み中...',
    );
  }
});
