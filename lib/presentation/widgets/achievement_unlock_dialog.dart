import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/achievement.dart';
import '../theme/app_theme.dart';

/// 実績バッジを新しく獲得した際のお祝い演出を、順番に表示する
Future<void> showAchievementUnlockDialogs(
  BuildContext context,
  List<Achievement> achievements,
) async {
  for (final achievement in achievements) {
    if (!context.mounted) return;
    await _showSingle(context, achievement);
  }
}

Future<void> _showSingle(BuildContext context, Achievement achievement) {
  HapticFeedback.mediumImpact();
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'achievement_unlocked',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final scale = CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      );
      return Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale.value,
          child: _AchievementUnlockedCard(achievement: achievement),
        ),
      );
    },
  );
}

class _AchievementUnlockedCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementUnlockedCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉 実績を解除しました！',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(achievement.emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              achievement.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('やった！'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
