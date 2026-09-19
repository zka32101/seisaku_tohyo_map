import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihon_future_map/infrastructure/providers/recommendation_provider.dart';
import 'package:nihon_future_map/infrastructure/providers/user_preferences_provider.dart';

/// Personalized recommendations screen showing challenges matched to user interests
class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedInterests = ref.watch(selectedInterestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('あなたへのおすすめ'), centerTitle: true),
      body: selectedInterests.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
        data: (interests) => _buildContent(context, ref, interests),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<String> interests,
  ) {
    if (interests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('興味分野を選択してください'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to interest setup
                // Navigator.push(...);
              },
              child: const Text('設定する'),
            ),
          ],
        ),
      );
    }

    final recommendationsAsync = ref.watch(
      recommendationProvider((
        userId: userId,
        userInterests: interests,
        limit: 20,
      )),
    );

    return recommendationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('エラー: $error')),
      data: (recommendations) {
        if (recommendations.isEmpty) {
          return const Center(child: Text('おすすめの議案がありません'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            final recommendation = recommendations[index];
            return _buildRecommendationCard(context, recommendation);
          },
        );
      },
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    RecommendedChallenge recommendation,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with relevance score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    recommendation.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getRelevanceColor(recommendation.relevanceScore),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(recommendation.relevanceScore * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              recommendation.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),

            const SizedBox(height: 12),

            // Meta information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(recommendation.category),
                  labelStyle: const TextStyle(fontSize: 11),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Text(
                  '投票数: ${recommendation.voteCount}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Reason and action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    recommendation.reason,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to challenge detail and vote
                  },
                  icon: const Icon(Icons.thumb_up, size: 16),
                  label: const Text('投票'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRelevanceColor(double score) {
    if (score >= 0.8) {
      return Colors.green; // Highly relevant
    } else if (score >= 0.5) {
      return Colors.orange; // Moderately relevant
    } else {
      return Colors.grey; // Somewhat relevant
    }
  }
}
