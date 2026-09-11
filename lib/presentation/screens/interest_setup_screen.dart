import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihon_future_map/infrastructure/providers/user_preferences_provider.dart';

/// Onboarding screen for user interest field selection
class InterestSetupScreen extends ConsumerWidget {
  const InterestSetupScreen({Key? key}) : super(key: key);

  static const List<String> interestCategories = [
    '経済・財政',
    '福祉・医療',
    '人口・地域',
    '環境・エネルギー',
    '政治構造',
    '教育・科学',
    '防衛・外交',
    'その他',
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

              return Card(
                child: CheckboxListTile(
                  title: Text(category),
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
              onPressed: selectedInterests.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('選択完了'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
