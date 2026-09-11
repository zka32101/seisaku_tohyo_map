import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihon_future_map/infrastructure/providers/search_provider.dart';

/// Advanced search screen with keyword, category filter, and sorting options
class AdvancedSearchScreen extends ConsumerStatefulWidget {
  const AdvancedSearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdvancedSearchScreen> createState() =>
      _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen> {
  final _searchController = TextEditingController();
  final List<String> _selectedCategories = [];
  String _sortBy = 'relevance';

  static const List<String> categories = [
    '経済・財政',
    '福祉・医療',
    '人口・地域',
    '環境・エネルギー',
    '政治構造',
    '教育・科学',
    '防衛・外交',
    'その他',
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

  @override
  Widget build(BuildContext context) {
    final searchParams = SearchParams(
      query: _searchController.text,
      categories: _selectedCategories,
      sortBy: _sortBy,
    );

    final searchResults = ref.watch(searchProvider(searchParams));

    return Scaffold(
      appBar: AppBar(
        title: const Text('詳細検索'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'キーワードを入力',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),

          // Category filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('分野を選択', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sort options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('並び替え', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: sortOptions
                      .map(
                        (option) => ButtonSegment(
                          value: option,
                          label: Text(sortLabels[option] ?? option),
                        ),
                      )
                      .toList(),
                  selected: {_sortBy},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _sortBy = newSelection.first;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search results
          Expanded(
            child: searchResults.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('エラー: $error')),
              data: (results) {
                if (results.isEmpty) {
                  return const Center(child: Text('検索結果がありません'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(result.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              result.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Chip(
                                  label: Text(result.category),
                                  labelStyle: const TextStyle(fontSize: 10),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '投票数: ${result.voteCount}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigate to detail screen
                          // Navigator.push(...);
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
