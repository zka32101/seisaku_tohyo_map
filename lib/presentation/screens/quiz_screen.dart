import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/quiz_provider.dart';
import '../../application/usecases/check_new_achievements.dart';
import '../../domain/entities/quiz.dart';
import '../../infrastructure/analytics/analytics_service.dart';
import '../../infrastructure/local_storage/activity_store.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_unlock_dialog.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final _guessController = TextEditingController();
  QuizAnswer? _revealed;

  @override
  void initState() {
    super.initState();
    // クイズ開始時に状態をリセット
    Future.microtask(() {
      ref.read(quizCurrentIndexProvider.notifier).state = 0;
      ref.read(quizAnswersProvider.notifier).state = [];
    });
  }

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  void _submitGuess(QuizQuestion question) {
    final guess = double.tryParse(_guessController.text);
    if (guess == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('数字で入力してください')));
      return;
    }

    final answer = QuizAnswer(question: question, userGuess: guess);
    setState(() => _revealed = answer);
  }

  Future<void> _next(List<QuizQuestion> questions) async {
    final revealed = _revealed;
    if (revealed == null) return;

    ref
        .read(quizAnswersProvider.notifier)
        .update((list) => [...list, revealed]);

    final currentIndex = ref.read(quizCurrentIndexProvider);
    if (currentIndex + 1 >= questions.length) {
      final result = ref.read(quizResultProvider);
      AnalyticsService().logQuizCompleted(
        diagnosisLevel: result.level.name,
        averageAccuracy: result.averageAccuracy,
        isAdvanced: ref.read(isAdvancedQuizProvider),
      );
      final newlyUnlocked = await CheckNewAchievements.call(
        () => ActivityStore().incrementQuizzesCompleted(),
      );
      if (!mounted) return;
      if (newlyUnlocked.isNotEmpty) {
        await showAchievementUnlockDialogs(context, newlyUnlocked);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const QuizResultScreen()),
      );
      return;
    }

    ref.read(quizCurrentIndexProvider.notifier).state = currentIndex + 1;
    _guessController.clear();
    setState(() => _revealed = null);
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(quizQuestionsProvider);
    final currentIndex = ref.watch(quizCurrentIndexProvider);
    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${ref.watch(isAdvancedQuizProvider) ? '上級' : ''}ギャップクイズ '
          '${currentIndex + 1}/${questions.length}',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value:
                    (currentIndex + (_revealed != null ? 1 : 0)) /
                    questions.length,
                minHeight: 6,
                backgroundColor: AppColors.background,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                question.question,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_revealed == null) ...[
                TextField(
                  controller: _guessController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: InputDecoration(
                    hintText: '予想を入力',
                    suffixText: question.unit,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _submitGuess(question),
                    child: const Text('答え合わせ'),
                  ),
                ),
              ] else ...[
                _GapResultCard(answer: _revealed!),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _next(questions),
                    child: Text(
                      currentIndex + 1 >= questions.length ? '結果を見る' : '次の問題へ',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GapResultCard extends StatelessWidget {
  final QuizAnswer answer;

  const _GapResultCard({required this.answer});

  @override
  Widget build(BuildContext context) {
    final isClose = answer.accuracy >= 70;
    final tone = isClose ? AppColors.success : AppColors.danger;
    final toneLight = isClose ? AppColors.successLight : AppColors.dangerLight;
    final maxValue = [
      answer.userGuess.abs(),
      answer.question.correctAnswer.abs(),
    ].reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: toneLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isClose
                ? 'かなり近い！'
                : answer.guessedTooLow
                ? '実際はもっと大きい'
                : '実際はもっと小さい',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: tone,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _BarRow(
            label: 'あなたの予想',
            value: answer.userGuess,
            unit: answer.question.unit,
            maxValue: maxValue,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.sm),
          _BarRow(
            label: '実際の値',
            value: answer.question.correctAnswer,
            unit: answer.question.unit,
            maxValue: maxValue,
            color: tone,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            answer.question.explanation,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double maxValue;
  final Color color;

  const _BarRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue == 0
        ? 0.0
        : (value.abs() / maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
