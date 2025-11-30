import 'package:quiz_app/CreateSection/models/question.dart';

class QuizAttempt {
  final List<Question> questions;
  final List<dynamic> answers;
  int score = 0;

  // Streak tracking
  int currentStreak = 0;
  int maxStreak = 0;

  QuizAttempt({required this.questions})
    : answers = List<dynamic>.filled(questions.length, null);

  /// Records the answer and updates streak. Returns streak change info.
  /// Returns: positive = streak gained, negative = streak lost, 0 = no change (first answer or already 0)
  int recordAnswer(int questionIndex, dynamic answer) {
    if (questionIndex >= 0 && questionIndex < answers.length) {
      answers[questionIndex] = answer;

      // Calculate if this answer is correct
      final question = questions[questionIndex];
      bool isCorrect = _isAnswerCorrect(question, answer);

      if (isCorrect) {
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
        return 1; // Streak gained
      } else {
        int streakLost = currentStreak > 0 ? -currentStreak : 0;
        currentStreak = 0;
        return streakLost; // Streak lost (negative) or 0 if was already 0
      }
    }
    return 0;
  }

  bool _isAnswerCorrect(Question question, dynamic answer) {
    if (answer == null) return false;

    if (question.type == QuestionType.multiMcq) {
      List<int> userSelection = List<int>.from(answer)..sort();
      List<int> correctSelection = List<int>.from(
        question.correctAnswerIndices!,
      )..sort();
      return userSelection.length == correctSelection.length &&
          userSelection.asMap().entries.every(
            (entry) => entry.value == correctSelection[entry.key],
          );
    } else {
      return answer == question.correctAnswerIndex;
    }
  }

  /// Get streak multiplier for scoring (1x base, increases with streak)
  double get streakMultiplier {
    if (currentStreak >= 5) return 3.0;
    if (currentStreak >= 3) return 2.0;
    if (currentStreak >= 2) return 1.5;
    return 1.0;
  }

  /// Get display text for streak multiplier
  String get streakMultiplierText {
    if (currentStreak >= 5) return 'x3';
    if (currentStreak >= 3) return 'x2';
    if (currentStreak >= 2) return 'x1.5';
    return 'x1';
  }

  void calculateScore() {
    score = 0;
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final userAnswer = answers[i];

      if (userAnswer == null) continue;

      bool isCorrect = false;
      if (question.type == QuestionType.multiMcq) {
        // For multi-select, compare sorted lists
        List<int> userSelection = List<int>.from(userAnswer)..sort();
        List<int> correctSelection = List<int>.from(
          question.correctAnswerIndices!,
        )..sort();
        isCorrect =
            userSelection.length == correctSelection.length &&
            userSelection.asMap().entries.every(
              (entry) => entry.value == correctSelection[entry.key],
            );
      } else {
        // For other types, direct comparison
        isCorrect = userAnswer == question.correctAnswerIndex;
      }

      if (isCorrect) {
        score++;
      }
    }
  }
}
