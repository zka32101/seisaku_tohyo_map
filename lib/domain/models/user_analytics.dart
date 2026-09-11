/// User analytics data model
class UserAnalyticsModel {
  final String userId;
  final int totalVotes;
  final Map<String, int> categoryCounts;
  final List<InterestTrendModel> interestTrends;
  final int realizedCount;
  final double realizationRate;
  final Map<String, int> monthlyVoteCounts;

  UserAnalyticsModel({
    required this.userId,
    required this.totalVotes,
    required this.categoryCounts,
    required this.interestTrends,
    required this.realizedCount,
    required this.realizationRate,
    required this.monthlyVoteCounts,
  });
}

/// Interest trend data model for month-over-month comparison
class InterestTrendModel {
  final String category;
  final int lastMonthCount;
  final int thisMonthCount;

  InterestTrendModel({
    required this.category,
    required this.lastMonthCount,
    required this.thisMonthCount,
  });

  /// Calculate the trend (positive = increasing, negative = decreasing)
  int get trend => thisMonthCount - lastMonthCount;
}
