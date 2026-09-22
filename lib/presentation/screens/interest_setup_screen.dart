import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihon_future_map/infrastructure/providers/user_preferences_provider.dart';
import 'package:nihon_future_map/presentation/theme/app_theme.dart';

/// 興味分野の設定画面。オンボーディング時だけでなく、マイページからいつでも
/// 編集できる。ここで選んだカテゴリは、課題一覧のおすすめ表示（まだ何も
/// 投票していないユーザー向けの初期表示）に使われる。
class InterestSetupScreen extends ConsumerWidget {
  const InterestSetupScreen({super.key});

  // Challenge.category と同じ内部コードを使う（表示名はAppColors.categoryLabelに揃える）
  static const List<String> interestCategories = [
    'economy',
    'welfare',
    'demographic',
    'politics',
    'debt',
    'structural',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedInterests = ref.watch(selectedInterestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('興味分野を選択'),
        centerTitle: true,
        elevation: 0,
      ),
      body: selectedInterests.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('エラーが発生しました: $error')),
        data: (interests) => _buildContent(context, ref, interests),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<String> selectedInterests,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: interestCategories.length,
            itemBuilder: (context, index) {
              final category = interestCategories[index];
              final isSelected = selectedInterests.contains(category);
              final color = AppColors.categoryColor(category);

              return Card(
                child: CheckboxListTile(
                  secondary: Icon(
                    AppColors.categoryIcon(category),
                    color: color,
                  ),
                  title: Text(AppColors.categoryLabel(category)),
                  value: isSelected,
                  onChanged: (value) {
                    ref
                        .read(selectedInterestsProvider.notifier)
                        .toggle(category);
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('完了'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
