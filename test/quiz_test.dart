import 'package:flutter_test/flutter_test.dart';
import 'package:nihon_future_map/domain/entities/quiz.dart';

QuizQuestion _question({double correct = 100}) {
  return QuizQuestion(
    id: 'test',
    question: 'テスト問題',
    unit: '%',
    correctAnswer: correct,
    explanation: 'テスト解説',
    category: 'economy',
  );
}

void main() {
  group('QuizAnswer', () {
    test('正解と完全一致した場合、正答度は100%', () {
      final answer = QuizAnswer(
        question: _question(correct: 100),
        userGuess: 100,
      );

      expect(answer.gap, 0);
      expect(answer.gapPercentage, 0);
      expect(answer.accuracy, 100);
    });

    test('予想が正解より低い場合、guessedTooLowはtrue', () {
      final answer = QuizAnswer(
        question: _question(correct: 100),
        userGuess: 50,
      );

      expect(answer.guessedTooLow, true);
      expect(answer.gap, -50);
      expect(answer.gapPercentage, 50);
      expect(answer.accuracy, 50);
    });

    test('予想が正解より高い場合、guessedTooLowはfalse', () {
      final answer = QuizAnswer(
        question: _question(correct: 100),
        userGuess: 150,
      );

      expect(answer.guessedTooLow, false);
      expect(answer.gapPercentage, 50);
      expect(answer.accuracy, 50);
    });

    test('乖離が100%を超えても正答度は0未満にならない', () {
      final answer = QuizAnswer(
        question: _question(correct: 100),
        userGuess: 500,
      );

      expect(answer.gapPercentage, 400);
      expect(answer.accuracy, 0);
    });

    test('正解が0の場合、gapPercentageは0を返す（ゼロ除算回避）', () {
      final answer = QuizAnswer(question: _question(correct: 0), userGuess: 50);

      expect(answer.gapPercentage, 0);
    });
  });

  group('QuizResult / DiagnosisLevel', () {
    test('平均正答度70%以上でマスター判定', () {
      final result = QuizResult(
        answers: [
          QuizAnswer(question: _question(), userGuess: 100), // 100%
          QuizAnswer(question: _question(), userGuess: 90), // 90%
        ],
      );

      expect(result.averageAccuracy, 95);
      expect(result.level, DiagnosisLevel.master);
    });

    test('平均正答度40〜70%未満で平均的な認知度判定', () {
      final result = QuizResult(
        answers: [
          QuizAnswer(question: _question(), userGuess: 50), // 50%
        ],
      );

      expect(result.level, DiagnosisLevel.average);
    });

    test('平均正答度40%未満で伸びしろ十分判定', () {
      final result = QuizResult(
        answers: [
          QuizAnswer(question: _question(), userGuess: 1000), // 0%扱い
        ],
      );

      expect(result.level, DiagnosisLevel.beginner);
    });

    test('回答が空の場合、averageAccuracyは0', () {
      final result = QuizResult(answers: []);

      expect(result.averageAccuracy, 0);
      expect(result.level, DiagnosisLevel.beginner);
    });
  });
}
