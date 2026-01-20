import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/question.dart';
import 'package:quiz_app/utils/color.dart';

import 'drag_drop_content.dart';
import 'option_item.dart';

class QuestionContentBuilder extends StatelessWidget {
  final Question question;
  final List<TextEditingController> optionControllers;
  final List<TextEditingController> dragItemControllers;
  final List<TextEditingController> dropTargetControllers;
  final ValueNotifier<int?> correctAnswerNotifier;
  final ValueNotifier<List<int>> multiCorrectAnswersNotifier;
  final Function(int) onCorrectAnswerSelected;
  final VoidCallback onAddDragDropPair;
  final VoidCallback onRemoveDragDropPair;
  final bool isLocked;

  const QuestionContentBuilder({
    super.key,
    required this.question,
    required this.optionControllers,
    required this.dragItemControllers,
    required this.dropTargetControllers,
    required this.correctAnswerNotifier,
    required this.multiCorrectAnswersNotifier,
    required this.onCorrectAnswerSelected,
    required this.onAddDragDropPair,
    required this.onRemoveDragDropPair,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case QuestionType.dragAndDrop:
        return DragDropContent(
          dragItemControllers: dragItemControllers,
          dropTargetControllers: dropTargetControllers,
          onAddPair: onAddDragDropPair,
          onRemovePair: onRemoveDragDropPair,
          isLocked: isLocked,
        );
      default:
        return _buildOptionsContent();
    }
  }

  Widget _buildOptionsContent() {
    String instructionText = question.type == QuestionType.multiMcq
        ? 'Click multiple circles to mark correct answers'
        : 'Click the circle to mark the correct answer';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Answer Options',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          instructionText,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          question.options.length,
          (index) => OptionItem(
            index: index,
            question: question,
            controller: optionControllers[index],
            correctAnswerNotifier: correctAnswerNotifier,
            multiCorrectAnswersNotifier: multiCorrectAnswersNotifier,
            onCorrectAnswerSelected: onCorrectAnswerSelected,
            isLocked: isLocked,
          ),
        ),
      ],
    );
  }
}
