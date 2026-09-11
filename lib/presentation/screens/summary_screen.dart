import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihon_future_map/infrastructure/providers/summary_provider.dart';

/// Summary dashboard showing weekly and monthly voting summaries
class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklySummaryAsync = ref.watch(weeklySummaryProvider(userId));
    final monthlySummaryAsync = ref.watch(monthlySummaryProvider(userId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('サマリー'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: '週間'),
              Tab(text: '月間'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Weekly tab
            weeklySummaryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('エラー: $error')),
              data: (summary) => _buildWeeklySummary(context, summary),
            ),

            // Monthly tab
            monthlySummaryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('エラー: $error')),
              data: (summary) => _buildMonthlySummary(context, summary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummary(BuildContext context, WeeklySummary summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header stats
          _buildWeeklyHeader(summary),
          const SizedBox(height: 24),

          // Vote stats
          _buildVoteStatsCard(summary),
          const SizedBox(height: 16),

          // Top category
          _buildTopCategoryCard(summary),
          const SizedBox(height: 16),

          // Consistency score
          _buildConsistencyCard(summary),
          const SizedBox(height: 16),

          // New categories
          _buildNewCategoriesCard(summary),
          const SizedBox(height: 16),

          // Key insight
          _buildInsightCard(summary),
        ],
      ),
    );
  }

  Widget _buildWeeklyHeader(WeeklySummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${summary.weekStart.month}月${summary.weekStart.day}日 - ${summary.weekEnd.month}月${summary.weekEnd.day}日',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('今週の投票数'),
                    Text(
                      '${summary.votesThisWeek}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('先週比'),
                    Row(
                      children: [
                        Icon(
                          summary.voteChange >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: summary.voteChange >= 0
                              ? Colors.green
                              : Colors.red,
                          size: 20,
                        ),
                        Text(
                          '${summary.voteChange > 0 ? '+' : ''}${summary.voteChange}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: summary.voteChange >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteStatsCard(WeeklySummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '投票統計',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('今週', '${summary.votesThisWeek}'),
                _buildStatColumn('先週', '${summary.votesLastWeek}'),
                _buildStatColumn(
                  '変化率',
                  '${summary.votesLastWeek > 0 ? ((summary.voteChange / summary.votesLastWeek) * 100).toStringAsFixed(0) : 0}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTopCategoryCard(WeeklySummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最も投票した分野',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  summary.topCategory,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${summary.topCategoryCount}件',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsistencyCard(WeeklySummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '投票の一貫性',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: summary.isConsistent
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    summary.isConsistent ? '安定' : '変動',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: summary.isConsistent ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: summary.consistencyScore / 100,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${summary.consistencyScore.toStringAsFixed(0)}% (${summary.consistencyScore ~/ 20}日/7日投票)',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewCategoriesCard(WeeklySummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '新しく投票した分野',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (summary.newCategoriesVoted.isEmpty)
              const Text(
                '先週と同じ分野に投票しています',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: summary.newCategoriesVoted
                    .map(
                      (category) => Chip(
                        label: Text(category),
                        backgroundColor: Colors.green.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(WeeklySummary summary) {
    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今週のアドバイス',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary.isConsistent
                        ? 'コンスタントに投票しています！ペースを保ちましょう'
                        : '別の分野にも投票してみることで視点を広げましょう',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummary(BuildContext context, MonthlySummary summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildMonthlyHeader(summary),
          const SizedBox(height: 24),

          // Vote stats
          _buildMonthlyVoteStats(summary),
          const SizedBox(height: 16),

          // Category breakdown
          _buildCategoryBreakdown(summary),
          const SizedBox(height: 16),

          // Realization rate
          _buildRealizationCard(summary),
          const SizedBox(height: 16),

          // Key insight
          _buildMonthlyInsightCard(summary),
        ],
      ),
    );
  }

  Widget _buildMonthlyHeader(MonthlySummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${summary.year}年${summary.month}月',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('今月の投票数'),
                    Text(
                      '${summary.totalVotes}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('前月比'),
                    Row(
                      children: [
                        Icon(
                          summary.isGrowing
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color:
                              summary.isGrowing ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        Text(
                          '${summary.growthRate.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                summary.isGrowing ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyVoteStats(MonthlySummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '月間統計',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('今月', '${summary.totalVotes}'),
                _buildStatColumn('先月', '${summary.totalVotesLastMonth}'),
                _buildStatColumn(
                  '投票数増減',
                  '${summary.voteChange > 0 ? '+' : ''}${summary.voteChange}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(MonthlySummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '分野別投票数',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...summary.categoryBreakdown.entries.map((entry) {
              final percentage = summary.totalVotes > 0
                  ? (entry.value / summary.totalVotes) * 100
                  : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text('${entry.value}件 (${percentage.toStringAsFixed(0)}%)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRealizationCard(MonthlySummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '実現率',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: summary.realizationRate / 100,
                      minHeight: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${summary.realizationRate.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${summary.realizationCount}/${summary.totalVotes}件が実現',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyInsightCard(MonthlySummary summary) {
    return Card(
      color: Colors.purple.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.insights, color: Colors.purple),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '月間インサイト',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary.keyInsight,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '最も投票した分野: ${summary.dominantCategory}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
