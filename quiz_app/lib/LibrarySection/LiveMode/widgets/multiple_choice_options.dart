import 'package:flutter/material.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/widgets/quiz/quiz_widgets.dart';

/// Multiple choice options widget for live multiplayer mode.
/// Uses the shared QuizMcqOptions component with instant feedback.
class MultipleChoiceOptions extends StatefulWidget {
  final List options;
  final Function(int) onSelect;
  final int? selectedAnswer;
  final String? correctAnswer;
  final bool hasAnswered;
  final bool? isCorrect;

  const MultipleChoiceOptions({
    super.key,
    required this.options,
    required this.onSelect,
    this.selectedAnswer,
    this.correctAnswer,
    required this.hasAnswered,
    this.isCorrect,
  });

  @override
  State<MultipleChoiceOptions> createState() => _MultipleChoiceOptionsState();
}

class _MultipleChoiceOptionsState extends State<MultipleChoiceOptions> {
  int? _localSelectedIndex;

  @override
  void didUpdateWidget(MultipleChoiceOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset when question changes (new options list)
    if (widget.options.length != oldWidget.options.length ||
        (widget.options.isNotEmpty && oldWidget.options.isNotEmpty && 
         widget.options[0] != oldWidget.options[0])) {
      AppLogger.debug('📝 SINGLE_CHOICE - New question detected, resetting');
      setState(() {
        _localSelectedIndex = null;
      });
    }
  }

  int? _getCorrectAnswerIndex() {
    if (widget.correctAnswer == null) return null;
    final parsed = int.tryParse(widget.correctAnswer!);
    if (parsed != null) return parsed;
    for (int i = 0; i < widget.options.length; i++) {
      if (widget.options[i].toString() == widget.correctAnswer) {
        return i;
      }
    }
    return null;
  }

  void _handleAnswerSelected(dynamic answer) {
    if (_localSelectedIndex != null || widget.hasAnswered) return;
    
    AppLogger.debug('📝 SINGLE_CHOICE - User selected option $answer');
    setState(() {
      _localSelectedIndex = answer as int;
    });
    // Submit immediately for instant local feedback
    widget.onSelect(answer as int);
  }

  @override
  Widget build(BuildContext context) {
    // Use local selection immediately for instant feedback
    final effectiveSelectedIndex = _localSelectedIndex ?? widget.selectedAnswer;
    final correctIndex = _getCorrectAnswerIndex();
    final hasResult = widget.correctAnswer != null;

    return QuizMcqOptions(
      options: widget.options.map((e) => e.toString()).toList(),
      userAnswer: effectiveSelectedIndex,
      onAnswerSelected: _handleAnswerSelected,
      isMultiSelect: false,
      // Only pass correct answer when backend has responded
      correctAnswerIndex: correctIndex,
      // hasAnswered should reflect whether we have the result, not just local selection
      hasAnswered: hasResult,
      enabled: _localSelectedIndex == null && !widget.hasAnswered,
    );
  }
}
