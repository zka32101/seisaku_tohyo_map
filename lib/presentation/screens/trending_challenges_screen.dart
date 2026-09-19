import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihon_future_map/infrastructure/providers/trending_provider.dart';

/// Screen displaying top 10 trending challenges with rank-based visualization
class TrendingChallengesScreen extends ConsumerWidget {
  const TrendingChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('トレンド'), centerTitle: true),
      body: trendingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
        data: (trending) => _buildContent(context, trending),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<TrendingItem> trending) {
    if (trending.isEmpty) {
      return const Center(child: Text('トレンドデータがありません'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trending.length,
      itemBuilder: (context, index) {
        final item = trending[index];
        final rank = index + 1;

        return TrendingCard(
          rank: rank,
          title: item.title,
          voteCount: item.thisWeekVotes,
          voteChange: item.voteChange,
          category: item.category,
        );
      },
    );
  }
}

/// Widget for displaying a single trending challenge
class TrendingCard extends StatelessWidget {
  const TrendingCard({
    super.key,
    required this.rank,
    required this.title,
    required this.voteCount,
    required this.voteChange,
    required this.category,
  });

  final int rank;
  final String title;
  final int voteCount;
  final int voteChange;
  final String category;

  @override
  Widget build(BuildContext context) {
    final isPositive = voteChange >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text(category),
                        labelStyle: const TextStyle(fontSize: 10),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '投票数: $voteCount',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Vote change indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 20,
                ),
                Text(
                  '${isPositive ? '+' : ''}$voteChange',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFD4AF37); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF3B82F6); // Blue
    }
  }
}
