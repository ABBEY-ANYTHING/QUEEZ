import 'package:flutter/material.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/widgets/quiz/quiz_widgets.dart';

/// Multi-select options widget for live multiplayer mode.
/// Uses the shared QuizMcqOptions component with instant feedback.
class MultiSelectOptions extends StatefulWidget {
  final List<String> options;
  final Function(List<int>) onSubmit;
  final VoidCallback? onNextQuestion;
  final bool hasAnswered;
  final List<int>? selectedAnswers;
  final List<int>? correctAnswers;
  final bool? isCorrect;

  const MultiSelectOptions({
    super.key,
    required this.options,
    required this.onSubmit,
    this.onNextQuestion,
    required this.hasAnswered,
    this.selectedAnswers,
    this.correctAnswers,
    this.isCorrect,
  });

  @override
  State<MultiSelectOptions> createState() => _MultiSelectOptionsState();
}

class _MultiSelectOptionsState extends State<MultiSelectOptions> {
  List<int>? _localSelectedIndices;
  bool _submitted = false;

  @override
  void didUpdateWidget(MultiSelectOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset when question changes (new options)
    if (widget.options.length != oldWidget.options.length ||
        (widget.options.isNotEmpty && oldWidget.options.isNotEmpty && 
         widget.options[0] != oldWidget.options[0])) {
      AppLogger.debug('📝 MULTI_SELECT - New question detected, resetting');
      setState(() {
        _localSelectedIndices = null;
        _submitted = false;
      });
    }
    
    // Also reset if hasAnswered goes from true to false (new question)
    if (!widget.hasAnswered && oldWidget.hasAnswered) {
      AppLogger.debug('📝 MULTI_SELECT - hasAnswered changed to false, resetting');
      setState(() {
        _localSelectedIndices = null;
        _submitted = false;
      });
    }
  }

  void _handleAnswerSelected(dynamic answer) {
    if (_submitted || widget.hasAnswered) return;
    
    final indices = (answer as List).cast<int>();
    AppLogger.debug('📝 MULTI_SELECT - Submitting: $indices');
    setState(() {
      _localSelectedIndices = indices;
      _submitted = true;
    });
    // Submit immediately for instant local feedback
    widget.onSubmit(indices);
  }

  @override
  Widget build(BuildContext context) {
    // Use local selection immediately for instant feedback
    final effectiveSelectedIndices = _localSelectedIndices ?? widget.selectedAnswers;
    final hasResult = widget.correctAnswers != null;

    return QuizMcqOptions(
      options: widget.options,
      userAnswer: effectiveSelectedIndices,
      onAnswerSelected: _handleAnswerSelected,
      isMultiSelect: true,
      // Only pass correct answers when backend has responded
      correctAnswerIndices: widget.correctAnswers,
      // hasAnswered should reflect whether we have the result
      hasAnswered: hasResult,
      enabled: !_submitted && !widget.hasAnswered,
    );
  }
}
