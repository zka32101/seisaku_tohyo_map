import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/firebase_provider.dart';
import '../../domain/entities/challenge.dart';
import '../navigation/navigation_helpers.dart';
import '../theme/app_theme.dart';
import 'challenge_detail_screen.dart';

/// キーワード・カテゴリ・並び替えで課題を絞り込む詳細検索画面。
///
/// 課題一覧は（アプリ全体の設計と同じく）Firestoreではなくローカルの
/// [challengesProvider]（モックデータ）から取得し、クライアント側で
/// フィルタ・ソートする。実在しないFirestoreコレクションを検索していた
/// 旧実装を、実際のデータソースに合わせて書き直したもの。
class AdvancedSearchScreen extends ConsumerStatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  ConsumerState<AdvancedSearchScreen> createState() =>
      _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen> {
  final _searchController = TextEditingController();
  final Set<String> _selectedCategories = {};
  String _sortBy = 'relevance';

  // Challenge.category の内部コードと表示ラベルの対応（AppColors.categoryLabelと一致させる）
  static const List<String> categoryCodes = [
    'economy',
    'welfare',
    'demographic',
    'politics',
    'debt',
    'structural',
  ];

  static const List<String> sortOptions = ['relevance', 'newest', 'popular'];
  static const Map<String, String> sortLabels = {
    'relevance': '関連度',
    'newest': '最新',
    'popular': '投票数',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Challenge> _filterAndSort(List<Challenge> challenges) {
    final query = _searchController.text.trim();
    var results = challenges.where((c) {
      if (_selectedCategories.isNotEmpty &&
          !_selectedCategories.contains(c.category)) {
        return false;
      }
      return c.matchesSearch(query);
    }).toList();

    switch (_sortBy) {
      case 'newest':
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'popular':
        results.sort((a, b) => b.voteCount.compareTo(a.voteCount));
        break;
      case 'relevance':
      default:
        if (query.isNotEmpty) {
          final q = query.toLowerCase();
          results.sort((a, b) {
            final aStarts = a.name.toLowerCase().contains(q);
            final bStarts = b.name.toLowerCase().contains(q);
            if (aStarts && !bStarts) return -1;
            if (!aStarts && bStarts) return 1;
            return b.voteCount.compareTo(a.voteCount);
          });
        } else {
          results.sort((a, b) => b.voteCount.compareTo(a.voteCount));
        }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final challengesAsync = ref.watch(challengesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('詳細検索'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'キーワードを入力',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('分野を選択', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categoryCodes.map((code) {
                    final isSelected = _selectedCategories.contains(code);
                    final color = AppColors.categoryColor(code);
                    return FilterChip(
                      label: Text(AppColors.categoryLabel(code)),
                      avatar: Icon(
                        AppColors.categoryIcon(code),
                        size: 16,
                        color: isSelected ? Colors.white : color,
                      ),
                      selected: isSelected,
                      selectedColor: color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(code);
                          } else {
                            _selectedCategories.remove(code);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                const Text('並び替え', style: TextStyle(fontSize: 14)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: sortOptions
                          .map(
                            (option) => ButtonSegment(
                              value: option,
                              label: Text(sortLabels[option] ?? option),
                            ),
                          )
                          .toList(),
                      selected: {_sortBy},
                      onSelectionChanged: (newSelection) {
                        setState(() => _sortBy = newSelection.first);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: challengesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('エラー: $error')),
              data: (challenges) {
                final results = _filterAndSort(challenges);
                if (results.isEmpty) {
                  return const Center(child: Text('検索結果がありません'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final challenge = results[index];
                    final color = AppColors.categoryColor(challenge.category);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(challenge.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              challenge.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    AppColors.categoryLabel(challenge.category),
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 10,
                                    color: color,
                                  ),
                                  backgroundColor: color.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '投票数: ${challenge.voteCount}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          context.pushScreenWithTransition(
                            ChallengeDetailScreen(challenge: challenge),
                            screenName: 'ChallengeDetail',
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
