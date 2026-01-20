import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/CreateSection/widgets/quiz_saved_dialog.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_dashboard.dart';
import 'package:quiz_app/providers/library_provider.dart';
import 'package:quiz_app/providers/library_search_provider.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/app_logger.dart';
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
    builder: (context) => const AddQuizModalContent(),
  );
}

class AddQuizModalContent extends ConsumerStatefulWidget {
  const AddQuizModalContent({super.key});

  @override
  ConsumerState<AddQuizModalContent> createState() =>
      _AddQuizModalContentState();
}

class _AddQuizModalContentState extends ConsumerState<AddQuizModalContent> {
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
    AppLogger.info('_handleAddQuiz called with code: $quizCode');

    if (quizCode.isEmpty) {
      AppLogger.warning('Quiz code is empty, showing error');
      setState(() {
        _errorMessage = 'Please enter a quiz code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    AppLogger.info('Set loading state to true');

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      AppLogger.debug('Current user ID: $userId');

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Add quiz to user's library via service
      AppLogger.info('Calling QuizService.addQuizToLibrary...');
      final result = await QuizService.addQuizToLibrary(userId, quizCode);
      AppLogger.success('QuizService.addQuizToLibrary returned: $result');

      if (!mounted) {
        AppLogger.warning('Widget not mounted after API call, returning');
        return;
      }

      AppLogger.debug('Result mode: ${result['mode']}');

      if (result['mode'] == 'live_multiplayer') {
        AppLogger.info('Live multiplayer mode - navigating to dashboard');
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
        AppLogger.success('Quiz added successfully! Title: $quizTitle');
        AppLogger.debug('Full result details: ${result['quiz_details']}');

        // Store the navigator and overlay context before closing
        final navigator = Navigator.of(context);
        final overlayContext = Overlay.of(context).context;
        AppLogger.debug('Stored navigator and overlay context');

        // Close the modal first
        AppLogger.info('Closing modal...');
        navigator.pop();

        // Show success dialog using the main navigator's context
        if (overlayContext.mounted) {
          AppLogger.info('Showing success dialog...');
          QuizSavedDialog.show(
            overlayContext,
            title: 'Success!',
            message: 'Quiz "$quizTitle" has been added to your library!',
            onDismiss: () async {
              AppLogger.info('Success dialog dismissed');
            },
          );
        } else {
          AppLogger.warning('Overlay context not mounted, cannot show dialog');
        }

        // Invalidate the library provider to trigger a reload
        AppLogger.info('Invalidating quizLibraryProvider...');
        ref.invalidate(quizLibraryProvider);
        AppLogger.success('quizLibraryProvider invalidated');

        // Wait for the provider to rebuild with fresh data
        AppLogger.info('Waiting 300ms for provider to rebuild...');
        await Future.delayed(const Duration(milliseconds: 300));
        AppLogger.success('Wait complete, setting search query');

        // Set the search query to the quiz title so it appears in results
        AppLogger.info('Setting search query to "$quizTitle"...');
        ref.read(librarySearchQueryProvider.notifier).setQuery(quizTitle);
        AppLogger.success('Search query set');

        // Close the dialog after a short delay
        AppLogger.info('Waiting 1500ms before closing dialog...');
        await Future.delayed(const Duration(milliseconds: 1500));
        if (overlayContext.mounted) {
          if (navigator.canPop()) {
            AppLogger.info('Closing success dialog...');
            navigator.pop();
          } else {
            AppLogger.warning('Navigator cannot pop');
          }
        } else {
          AppLogger.warning('Overlay context not mounted after delay');
        }
        AppLogger.success('_handleAddQuiz completed successfully');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'ERROR in _handleAddQuiz',
        exception: e,
        stackTrace: stackTrace,
      );
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(QuizBorderRadius.xl),
          topRight: Radius.circular(QuizBorderRadius.xl),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          QuizSpacing.lg,
          QuizSpacing.lg,
          QuizSpacing.lg,
          bottomPadding > 0 ? bottomPadding + QuizSpacing.lg : 120,
        ),
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
              size: AppButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}
