import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/CreateSection/widgets/quiz_saved_dialog.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_dashboard.dart';
import 'package:quiz_app/LibrarySection/screens/library_page.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';
import 'package:quiz_app/widgets/core/core_widgets.dart';

void showAddQuizModal(
  BuildContext context,
  Future<void> Function() onQuizAdded,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.primary.withValues(alpha: 0.3),
    builder: (context) => AddQuizModalContent(onQuizAdded: onQuizAdded),
  );
}

class AddQuizModalContent extends StatefulWidget {
  final Future<void> Function() onQuizAdded;

  const AddQuizModalContent({super.key, required this.onQuizAdded});

  @override
  State<AddQuizModalContent> createState() => _AddQuizModalContentState();
}

class _AddQuizModalContentState extends State<AddQuizModalContent> {
  final TextEditingController _quizCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _quizCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleAddQuiz() async {
    final quizCode = _quizCodeController.text.trim();

    if (quizCode.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a quiz code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Add quiz to user's library via service
      final result = await QuizService.addQuizToLibrary(userId, quizCode);

      if (!mounted) return;

      if (result['mode'] == 'live_multiplayer') {
        // For live multiplayer, open the dashboard without saving
        Navigator.pop(context); // Close the modal
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return PageTransition(
                animation: animation,
                animationType: AnimationType.slideUp,
                child: LiveMultiplayerDashboard(
                  quizId: result['quiz_id'],
                  sessionCode: quizCode,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      } else {
        // For self-paced and timed_individual, the quiz is saved
        final quizTitle = result['quiz_title'] ?? 'Quiz';

        // Close the modal first
        Navigator.pop(context);

        // Show success dialog (without auto-dismiss callback)
        final dialogContext = context;
        if (context.mounted) {
          // Show the dialog but don't wait for it
          QuizSavedDialog.show(
            dialogContext,
            title: 'Success!',
            message: 'Quiz "$quizTitle" has been added to your library!',
            onDismiss: () async {
              // This will be called when dialog auto-dismisses
            },
          );
        }

        // Reload quizzes from server in background
        await widget.onQuizAdded();

        // Sleep for half a second
        await Future.delayed(const Duration(milliseconds: 500));

        // Set the search query to the quiz title
        LibraryPage.setSearchQuery(quizTitle);
        if (context.mounted) {
          // Close the dialog after setting search
          if (Navigator.canPop(dialogContext)) {
            Navigator.of(dialogContext).pop();
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomPadding > 0 ? bottomPadding + 20 : safeAreaBottom + 100,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(QuizBorderRadius.xl),
            topRight: Radius.circular(QuizBorderRadius.xl),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(QuizSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(QuizBorderRadius.sm),
                  ),
                ),
              ),
              const SizedBox(height: QuizSpacing.lg),

              // Title
              const Text(
                'Add a quiz',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: QuizSpacing.sm),

              // Description
              Text(
                'Add a quiz made by other users',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: QuizSpacing.lg),

              // Text field
              TextField(
                controller: _quizCodeController,
                enabled: !_isLoading,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                onChanged: (value) {
                  // Capitalize the text as user types
                  final capitalizedValue = value.toUpperCase();
                  if (value != capitalizedValue) {
                    _quizCodeController.value = _quizCodeController.value
                        .copyWith(
                          text: capitalizedValue,
                          selection: TextSelection.collapsed(
                            offset: capitalizedValue.length,
                          ),
                        );
                  }

                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Enter quiz code',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: QuizSpacing.md,
                    vertical: QuizSpacing.md,
                  ),
                  errorText: _errorMessage,
                  errorStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                onSubmitted: (_) => _handleAddQuiz(),
              ),
              const SizedBox(height: QuizSpacing.lg),

              // Add button
              AppButton.primary(
                text: 'Add Quiz',
                onPressed: _handleAddQuiz,
                isLoading: _isLoading,
                fullWidth: true,
                size: AppButtonSize.large,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
