import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/quiz.dart';
import 'package:quiz_app/CreateSection/services/quiz_cache_manager.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/CreateSection/widgets/quiz_saved_dialog.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/widgets/appbar/universal_appbar.dart';
import 'package:quiz_app/widgets/core/app_dialog.dart';

import '../models/question.dart';
import '../widgets/question_card/question_card.dart';
import '../widgets/question_navigation.dart';

class QuizQuestions extends StatefulWidget {
  final List<Question>? questions;
  final bool isStudySetMode;
  final Function(Quiz)? onSaveForStudySet;

  const QuizQuestions({
    super.key,
    this.questions,
    this.isStudySetMode = false,
    this.onSaveForStudySet,
  });
  @override
  State<QuizQuestions> createState() => _QuizQuestionsState();
}

class _QuizQuestionsState extends State<QuizQuestions> {
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  bool isNavigationExpanded = false;
  bool _isLocked = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    debugPrint('========================================');
    debugPrint('QuizQuestions initialized');
    debugPrint('isStudySetMode: ${widget.isStudySetMode}');
    debugPrint(
      'onSaveForStudySet callback: ${widget.onSaveForStudySet != null ? "PROVIDED" : "NULL"}',
    );
    debugPrint('========================================');

    if (widget.questions != null && widget.questions!.isNotEmpty) {
      questions = List.from(widget.questions!);
      _isLocked = true;
      currentQuestionIndex = 0;
    } else {
      _addNewQuestion();
    }
  }

  void _addNewQuestion() {
    setState(() {
      questions.add(
        Question(id: DateTime.now().millisecondsSinceEpoch.toString()),
      );
      currentQuestionIndex = questions.length - 1;
    });
  }

  void _updateQuestion(Question updatedQuestion) {
    int index = questions.indexWhere((q) => q.id == updatedQuestion.id);
    if (index != -1) {
      questions[index] = updatedQuestion;
    }
  }

  void _navigateToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      setState(() {
        currentQuestionIndex = index;
      });
    }
  }

  void _toggleNavigationMode() {
    setState(() {
      isNavigationExpanded = !isNavigationExpanded;
    });
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: _isSaving ? null : _saveQuiz,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isSaving
                ? AppColors.secondary.withValues(alpha: 0.6)
                : AppColors.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _isSaving
              ? SizedBox(
                  width: 40,
                  height: 20,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                )
              : Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UniversalAppBar(
        title: 'Create Quiz Questions',
        showNotificationBell: false,
        actions: [_buildSaveButton()],
      ),
      body: questions.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                key: ValueKey('emptyQuestionsLoadingIndicator'),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    key: ValueKey(
                      'question_${questions[currentQuestionIndex].id}',
                    ),
                    child: QuestionCard(
                      key: ValueKey(
                        'card_${questions[currentQuestionIndex].id}',
                      ),
                      question: questions[currentQuestionIndex],
                      onQuestionUpdated: _updateQuestion,
                      isLocked: _isLocked,
                    ),
                  ),
                ),
                QuestionNavigation(
                  currentIndex: currentQuestionIndex,
                  totalQuestions: questions.length,
                  onIndexChanged: _navigateToQuestion,
                  onAddQuestion: _addNewQuestion,
                  isExpanded: isNavigationExpanded,
                  onToggleExpanded: _toggleNavigationMode,
                  isLocked: _isLocked,
                ),
              ],
            ),
    );
  }

  Future<void> _saveQuiz() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    debugPrint('Starting _saveQuiz');
    try {
      // Update questions in cache
      debugPrint('Updating questions in cache');
      QuizCacheManager.instance.updateQuestions(questions);

      // Get the complete quiz from cache
      debugPrint('Retrieving quiz from cache');
      final quiz = QuizCacheManager.instance.currentQuiz;

      if (quiz == null) {
        throw Exception('No quiz details found');
      }

      // If in study set mode, add to study set cache and return
      if (widget.isStudySetMode && widget.onSaveForStudySet != null) {
        debugPrint('========================================');
        debugPrint('STUDY SET MODE DETECTED - NOT SAVING TO DATABASE');
        debugPrint('Adding quiz to study set cache only');
        debugPrint('========================================');

        widget.onSaveForStudySet!(quiz);
        QuizCacheManager.instance.clearCache();

        if (mounted) {
          // Show success dialog with custom QuizSavedDialog
          await QuizSavedDialog.show(
            context,
            title: 'Quiz Added!',
            message: 'Quiz has been added to your study set.',
            onDismiss: () async {
              debugPrint('Dialog dismissed, now popping navigation stack...');

              if (mounted) {
                // Pop back to dashboard with simple slide animation
                // Stack: ... -> Dashboard -> QuizDetails -> QuizQuestions (current)
                // Pop to Dashboard (2 screens back)
                int popCount = 0;
                Navigator.of(context).popUntil((route) {
                  return popCount++ >= 2 || route.isFirst;
                });
                debugPrint('Navigation complete - should be at Dashboard now');
              }
            },
          );
        }
        debugPrint('Returning early - database save will NOT execute');
        return;
      }

      debugPrint('========================================');
      debugPrint('STANDALONE MODE - SAVING TO DATABASE');
      debugPrint('========================================');

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated. Cannot save quiz.');
      }

      // Save to backend with timeout
      debugPrint('Saving quiz to backend');
      String quizId;

      // Call createQuiz() for new quiz
      quizId = await QuizService.createQuiz(quiz).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timed out'),
      );

      debugPrint('Quiz saved with ID: $quizId');

      // Show success dialog
      if (mounted) {
        await QuizSavedDialog.show(
          context,
          title: 'Success!',
          message: 'Your quiz has been saved successfully and is ready to use!',
          onDismiss: () async {
            debugPrint('Success dialog dismissed');
            QuizCacheManager.instance.clearCache();
            debugPrint('Cache cleared');
            if (mounted) {
              // Pop back to the Create page
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        );
        debugPrint('Success dialog shown');
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _saveQuiz: $e\n$stackTrace');
      setState(() {
        _isSaving = false;
      });
      // Show error dialog
      if (mounted) {
        await AppDialog.show(
          context: context,
          title: 'Error',
          content: 'Failed to save quiz: $e',
          primaryActionText: 'OK',
          primaryActionCallback: () {
            if (mounted) {
              Navigator.of(context).pop();
              debugPrint('Error dialog dismissed');
            }
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
