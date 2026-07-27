import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/firebase_provider.dart';
import '../../application/providers/good_news_provider.dart';
import '../../application/usecases/load_agency_contacts.dart';
import '../../application/usecases/load_diet_bills.dart';
import '../../application/usecases/load_international_comparisons.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/good_news_item.dart';
import '../theme/app_theme.dart';
import 'age_input_screen.dart';
import 'challenge_detail_screen.dart';
import 'good_news_screen.dart';

const _categories = [
  'structural',
  'economy',
  'welfare',
  'demographic',
  'politics',
  'debt',
];
const _goodNewsSectionKey = 'good_news';

/// 24件の課題・良くなっていることを1画面のマップとして俯瞰し、
/// 個別画面を行き来するだけでは見えづらい「全体感」をつかむための画面。
/// カテゴリごとにセクション分けし、何も隠さず全件を一望できる構成にしている。
class OverviewMapScreen extends ConsumerStatefulWidget {
  const OverviewMapScreen({super.key});

  @override
  ConsumerState<OverviewMapScreen> createState() => _OverviewMapScreenState();
}

class _OverviewMapScreenState extends ConsumerState<OverviewMapScreen> {
  final _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {
    for (final category in _categories) category: GlobalKey(),
    _goodNewsSectionKey: GlobalKey(),
  };

  void _jumpTo(String sectionId) {
    final context = _sectionKeys[sectionId]?.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challengesAsync = ref.watch(challengesProvider);
    final goodNews = ref.watch(goodNewsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('全体を俯瞰する')),
      body: challengesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
        data: (challenges) {
          final dietBillCount = challenges
              .where((c) => LoadDietBills.forChallenge(c.id).isNotEmpty)
              .length;
          final intlCount =
              challenges
                  .where(
                    (c) => LoadInternationalComparisons.forId(c.id) != null,
                  )
                  .length +
              goodNews
                  .where(
                    (g) => LoadInternationalComparisons.forId(g.id) != null,
                  )
                  .length;

          final byCategory = {
            for (final category in _categories)
              category: challenges
                  .where((c) => c.category == category)
                  .toList(),
          };

          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _SummaryCard(
                challengeCount: challenges.length,
                goodNewsCount: goodNews.length,
                dietBillCount: dietBillCount,
                intlCount: intlCount,
              ),
              const SizedBox(height: AppSpacing.md),
              _SectionJumpRow(
                categories: _categories
                    .where((c) => (byCategory[c] ?? const []).isNotEmpty)
                    .toList(),
                hasGoodNews: goodNews.isNotEmpty,
                onCategoryTap: (category) => _jumpTo(category),
                onGoodNewsTap: () => _jumpTo(_goodNewsSectionKey),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final category in _categories)
                if ((byCategory[category] ?? const []).isNotEmpty)
                  _CategorySection(
                    key: _sectionKeys[category],
                    category: category,
                    challenges: byCategory[category]!,
                  ),
              if (goodNews.isNotEmpty)
                _GoodNewsSection(
                  key: _sectionKeys[_goodNewsSectionKey],
                  items: goodNews,
                ),
            ],
          );
        },
      ),
    );
  }
}

/// 課題・良くなっていること・国会議案・世界比較の件数を一目で見せるサマリー
class _SummaryCard extends StatelessWidget {
  final int challengeCount;
  final int goodNewsCount;
  final int dietBillCount;
  final int intlCount;

  const _SummaryCard({
    required this.challengeCount,
    required this.goodNewsCount,
    required this.dietBillCount,
    required this.intlCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.list_alt,
              label: '課題',
              value: '$challengeCount',
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.trending_up,
              label: '良くなっている',
              value: '$goodNewsCount',
              color: AppColors.success,
            ),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.account_balance,
              label: '国会議案',
              value: '$dietBillCount',
              color: AppColors.politicsPurple,
            ),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.public,
              label: '世界比較',
              value: '$intlCount',
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

/// 「今どこにいるか」ではなく「どこに何があるか」を示すセクション目次
class _SectionJumpRow extends StatelessWidget {
  final List<String> categories;
  final bool hasGoodNews;
  final ValueChanged<String> onCategoryTap;
  final VoidCallback onGoodNewsTap;

  const _SectionJumpRow({
    required this.categories,
    required this.hasGoodNews,
    required this.onCategoryTap,
    required this.onGoodNewsTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ActionChip(
                avatar: Icon(
                  AppColors.categoryIcon(category),
                  size: 14,
                  color: AppColors.categoryColor(category),
                ),
                label: Text(
                  AppColors.categoryLabel(category),
                  style: const TextStyle(fontSize: 12),
                ),
                onPressed: () => onCategoryTap(category),
                backgroundColor: AppColors.categoryColor(
                  category,
                ).withValues(alpha: 0.08),
                side: BorderSide(
                  color: AppColors.categoryColor(
                    category,
                  ).withValues(alpha: 0.2),
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          if (hasGoodNews)
            ActionChip(
              avatar: const Icon(
                Icons.trending_up,
                size: 14,
                color: AppColors.success,
              ),
              label: const Text('良い動き', style: TextStyle(fontSize: 12)),
              onPressed: onGoodNewsTap,
              backgroundColor: AppColors.success.withValues(alpha: 0.08),
              side: BorderSide(color: AppColors.success.withValues(alpha: 0.2)),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        ],
      ),
    );
  }
}

/// 1カテゴリ分の見出し＋タイルグリッド
class _CategorySection extends StatelessWidget {
  final String category;
  final List<Challenge> challenges;

  const _CategorySection({
    super.key,
    required this.category,
    required this.challenges,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppColors.categoryIcon(category), size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                AppColors.categoryLabel(category),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${challenges.length}件',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.92,
            ),
            itemCount: challenges.length,
            itemBuilder: (context, index) =>
                _ChallengeTile(challenge: challenges[index]),
          ),
        ],
      ),
    );
  }
}

/// 「良くなっていること」セクション（見出し＋タイルグリッド）
class _GoodNewsSection extends StatelessWidget {
  final List<GoodNewsItem> items;

  const _GoodNewsSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, size: 18, color: AppColors.success),
              const SizedBox(width: 6),
              const Text(
                '良くなっていること',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${items.length}件',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.92,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => _GoodNewsTile(item: items[index]),
          ),
        ],
      ),
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  final Challenge challenge;

  const _ChallengeTile({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(challenge.category);
    final hasDietBill = LoadDietBills.forChallenge(challenge.id).isNotEmpty;
    final hasIntl = LoadInternationalComparisons.forId(challenge.id) != null;
    final hasAgencyContact = LoadAgencyContacts.forChallenge(
      challenge.id,
    ).isNotEmpty;

    return Material(
      color: color.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () {
          if (challenge.id == 'my_pension_balance') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AgeInputScreen()),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChallengeDetailScreen(challenge: challenge),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasDietBill || hasIntl || hasAgencyContact)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (hasDietBill)
                      const Padding(
                        padding: EdgeInsets.only(left: 3),
                        child: Icon(
                          Icons.account_balance,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    if (hasIntl)
                      const Padding(
                        padding: EdgeInsets.only(left: 3),
                        child: Icon(
                          Icons.public,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    if (hasAgencyContact)
                      const Padding(
                        padding: EdgeInsets.only(left: 3),
                        child: Icon(
                          Icons.mark_email_read_outlined,
                          size: 12,
                          color: AppColors.success,
                        ),
                      ),
                  ],
                ),
              Expanded(
                child: Text(
                  challenge.name,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.how_to_vote,
                    size: 11,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${challenge.voteCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoodNewsTile extends StatelessWidget {
  final GoodNewsItem item;

  const _GoodNewsTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.success.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const GoodNewsScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.trending_up,
                  size: 14,
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '改善中',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
