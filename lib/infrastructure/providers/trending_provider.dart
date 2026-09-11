import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model for trending items
class TrendingItem {
  final String id;
  final String title;
  final String category;
  final int thisWeekVotes;
  final int lastWeekVotes;

  TrendingItem({
    required this.id,
    required this.title,
    required this.category,
    required this.thisWeekVotes,
    required this.lastWeekVotes,
  });

  /// Calculate the change in votes between weeks
  int get voteChange => thisWeekVotes - lastWeekVotes;
}

/// Riverpod provider for trending challenges
final trendingProvider = FutureProvider<List<TrendingItem>>((ref) async {
  final firestore = FirebaseFirestore.instance;

  try {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

    // Get all challenges
    final challengesSnapshot =
        await firestore.collection('challenges').get();

    final trendingItems = <TrendingItem>[];

    // For each challenge, calculate votes from this week and last week
    for (final challengeDoc in challengesSnapshot.docs) {
      final challengeId = challengeDoc.id;
      final data = challengeDoc.data();
      final title = data['title'] as String? ?? '';
      final category = data['category'] as String? ?? '';

      // Count votes from this week
      final thisWeekSnapshot = await firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('votes')
          .where('created_at',
              isGreaterThanOrEqualTo: Timestamp.fromDate(thisWeekStart))
          .count()
          .get();
      final thisWeekVotes = thisWeekSnapshot.count;

      // Count votes from last week
      final lastWeekSnapshot = await firestore
          .collection('challenges')
          .doc(challengeId)
          .collection('votes')
          .where('created_at',
              isGreaterThanOrEqualTo: Timestamp.fromDate(lastWeekStart))
          .where('created_at',
              isLessThanOrEqualTo: Timestamp.fromDate(lastWeekEnd))
          .count()
          .get();
      final lastWeekVotes = lastWeekSnapshot.count;

      trendingItems.add(
        TrendingItem(
          id: challengeId,
          title: title,
          category: category,
          thisWeekVotes: thisWeekVotes,
          lastWeekVotes: lastWeekVotes,
        ),
      );
    }

    // Sort by this week's votes and take top 10
    trendingItems.sort((a, b) => b.thisWeekVotes.compareTo(a.thisWeekVotes));

    return trendingItems.take(10).toList();
  } catch (e) {
    return [];
  }
});
