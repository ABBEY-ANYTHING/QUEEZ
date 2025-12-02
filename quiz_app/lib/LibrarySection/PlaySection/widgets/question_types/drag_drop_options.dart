import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/question.dart';
import 'package:quiz_app/widgets/quiz/quiz_widgets.dart';

/// Drag & Drop options widget for single player mode.
/// Uses the shared QuizDragDropOptions component.
class DragDropOptions extends StatelessWidget {
  final Question question;
  final dynamic userAnswer;
  final ValueChanged<dynamic> onAnswerSelected;
  final ScrollController? scrollController;

  const DragDropOptions({
    super.key,
    required this.question,
    this.userAnswer,
    required this.onAnswerSelected,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // Convert userAnswer to Map<String, String> if needed
    Map<String, String>? answerMap;
    if (userAnswer != null && userAnswer is Map) {
      answerMap = Map<String, String>.from(userAnswer);
    }

    // Build correct matches from question data - use the question's correctMatches if available
    Map<String, String>? correctMatches;
    if (userAnswer != null) {
      // First try to use the question's correctMatches
      if (question.correctMatches != null && question.correctMatches!.isNotEmpty) {
        correctMatches = question.correctMatches;
      } else if (question.dragItems != null && question.dropTargets != null) {
        // Fallback: derive from dragItems/dropTargets order
        if (question.dragItems!.length == question.dropTargets!.length) {
          correctMatches = {};
          for (int i = 0; i < question.dragItems!.length; i++) {
            correctMatches[question.dragItems![i]] = question.dropTargets![i];
          }
        }
      }
    }

    final hasAnswered = userAnswer != null;

    return QuizDragDropOptions(
      dragItems: question.dragItems ?? [],
      dropTargets: question.dropTargets ?? [],
      userAnswer: answerMap,
      correctMatches: hasAnswered ? correctMatches : null,
      onAnswerSelected: onAnswerSelected,
      hasAnswered: hasAnswered,
      enabled: !hasAnswered, // Disable when already answered
      scrollController: scrollController,
    );
  }
}
