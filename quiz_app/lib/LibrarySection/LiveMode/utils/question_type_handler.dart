import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/question.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/drag_drop_interface.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/multiple_choice_options.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/multi_select_options.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/true_false_options.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/utils/color.dart';

/// Utility class for handling different question types in live multiplayer quiz
/// Routes to appropriate UI component based on question type
class QuestionTypeHandler {
  /// Builds the appropriate question UI based on the question type
  ///
  /// Parameters:
  /// - [question]: The question data containing type and options
  /// - [onAnswerSelected]: Callback when user selects/submits an answer (receives index as int)
  /// - [onNextQuestion]: Callback for next question button (for multi-choice and drag-drop)
  /// - [hasAnswered]: Whether the user has already answered this question
  /// - [selectedAnswer]: The answer index the user selected (if any)
  /// - [isCorrect]: Whether the selected answer was correct (null if not yet revealed)
  /// - [correctAnswer]: The correct answer index (for display after submission)
  ///
  /// Returns the appropriate widget for the question type
  static Widget buildQuestionUI({
    required Map<String, dynamic> question,
    required Function(dynamic) onAnswerSelected,
    VoidCallback? onNextQuestion,
    required bool hasAnswered,
    dynamic selectedAnswer,
    bool? isCorrect,
    dynamic correctAnswer,
  }) {
    // Extract question type from the question data
    final String? typeString = question['type'] as String?;
    final QuestionType questionType = _parseQuestionType(typeString);

    // Extract options from question data
    final List<String> options = List<String>.from(question['options'] ?? []);

    // Build question type badge and content
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Type Badge
        _buildQuestionTypeBadge(questionType),
        const SizedBox(height: 16),
        
        // Question UI based on type
        _buildQuestionContent(
          questionType: questionType,
          question: question,
          options: options,
          onAnswerSelected: onAnswerSelected,
          onNextQuestion: onNextQuestion,
          hasAnswered: hasAnswered,
          selectedAnswer: selectedAnswer,
          isCorrect: isCorrect,
          correctAnswer: correctAnswer,
        ),
      ],
    );
  }

  static Widget _buildQuestionTypeBadge(QuestionType questionType) {
    String label;
    IconData icon;
    Color color;

    switch (questionType) {
      case QuestionType.singleMcq:
        label = 'Single Choice';
        icon = Icons.radio_button_checked;
        color = AppColors.primary;
        break;
      case QuestionType.multiMcq:
        label = 'Multiple Choice';
        icon = Icons.check_box;
        color = AppColors.secondary;
        break;
      case QuestionType.trueFalse:
        label = 'True/False';
        icon = Icons.toggle_on;
        color = AppColors.accentBright;
        break;
      case QuestionType.dragAndDrop:
        label = 'Drag & Drop';
        icon = Icons.swap_horiz;
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildQuestionContent({
    required QuestionType questionType,
    required Map<String, dynamic> question,
    required List<String> options,
    required Function(dynamic) onAnswerSelected,
    VoidCallback? onNextQuestion,
    required bool hasAnswered,
    dynamic selectedAnswer,
    bool? isCorrect,
    dynamic correctAnswer,
  }) {
    // Route to appropriate UI component based on question type
    switch (questionType) {
      case QuestionType.singleMcq:
        // Single choice questions - render all options as radio buttons
        // Parse selectedAnswer as int (backend may send as string)
        int? parsedSelectedAnswer;
        if (selectedAnswer != null) {
          parsedSelectedAnswer = selectedAnswer is int 
              ? selectedAnswer 
              : int.tryParse(selectedAnswer.toString());
        }
        
        return MultipleChoiceOptions(
          options: options,
          onSelect: (index) => onAnswerSelected(index),
          selectedAnswer: parsedSelectedAnswer,
          correctAnswer: correctAnswer?.toString(),
          hasAnswered: hasAnswered,
          isCorrect: isCorrect,
        );

      case QuestionType.multiMcq:
        // Multiple choice questions - render all options as checkboxes with submit button
        final List<int>? correctAnswersList = correctAnswer is List
            ? (correctAnswer).map((e) => e is int ? e : int.parse(e.toString())).toList()
            : null;
        final List<int>? selectedAnswersList = selectedAnswer is List
            ? (selectedAnswer).map((e) => e is int ? e : int.parse(e.toString())).toList()
            : null;
        
        return MultiSelectOptions(
          options: options,
          onSubmit: (indices) => onAnswerSelected(indices),
          onNextQuestion: onNextQuestion,
          selectedAnswers: selectedAnswersList,
          correctAnswers: correctAnswersList,
          hasAnswered: hasAnswered,
          isCorrect: isCorrect,
        );

      case QuestionType.trueFalse:
        // True/False questions - render exactly two buttons
        // Parse selectedAnswer and correctAnswer as int (backend may send as string)
        int? parsedSelectedAnswer;
        if (selectedAnswer != null) {
          parsedSelectedAnswer = selectedAnswer is int 
              ? selectedAnswer 
              : int.tryParse(selectedAnswer.toString());
        }
        
        return TrueFalseOptions(
          onSelect: (index) => onAnswerSelected(index),
          selectedAnswer: parsedSelectedAnswer,
          correctAnswer: int.tryParse(correctAnswer?.toString() ?? ''),
          hasAnswered: hasAnswered,
          isCorrect: isCorrect,
        );

      case QuestionType.dragAndDrop:
        // Drag and drop questions - render draggable items and drop targets
        final List<String> dragItems = List<String>.from(
          question['dragItems'] ?? [],
        );
        final List<String> dropTargets = List<String>.from(
          question['dropTargets'] ?? [],
        );
        final Map<String, String>? correctMatches = question['correctMatches'] != null
            ? Map<String, String>.from(question['correctMatches'])
            : null;
        
        AppLogger.debug('🎯 QuestionTypeHandler - DragAndDrop question data:');
        AppLogger.debug('   dragItems: $dragItems');
        AppLogger.debug('   dropTargets: $dropTargets');
        AppLogger.debug('   hasAnswered: $hasAnswered');
        AppLogger.debug('   correctMatches: $correctMatches');
        
        return DragDropInterface(
          dragItems: dragItems,
          dropTargets: dropTargets,
          onMatchSubmit: (matches) => onAnswerSelected(matches),
          hasAnswered: hasAnswered,
          isCorrect: isCorrect,
          correctMatches: correctMatches,
        );
    }
  }

  /// Parses a question type string into a QuestionType enum
  /// Returns singleMcq as default if type is null or unrecognized
  static QuestionType _parseQuestionType(String? typeString) {
    if (typeString == null) return QuestionType.singleMcq;

    switch (typeString.toLowerCase()) {
      case 'singlemcq':
      case 'single_mcq':
      case 'single':
        return QuestionType.singleMcq;

      case 'multimcq':
      case 'multi_mcq':
      case 'multiple':
        return QuestionType.multiMcq;

      case 'truefalse':
      case 'true_false':
      case 'true/false':
      case 'tf':
        return QuestionType.trueFalse;

      case 'draganddrop':
      case 'drag_and_drop':
      case 'drag&drop':
      case 'dragdrop':
        return QuestionType.dragAndDrop;

      default:
        // Default to single MCQ for unrecognized types
        return QuestionType.singleMcq;
    }
  }
}
