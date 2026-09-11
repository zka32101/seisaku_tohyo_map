import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Achievement model
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int requiredCount;
  final String type; // 'votes', 'categories', 'trends', 'voting_streak'
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredCount,
    required this.type,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  int get progressPercentage {
    // This will be calculated based on user data
    return 0;
  }
}

/// List of available achievements
const List<Achievement> allAchievements = [
  Achievement(
    id: 'first_vote',
    name: '投票を始めた',
    description: '初めての投票をしました',
    icon: '🗳️',
    requiredCount: 1,
    type: 'votes',
  ),
  Achievement(
    id: 'vote_10',
    name: '10投票達成',
    description: '10個の議案に投票しました',
    icon: '📊',
    requiredCount: 10,
    type: 'votes',
  ),
  Achievement(
    id: 'vote_50',
    name: '50投票達成',
    description: '50個の議案に投票しました',
    icon: '⭐',
    requiredCount: 50,
    type: 'votes',
  ),
  Achievement(
    id: 'vote_100',
    name: '100投票達成',
    description: '100個の議案に投票しました',
    icon: '👑',
    requiredCount: 100,
    type: 'votes',
  ),
  Achievement(
    id: 'category_master',
    name: 'カテゴリマスター',
    description: 'すべての分野に投票しました',
    icon: '🎯',
    requiredCount: 8,
    type: 'categories',
  ),
  Achievement(
    id: 'trending_voter',
    name: 'トレンドボター',
    description: 'トレンド1位の議案に投票しました',
    icon: '🔥',
    requiredCount: 1,
    type: 'trends',
  ),
  Achievement(
    id: 'voting_streak_7',
    name: '7日連続投票',
    description: '7日間連続で投票しました',
    icon: '🔥',
    requiredCount: 7,
    type: 'voting_streak',
  ),
];

/// User achievement state
class UserAchievements {
  final String userId;
  final List<Achievement> unlockedAchievements;
  final int totalVotes;
  final Set<String> votedCategories;

  UserAchievements({
    required this.userId,
    required this.unlockedAchievements,
    required this.totalVotes,
    required this.votedCategories,
  });

  int get achievementCount => unlockedAchievements.length;
  int get completionPercentage =>
      ((achievementCount / allAchievements.length) * 100).toInt();
}

/// Provider for user achievements
final achievementProvider = FutureProvider.family<UserAchievements, String>(
  (ref, userId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Get user's vote data
      final votesSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('votes')
          .get();

      final totalVotes = votesSnapshot.size;
      final categories = <String>{};

      for (final doc in votesSnapshot.docs) {
        final category = doc['category'] as String?;
        if (category != null) {
          categories.add(category);
        }
      }

      // Get unlocked achievements from Firestore
      final achievementsSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .get();

      final unlockedIds = achievementsSnapshot.docs.map((doc) => doc.id).toSet();

      final unlockedAchievements = allAchievements
          .where((achievement) => unlockedIds.contains(achievement.id))
          .toList();

      return UserAchievements(
        userId: userId,
        unlockedAchievements: unlockedAchievements,
        totalVotes: totalVotes,
        votedCategories: categories,
      );
    } catch (e) {
      return UserAchievements(
        userId: userId,
        unlockedAchievements: [],
        totalVotes: 0,
        votedCategories: {},
      );
    }
  },
);

/// Check and unlock achievements based on user actions
Future<void> checkAndUnlockAchievements(
  String userId,
  Map<String, dynamic> updateData,
) async {
  final firestore = FirebaseFirestore.instance;
  final achievementsRef = firestore.collection('users').doc(userId).collection('achievements');

  final totalVotes = updateData['total_votes'] as int? ?? 0;
  final categories = (updateData['categories'] as List?)?.cast<String>() ?? [];

  // Check vote count achievements
  if (totalVotes >= 1) {
    _unlockAchievementIfNotExists(achievementsRef, 'first_vote');
  }
  if (totalVotes >= 10) {
    _unlockAchievementIfNotExists(achievementsRef, 'vote_10');
  }
  if (totalVotes >= 50) {
    _unlockAchievementIfNotExists(achievementsRef, 'vote_50');
  }
  if (totalVotes >= 100) {
    _unlockAchievementIfNotExists(achievementsRef, 'vote_100');
  }

  // Check category master achievement
  if (categories.length >= 8) {
    _unlockAchievementIfNotExists(achievementsRef, 'category_master');
  }
}

Future<void> _unlockAchievementIfNotExists(
  CollectionReference ref,
  String achievementId,
) async {
  final doc = await ref.doc(achievementId).get();
  if (!doc.exists) {
    await ref.doc(achievementId).set({
      'unlocked_at': FieldValue.serverTimestamp(),
    });
  }
}
