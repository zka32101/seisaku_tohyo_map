import 'package:flutter/material.dart';

import '../../application/usecases/load_prefecture_aging_stats.dart';
import '../theme/app_theme.dart';

/// 都道府県選択ボトムシートを開き、選択結果を返す（キャンセル時はnull）
Future<String?> showPrefecturePicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _PrefecturePickerSheet(),
  );
}

class _PrefecturePickerSheet extends StatelessWidget {
  const _PrefecturePickerSheet();

  @override
  Widget build(BuildContext context) {
    final prefectures = LoadPrefectureAgingStats.all
        .map((s) => s.name)
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                'お住まいの都道府県を選択',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: prefectures.length,
                itemBuilder: (context, index) {
                  final name = prefectures[index];
                  return ListTile(
                    title: Text(name),
                    onTap: () => Navigator.of(context).pop(name),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
