import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihon_future_map/infrastructure/providers/achievement_provider.dart';

/// Achievements and gamification screen
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('アチーブメント'),
        centerTitle: true,
      ),
      body: achievementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
        data: (userAchievements) => _buildContent(context, userAchievements),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserAchievements achievements) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress card
          _buildProgressCard(achievements),
          const SizedBox(height: 24),

          // Achievement grid
          const Text(
            'アチーブメント',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildAchievementGrid(achievements),
        ],
      ),
    );
  }

  Widget _buildProgressCard(UserAchievements achievements) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '進捗: ${achievements.achievementCount}/${allAchievements.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: achievements.completionPercentage / 100,
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${achievements.completionPercentage}% 達成',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            Text(
              '総投票数: ${achievements.totalVotes}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '投票済み分野: ${achievements.votedCategories.length}/8',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementGrid(UserAchievements achievements) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: allAchievements.length,
      itemBuilder: (context, index) {
        final achievement = allAchievements[index];
        final isUnlocked =
            achievements.unlockedAchievements.any((a) => a.id == achievement.id);

        return _buildAchievementCard(achievement, isUnlocked);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return Card(
      color: isUnlocked ? null : Colors.grey.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              achievement.icon,
              style: TextStyle(
                fontSize: 40,
                opacity: isUnlocked ? 1.0 : 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isUnlocked ? Colors.grey : Colors.grey.shade400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isUnlocked)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '達成済み',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
