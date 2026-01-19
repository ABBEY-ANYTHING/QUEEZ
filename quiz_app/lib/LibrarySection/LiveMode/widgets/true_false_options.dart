import 'package:flutter/material.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/widgets/quiz/quiz_widgets.dart';

/// True/False options widget for live multiplayer mode.
/// Uses the shared QuizTrueFalseOptions component with instant feedback.
class TrueFalseOptions extends StatefulWidget {
  final Function(int) onSelect;
  final int? selectedAnswer;
  final int? correctAnswer;
  final bool hasAnswered;
  final bool? isCorrect;

  const TrueFalseOptions({
    super.key,
    required this.onSelect,
    this.selectedAnswer,
    this.correctAnswer,
    required this.hasAnswered,
    this.isCorrect,
  });

  @override
  State<TrueFalseOptions> createState() => _TrueFalseOptionsState();
}

class _TrueFalseOptionsState extends State<TrueFalseOptions> {
  int? _localSelectedValue;

  @override
  void didUpdateWidget(TrueFalseOptions oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset when moving to new question (correctAnswer becomes null again)
    if (widget.correctAnswer == null && oldWidget.correctAnswer != null) {
      setState(() {
        _localSelectedValue = null;
      });
    }
  }

  void _handleAnswerSelected(int value) {
    if (_localSelectedValue != null || widget.hasAnswered) return;

    AppLogger.debug('Answer selected: ${value == 0 ? "TRUE" : "FALSE"}');
    setState(() {
      _localSelectedValue = value;
    });
    // Submit immediately for instant local feedback
    widget.onSelect(value);
  }

  @override
  Widget build(BuildContext context) {
    // Use local selection immediately for instant feedback
    final effectiveSelectedValue = _localSelectedValue ?? widget.selectedAnswer;
    final hasResult = widget.correctAnswer != null;

    return QuizTrueFalseOptions(
      userAnswer: effectiveSelectedValue,
      // Only pass correct answer when backend has responded
      correctAnswer: widget.correctAnswer,
      onAnswerSelected: _handleAnswerSelected,
      // hasAnswered should reflect whether we have the result
      hasAnswered: hasResult,
      enabled: _localSelectedValue == null && !widget.hasAnswered,
    );
  }
}
