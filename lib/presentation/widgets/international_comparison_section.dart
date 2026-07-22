import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/international_comparison.dart';
import '../theme/app_theme.dart';
import 'glossary_text.dart';

/// 「世界との比較」セクション。日本の数値を他国と横棒グラフで比べる。
class InternationalComparisonSection extends StatelessWidget {
  final InternationalComparison comparison;

  const InternationalComparisonSection({super.key, required this.comparison});

  @override
  Widget build(BuildContext context) {
    final entries = [
      (
        label: comparison.japanLabel,
        value: comparison.japanValue,
        isJapan: true,
      ),
      ...comparison.comparisons.map(
        (c) => (label: c.label, value: c.value, isJapan: false),
      ),
    ]..sort((a, b) => b.value.compareTo(a.value));

    final maxValue = entries
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
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
              const Icon(Icons.public, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  comparison.metricLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...entries.map((entry) {
            final ratio = maxValue == 0 ? 0.0 : entry.value / maxValue;
            final color = entry.isJapan
                ? AppColors.debtRed
                : AppColors.textMuted;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: entry.isJapan
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: entry.isJapan
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        entry.value % 1 == 0
                            ? entry.value.toStringAsFixed(0)
                            : entry.value.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation(
                        entry.isJapan ? color : color.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Text(
            comparison.unit,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          GlossaryText(
            comparison.note,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${comparison.source}（${comparison.asOfDate}）',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(comparison.sourceUrl),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new, size: 14),
                label: const Text('詳細を見る'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
