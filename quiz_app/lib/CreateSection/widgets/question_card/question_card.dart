import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/question.dart';
import 'package:quiz_app/CreateSection/widgets/custom_text_field.dart';
import 'package:quiz_app/utils/color.dart';

import '../../mixins/animation_mixin.dart';
import '../custom_dropdown.dart';
import 'question_content_builder.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final Function(Question) onQuestionUpdated;
  final bool isLocked;

  const QuestionCard({
    super.key,
    required this.question,
    required this.onQuestionUpdated,
    this.isLocked = false,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard>
    with TickerProviderStateMixin, QuestionCardAnimationMixin {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late List<TextEditingController> _dragItemControllers;
  late List<TextEditingController> _dropTargetControllers;

  late ValueNotifier<int?> _correctAnswerNotifier;
  late ValueNotifier<List<int>> _multiCorrectAnswersNotifier;

  @override
  void initState() {
    super.initState();
    _correctAnswerNotifier = ValueNotifier<int?>(
      widget.question.correctAnswerIndex,
    );
    _multiCorrectAnswersNotifier = ValueNotifier<List<int>>(
      widget.question.correctAnswerIndices ?? [],
    );
    _initializeControllers();
    initializeAnimations();
  }

  void _initializeControllers() {
    _questionController = TextEditingController(
      text: widget.question.questionText,
    );

    _optionControllers = widget.question.options
        .map((option) => TextEditingController(text: option))
        .toList();

    _dragItemControllers = (widget.question.dragItems ?? [])
        .map((item) => TextEditingController(text: item))
        .toList();

    _dropTargetControllers = (widget.question.dropTargets ?? [])
        .map((target) => TextEditingController(text: target))
        .toList();

    _addListeners();
  }

  void _addListeners() {
    _questionController.addListener(_updateQuestion);
    for (var controller in _optionControllers) {
      controller.addListener(_updateQuestion);
    }
    for (var controller in _dragItemControllers) {
      controller.addListener(_updateDragDropQuestion);
    }
    for (var controller in _dropTargetControllers) {
      controller.addListener(_updateDragDropQuestion);
    }
  }

  void _updateQuestion() {
    widget.question.questionText = _questionController.text;
    widget.question.options = _optionControllers.map((c) => c.text).toList();
    widget.onQuestionUpdated(widget.question);
  }

  void _updateDragDropQuestion() {
    widget.question.dragItems = _dragItemControllers
        .map((c) => c.text)
        .toList();
    widget.question.dropTargets = _dropTargetControllers
        .map((c) => c.text)
        .toList();

    // Build correctMatches map based on index matching
    // dragItems[0] matches dropTargets[0], dragItems[1] matches dropTargets[1], etc.
    final correctMatches = <String, String>{};
    final minLength =
        widget.question.dragItems!.length < widget.question.dropTargets!.length
        ? widget.question.dragItems!.length
        : widget.question.dropTargets!.length;

    for (int i = 0; i < minLength; i++) {
      final dragItem = widget.question.dragItems![i].trim();
      final dropTarget = widget.question.dropTargets![i].trim();
      if (dragItem.isNotEmpty && dropTarget.isNotEmpty) {
        correctMatches[dragItem] = dropTarget;
      }
    }

    widget.question.correctMatches = correctMatches;
    widget.onQuestionUpdated(widget.question);
  }

  void _selectCorrectAnswer(int index) {
    if (widget.question.type == QuestionType.multiMcq) {
      List<int> currentAnswers = List.from(_multiCorrectAnswersNotifier.value);
      if (currentAnswers.contains(index)) {
        currentAnswers.remove(index);
      } else {
        currentAnswers.add(index);
      }
      widget.question.correctAnswerIndices = currentAnswers;
      _multiCorrectAnswersNotifier.value = currentAnswers;
    } else {
      widget.question.correctAnswerIndex = index;
      _correctAnswerNotifier.value = index;
    }
    widget.onQuestionUpdated(widget.question);
  }

  void _changeQuestionType(String? typeString) {
    if (typeString == null) return;

    QuestionType newType = Question.typeFromString(typeString);
    setState(() {
      widget.question.type = newType;
      widget.question.correctAnswerIndex = null;
      widget.question.correctAnswerIndices = null;
      _correctAnswerNotifier.value = null;
      _multiCorrectAnswersNotifier.value = [];

      _disposeOptionControllers();
      _resetQuestionData(newType);
      _reinitializeControllers(newType);
    });
    widget.onQuestionUpdated(widget.question);
  }

  void _disposeOptionControllers() {
    for (var controller in _optionControllers) {
      controller.removeListener(_updateQuestion);
      controller.dispose();
    }
  }

  void _resetQuestionData(QuestionType newType) {
    switch (newType) {
      case QuestionType.trueFalse:
        widget.question.options = ['True', 'False'];
        break;
      case QuestionType.dragAndDrop:
        widget.question.options = [];
        widget.question.dragItems = ['', ''];
        widget.question.dropTargets = ['', ''];
        widget.question.correctMatches = {};
        _initializeDragDropControllers();
        break;
      default:
        widget.question.options = ['', '', '', ''];
    }
  }

  void _reinitializeControllers(QuestionType newType) {
    if (newType != QuestionType.dragAndDrop) {
      _optionControllers = widget.question.options
          .map((option) => TextEditingController(text: option))
          .toList();
      for (var controller in _optionControllers) {
        controller.addListener(_updateQuestion);
      }
    }
  }

  void _initializeDragDropControllers() {
    _disposeDragDropControllers();

    _dragItemControllers = (widget.question.dragItems ?? [])
        .map((item) => TextEditingController(text: item))
        .toList();

    _dropTargetControllers = (widget.question.dropTargets ?? [])
        .map((target) => TextEditingController(text: target))
        .toList();

    for (var controller in _dragItemControllers) {
      controller.addListener(_updateDragDropQuestion);
    }
    for (var controller in _dropTargetControllers) {
      controller.addListener(_updateDragDropQuestion);
    }
  }

  void _disposeDragDropControllers() {
    for (var controller in _dragItemControllers) {
      controller.dispose();
    }
    for (var controller in _dropTargetControllers) {
      controller.dispose();
    }
  }

  void _addDragDropPair() {
    setState(() {
      _dragItemControllers.add(TextEditingController());
      _dragItemControllers.last.addListener(_updateDragDropQuestion);

      _dropTargetControllers.add(TextEditingController());
      _dropTargetControllers.last.addListener(_updateDragDropQuestion);

      widget.question.dragItems = widget.question.dragItems ?? [];
      widget.question.dropTargets = widget.question.dropTargets ?? [];
      widget.question.dragItems!.add('');
      widget.question.dropTargets!.add('');
    });
    widget.onQuestionUpdated(widget.question);
  }

  void _removeDragDropPair() {
    if (_dragItemControllers.length > 1 && _dropTargetControllers.length > 1) {
      setState(() {
        if (_dragItemControllers.isNotEmpty) {
          _dragItemControllers.last.dispose();
          _dragItemControllers.removeLast();
          widget.question.dragItems?.removeLast();
        }

        if (_dropTargetControllers.isNotEmpty) {
          _dropTargetControllers.last.dispose();
          _dropTargetControllers.removeLast();
          widget.question.dropTargets?.removeLast();
        }
      });
      widget.onQuestionUpdated(widget.question);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuestionTypeSection(),
                        const SizedBox(height: 32),
                        _buildQuestionTextSection(),
                        const SizedBox(height: 32),
                        _buildQuestionContent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        CustomDropdown(
          value: widget.question.typeString,
          items: const [
            'Single Choice',
            'Multiple Choice',
            'True/False',
            'Drag & Drop',
          ],
          hintText: 'Select question type',
          onChanged: widget.isLocked ? null : _changeQuestionType,
          enabled: !widget.isLocked,
        ),
      ],
    );
  }

  Widget _buildQuestionTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Question',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _questionController,
          hintText: 'Enter your question here...',
          maxLines: 3,
          enabled: !widget.isLocked,
        ),
      ],
    );
  }

  Widget _buildQuestionContent() {
    return QuestionContentBuilder(
      question: widget.question,
      optionControllers: _optionControllers,
      dragItemControllers: _dragItemControllers,
      dropTargetControllers: _dropTargetControllers,
      correctAnswerNotifier: _correctAnswerNotifier,
      multiCorrectAnswersNotifier: _multiCorrectAnswersNotifier,
      onCorrectAnswerSelected: _selectCorrectAnswer,
      onAddDragDropPair: _addDragDropPair,
      onRemoveDragDropPair: _removeDragDropPair,
      isLocked: widget.isLocked,
    );
  }

  @override
  void dispose() {
    _disposeControllers();
    _correctAnswerNotifier.dispose();
    _multiCorrectAnswersNotifier.dispose();
    disposeAnimations();
    super.dispose();
  }

  void _disposeControllers() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    for (var controller in _dragItemControllers) {
      controller.dispose();
    }
    for (var controller in _dropTargetControllers) {
      controller.dispose();
    }
  }
}
