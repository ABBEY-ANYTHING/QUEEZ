import 'package:flutter/material.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/widgets/quiz/quiz_widgets.dart';

/// Drag & Drop interface widget for live multiplayer mode.
/// Uses the shared QuizDragDropOptions component with instant feedback.
class DragDropInterface extends StatefulWidget {
  final List<String> dragItems;
  final List<String> dropTargets;
  final Function(Map<String, String>) onMatchSubmit;
  final bool hasAnswered; // From game state - true when backend confirmed answer
  final bool? isCorrect;
  final Map<String, String>? correctMatches; // This comes from question data, NOT answer result

  const DragDropInterface({
    super.key,
    required this.dragItems,
    required this.dropTargets,
    required this.onMatchSubmit,
    required this.hasAnswered,
    this.isCorrect,
    this.correctMatches,
  });

  @override
  State<DragDropInterface> createState() => _DragDropInterfaceState();
}

class _DragDropInterfaceState extends State<DragDropInterface> {
  Map<String, String>? _localSubmittedAnswer;
  bool _submitted = false;

  @override
  void didUpdateWidget(DragDropInterface oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset when question changes
    if (!_listEquals(oldWidget.dragItems, widget.dragItems) ||
        !_listEquals(oldWidget.dropTargets, widget.dropTargets)) {
      AppLogger.debug('📝 DRAG_DROP - Question changed, resetting');
      setState(() {
        _localSubmittedAnswer = null;
        _submitted = false;
      });
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _handleAnswerSelected(Map<String, String> answer) {
    if (_submitted || widget.hasAnswered) return;
    
    AppLogger.debug('📝 DRAG_DROP - Submitting matches: $answer');
    setState(() {
      _localSubmittedAnswer = answer;
      _submitted = true;
    });
    widget.onMatchSubmit(answer);
  }

  @override
  Widget build(BuildContext context) {
    // Only show feedback when:
    // 1. User has submitted locally (_submitted)
    // 2. AND backend has confirmed (widget.hasAnswered)
    // 3. AND we have correct matches to compare against
    final showFeedback = _submitted && widget.hasAnswered && widget.correctMatches != null;
    final isEnabled = !_submitted && !widget.hasAnswered;
    
    AppLogger.debug('🎮 DragDropInterface build:');
    AppLogger.debug('   enabled: $isEnabled');
    AppLogger.debug('   _submitted: $_submitted');
    AppLogger.debug('   widget.hasAnswered: ${widget.hasAnswered}');
    AppLogger.debug('   showFeedback: $showFeedback');
    AppLogger.debug('   dragItems: ${widget.dragItems}');
    AppLogger.debug('   dropTargets: ${widget.dropTargets}');

    return QuizDragDropOptions(
      dragItems: widget.dragItems,
      dropTargets: widget.dropTargets,
      userAnswer: _localSubmittedAnswer,
      // Only pass correct matches when we should show feedback
      correctMatches: showFeedback ? widget.correctMatches : null,
      onAnswerSelected: _handleAnswerSelected,
      // hasAnswered controls whether to show feedback UI
      hasAnswered: showFeedback,
      enabled: isEnabled,
    );
  }
}
