import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/firebase_provider.dart';
import '../../application/usecases/check_new_achievements.dart';
import '../../application/usecases/load_agency_contacts.dart';
import '../../domain/entities/challenge.dart';
import '../../infrastructure/analytics/analytics_service.dart';
import '../../infrastructure/local_storage/activity_store.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_unlock_dialog.dart';
import '../widgets/glossary_text.dart';
import '../widgets/offline_banner.dart';
import 'age_input_screen.dart';
import 'challenge_detail_screen.dart';
import 'glossary_screen.dart';
import 'good_news_screen.dart';
import 'overview_map_screen.dart';
import 'proposal_list_screen.dart';
import 'ranking_screen.dart';

const _categories = [
  'structural',
  'economy',
  'welfare',
  'demographic',
  'politics',
  'debt',
];

class ChallengeListScreen extends ConsumerWidget {
  const ChallengeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(challengesProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);
    final votedIds = ref.watch(agreedChallengeIdsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('気になる課題は？'),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_outlined),
            tooltip: '全体を俯瞰する',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OverviewMapScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: '用語集',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const GlossaryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard_outlined),
            tooltip: '週刊ランキング',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const RankingScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.campaign_outlined),
            tooltip: 'みんなの提案',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProposalListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: challengesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
        data: (challenges) {
          final recommended = _recommend(challenges, votedIds);
          final isSearching = searchQuery.trim().isNotEmpty;
          var filtered = selectedCategory == null
              ? challenges
              : challenges
                    .where((c) => c.category == selectedCategory)
                    .toList();
          if (isSearching) {
            filtered = filtered
                .where((c) => c.matchesSearch(searchQuery))
                .toList();
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const OfflineBanner(),
              const _SearchField(),
              const SizedBox(height: AppSpacing.md),
              Material(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GoodNewsScreen(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: AppColors.success,
                          size: 22,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '課題だけじゃない',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.success,
                                ),
                              ),
                              Text(
                                '良くなっていることも見てみよう',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _CategoryFilterRow(selectedCategory: selectedCategory),
              const SizedBox(height: AppSpacing.md),
              if (isSearching && filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Center(
                    child: Text(
                      '「$searchQuery」に一致する課題が見つかりませんでした',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              if (!isSearching &&
                  recommended.isNotEmpty &&
                  selectedCategory == null) ...[
                const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'あなたにおすすめ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ...recommended.map(
                  (c) => _ChallengeCard(challenge: c, isRecommended: true),
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
              ],
              ...filtered.map((c) => _ChallengeCard(challenge: c)),
            ],
          );
        },
      ),
    );
  }

  // 投票済み課題のカテゴリに近い、未投票の課題を投票数順におすすめする
  List<Challenge> _recommend(List<Challenge> challenges, Set<String> votedIds) {
    if (votedIds.isEmpty) return [];

    final votedCategories = challenges
        .where((c) => votedIds.contains(c.id))
        .map((c) => c.category)
        .toSet();

    final candidates =
        challenges
            .where(
              (c) =>
                  !votedIds.contains(c.id) &&
                  votedCategories.contains(c.category),
            )
            .toList()
          ..sort((a, b) => b.voteCount.compareTo(a.voteCount));

    return candidates.take(2).toList();
  }
}

class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);

    return TextField(
      controller: _controller,
      onChanged: (value) =>
          ref.read(searchQueryProvider.notifier).state = value,
      decoration: InputDecoration(
        hintText: 'キーワードやタグで検索（例: 年金, 子育て）',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _controller.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                },
              ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.badge),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.badge),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

class _CategoryFilterRow extends ConsumerWidget {
  final String? selectedCategory;

  const _CategoryFilterRow({required this.selectedCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'すべて',
            selected: selectedCategory == null,
            color: AppColors.textSecondary,
            onTap: () =>
                ref.read(selectedCategoryFilterProvider.notifier).state = null,
          ),
          ..._categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _FilterChip(
                label: AppColors.categoryLabel(category),
                icon: AppColors.categoryIcon(category),
                selected: selectedCategory == category,
                color: AppColors.categoryColor(category),
                onTap: () =>
                    ref.read(selectedCategoryFilterProvider.notifier).state =
                        category,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withValues(alpha: 0.15) : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.badge),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.badge),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.badge),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: selected ? color : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends ConsumerWidget {
  final String tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.badge),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.badge),
        onTap: () => ref.read(searchQueryProvider.notifier).state = tag,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.badge),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '#$tag',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChallengeCard extends ConsumerStatefulWidget {
  final Challenge challenge;
  final bool isRecommended;

  const _ChallengeCard({required this.challenge, this.isRecommended = false});

  @override
  ConsumerState<_ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends ConsumerState<_ChallengeCard> {
  late int _voteCount;
  late int _agreeCount;
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    _voteCount = widget.challenge.voteCount;
    _agreeCount = widget.challenge.agreeCount;
  }

  Future<void> _onAgree() async {
    if (_agreed) return;
    final result = await ref.read(
      agreeChallengeProvider(widget.challenge.id).future,
    );
    if (result && mounted) {
      setState(() {
        _agreeCount++;
        _agreed = true;
      });
      ref
          .read(agreedChallengeIdsProvider.notifier)
          .update((ids) => {...ids, widget.challenge.id});
      AnalyticsService().logAgreeSubmitted(challengeId: widget.challenge.id);
      final newlyUnlocked = await CheckNewAchievements.call(
        () => ActivityStore().addVotedChallenge(widget.challenge.id),
      );
      if (newlyUnlocked.isNotEmpty && mounted) {
        showAchievementUnlockDialogs(context, newlyUnlocked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(widget.challenge.category);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () {
          if (widget.challenge.id == 'my_pension_balance') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AgeInputScreen()),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ChallengeDetailScreen(challenge: widget.challenge),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.badge),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppColors.categoryIcon(widget.challenge.category),
                          size: 12,
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppColors.categoryLabel(widget.challenge.category),
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isRecommended) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.auto_awesome,
                      size: 13,
                      color: AppColors.primary,
                    ),
                  ],
                  if (LoadAgencyContacts.forChallenge(
                    widget.challenge.id,
                  ).isNotEmpty) ...[
                    const SizedBox(width: 6),
                    const Tooltip(
                      message: '運営者が関係省庁・窓口に問い合わせ済み',
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        size: 13,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(Icons.how_to_vote, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '$_voteCount',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.challenge.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              GlossaryText(
                widget.challenge.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              if (widget.challenge.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.challenge.tags
                      .map((tag) => _TagChip(tag: tag))
                      .toList(),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _agreed ? null : _onAgree,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: _agreed ? AppColors.border : color),
                    foregroundColor: _agreed ? AppColors.textMuted : color,
                  ),
                  child: Text(
                    _agreed ? '賛同済み ✓ ($_agreeCount)' : 'これは問題 ($_agreeCount)',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
