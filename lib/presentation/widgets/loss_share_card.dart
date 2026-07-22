import 'package:flutter/material.dart';

import '../../domain/entities/pension_calculation.dart';
import '../theme/app_theme.dart';

/// SNSシェア用に単体で成立するデザインの年金損益カード。
/// RepaintBoundary でキャプチャして画像化することを前提としたレイアウト。
class LossShareCard extends StatelessWidget {
  final PensionCalculation pension;

  const LossShareCard({super.key, required this.pension});

  @override
  Widget build(BuildContext context) {
    final isLoss = pension.isInTheMinus;
    final tone = isLoss ? AppColors.danger : AppColors.success;
    final toneLight = isLoss ? AppColors.dangerLight : AppColors.successLight;

    return Container(
      width: 360,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.public, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text(
                '日本の未来マップ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${pension.age}歳のあなたの年金は',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            isLoss ? '生涯で損をします' : '生涯で得をします',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: tone,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: toneLight,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Column(
              children: [
                Text(
                  isLoss ? '△' : '+',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: tone,
                  ),
                ),
                Text(
                  '¥${(pension.netLoss.abs() / 10000).toStringAsFixed(0)}万円',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: tone,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '納めた額の${pension.lossRate.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: '納める',
                  amount: pension.totalContributions,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniStat(label: '受け取る', amount: pension.totalBenefits),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'あなたの生涯損益もチェックしてみよう',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;

  const _MiniStat({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '¥${(amount / 10000).toStringAsFixed(0)}万',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
