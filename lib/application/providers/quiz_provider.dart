import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/quiz.dart';
import '../usecases/load_quiz_questions.dart';

// 上級問題モードで挑戦中かどうか
final isAdvancedQuizProvider = StateProvider<bool>((ref) => false);

final quizQuestionsProvider = Provider<List<QuizQuestion>>((ref) {
  final isAdvanced = ref.watch(isAdvancedQuizProvider);
  return isAdvanced ? LoadQuizQuestions.advanced() : LoadQuizQuestions.call();
});

// 現在の設問インデックス
final quizCurrentIndexProvider = StateProvider<int>((ref) => 0);

// これまでの回答リスト
final quizAnswersProvider = StateProvider<List<QuizAnswer>>((ref) => []);

final quizResultProvider = Provider<QuizResult>((ref) {
  final answers = ref.watch(quizAnswersProvider);
  return QuizResult(answers: answers);
});
