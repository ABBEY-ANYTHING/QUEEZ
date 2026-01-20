import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/question.dart';
import 'package:quiz_app/CreateSection/widgets/custom_text_field.dart';
import 'package:quiz_app/utils/color.dart';

class OptionItem extends StatelessWidget {
  final int index;
  final Question question;
  final TextEditingController controller;
  final ValueNotifier<int?> correctAnswerNotifier;
  final ValueNotifier<List<int>> multiCorrectAnswersNotifier;
  final Function(int) onCorrectAnswerSelected;
  final bool isLocked;

  const OptionItem({
    super.key,
    required this.index,
    required this.question,
    required this.controller,
    required this.correctAnswerNotifier,
    required this.multiCorrectAnswersNotifier,
    required this.onCorrectAnswerSelected,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: correctAnswerNotifier,
      builder: (context, singleCorrect, child) {
        return ValueListenableBuilder<List<int>>(
          valueListenable: multiCorrectAnswersNotifier,
          builder: (context, multiCorrect, child) {
            bool isCorrect = question.type == QuestionType.multiMcq
                ? multiCorrect.contains(index)
                : singleCorrect == index;
            bool isReadOnly =
                question.type == QuestionType.trueFalse || isLocked;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isCorrect
                    ? AppColors.success.withValues(alpha: 0.08)
                    : AppColors.background,
                border: Border.all(
                  color: isCorrect
                      ? AppColors.success
                      : AppColors.primaryLight.withValues(alpha: 0.3),
                  width: isCorrect ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildSelectionIndicator(isCorrect),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(
                        right: 16,
                        top: 8,
                        bottom: 8,
                      ),
                      child: isReadOnly
                          ? _buildReadOnlyOption()
                          : CustomTextField(
                              controller: controller,
                              hintText:
                                  'Option ${String.fromCharCode(65 + index)}',
                              enabled: !isLocked,
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSelectionIndicator(bool isCorrect) {
    return GestureDetector(
      onTap: isLocked ? null : () => onCorrectAnswerSelected(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: question.type == QuestionType.multiMcq
                ? BoxShape.rectangle
                : BoxShape.circle,
            borderRadius: question.type == QuestionType.multiMcq
                ? BorderRadius.circular(4)
                : null,
            color: isCorrect ? AppColors.success : Colors.transparent,
            border: Border.all(
              color: isCorrect ? AppColors.success : AppColors.iconInactive,
              width: 2,
            ),
          ),
          child: isCorrect
              ? const Icon(Icons.check, color: AppColors.white, size: 16)
              : null,
        ),
      ),
    );
  }

  Widget _buildReadOnlyOption() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: Text(
        question.options[index],
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
