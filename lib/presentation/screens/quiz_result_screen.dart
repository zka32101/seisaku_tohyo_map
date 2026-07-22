import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../application/providers/quiz_provider.dart';
import '../../domain/entities/quiz.dart';
import '../../infrastructure/analytics/analytics_service.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(quizResultProvider);
    final level = result.level;
    final isAdvanced = ref.watch(isAdvancedQuizProvider);
    final canChallengeAdvanced = level == DiagnosisLevel.master && !isAdvanced;

    return Scaffold(
      appBar: AppBar(title: const Text('診断結果')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(level.emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                level.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '平均正答度 ${result.averageAccuracy.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Text(
                  level.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 問題ごとの結果一覧
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '各問題の結果',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...result.answers.map((a) => _AnswerSummaryRow(answer: a)),
              const SizedBox(height: AppSpacing.lg),

              if (canChallengeAdvanced) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🏆 マスター認定！さらに上級問題に挑戦しますか？',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _startAdvanced(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                          icon: const Icon(Icons.military_tech, size: 18),
                          label: const Text('上級問題に挑戦する'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _shareResult(context, result),
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: const Text('結果をシェアする'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _copyResult(context, result),
                  icon: const Icon(Icons.content_copy, size: 18),
                  label: const Text('結果をコピーする'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    ref.read(isAdvancedQuizProvider.notifier).state = false;
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  child: const Text('トップに戻る'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildShareText(QuizResult result) {
    final emojiRow = result.answers.map((a) {
      if (a.accuracy >= 70) return '🟩';
      if (a.accuracy >= 40) return '🟨';
      return '🟥';
    }).join();

    return '日本の未来マップ 診断結果 ${result.level.emoji}\n'
        '${result.level.title}（正答度${result.averageAccuracy.toStringAsFixed(0)}%）\n'
        '$emojiRow\n'
        'あなたも社会課題への感覚をチェックしてみよう！';
  }

  void _startAdvanced(BuildContext context, WidgetRef ref) {
    ref.read(isAdvancedQuizProvider.notifier).state = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const QuizScreen()),
    );
  }

  Future<void> _shareResult(BuildContext context, QuizResult result) async {
    try {
      await Share.share(_buildShareText(result));
      AnalyticsService().logContentShared(contentType: 'quiz_result');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('シェアに失敗しました: $e')));
    }
  }

  void _copyResult(BuildContext context, QuizResult result) {
    Clipboard.setData(ClipboardData(text: _buildShareText(result)));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('結果をコピーしました！SNSに貼り付けてシェアしよう')));
  }
}

class _AnswerSummaryRow extends StatelessWidget {
  final QuizAnswer answer;

  const _AnswerSummaryRow({required this.answer});

  @override
  Widget build(BuildContext context) {
    final isClose = answer.accuracy >= 70;
    final tone = isClose ? AppColors.success : AppColors.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            isClose ? Icons.check_circle : Icons.info,
            color: tone,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  answer.question.question,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '予想 ${answer.userGuess.toStringAsFixed(1)}${answer.question.unit} / '
                  '実際 ${answer.question.correctAnswer.toStringAsFixed(1)}${answer.question.unit}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${answer.accuracy.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: tone,
            ),
          ),
        ],
      ),
    );
  }
}
