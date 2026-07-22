class QuizQuestion {
  final String id;
  final String question;
  final String unit;
  final double correctAnswer;
  final String explanation;
  final String category;
  final String difficulty; // normal / advanced

  QuizQuestion({
    required this.id,
    required this.question,
    required this.unit,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    this.difficulty = 'normal',
  });
}

class QuizAnswer {
  final QuizQuestion question;
  final double userGuess;

  QuizAnswer({required this.question, required this.userGuess});

  double get gap => userGuess - question.correctAnswer;

  double get gapPercentage {
    if (question.correctAnswer == 0) return 0;
    return (gap.abs() / question.correctAnswer * 100).clamp(0, 999);
  }

  // 正解にどれだけ近かったか（0〜100）
  double get accuracy => (100 - gapPercentage).clamp(0, 100);

  bool get guessedTooLow => userGuess < question.correctAnswer;
}

enum DiagnosisLevel { master, average, beginner }

extension DiagnosisLevelInfo on DiagnosisLevel {
  String get title {
    switch (this) {
      case DiagnosisLevel.master:
        return '社会課題マスター';
      case DiagnosisLevel.average:
        return '平均的な認知度';
      case DiagnosisLevel.beginner:
        return '伸びしろ十分';
    }
  }

  String get emoji {
    switch (this) {
      case DiagnosisLevel.master:
        return '🏆';
      case DiagnosisLevel.average:
        return '📊';
      case DiagnosisLevel.beginner:
        return '🌱';
    }
  }

  String get message {
    switch (this) {
      case DiagnosisLevel.master:
        return '日本の社会課題について、かなり正確な感覚をお持ちです！';
      case DiagnosisLevel.average:
        return 'おおよその感覚は掴めています。もう少し詳しく知ると見方が変わるかも。';
      case DiagnosisLevel.beginner:
        return '実は多くの人が同じようにギャップを感じています。知ることが第一歩です。';
    }
  }
}

class QuizResult {
  final List<QuizAnswer> answers;

  QuizResult({required this.answers});

  double get averageAccuracy {
    if (answers.isEmpty) return 0;
    final total = answers.fold<double>(0, (sum, a) => sum + a.accuracy);
    return total / answers.length;
  }

  DiagnosisLevel get level {
    if (averageAccuracy >= 70) return DiagnosisLevel.master;
    if (averageAccuracy >= 40) return DiagnosisLevel.average;
    return DiagnosisLevel.beginner;
  }
}
