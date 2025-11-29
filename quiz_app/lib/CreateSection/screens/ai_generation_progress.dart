import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:quiz_app/CreateSection/providers/ai_study_set_provider.dart';
import 'package:quiz_app/CreateSection/services/study_set_service.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/CreateSection/widgets/quiz_saved_dialog.dart';
import 'package:quiz_app/providers/library_provider.dart';
import 'package:quiz_app/utils/globals.dart';

class AIGenerationProgress extends ConsumerStatefulWidget {
  const AIGenerationProgress({super.key});

  @override
  ConsumerState<AIGenerationProgress> createState() =>
      _AIGenerationProgressState();
}

class _AIGenerationProgressState extends ConsumerState<AIGenerationProgress> {
  @override
  void initState() {
    super.initState();
    // Start generation when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGeneration();
    });
  }

  Future<void> _startGeneration() async {
    final notifier = ref.read(aiStudySetProvider.notifier);

    try {
      debugPrint('=== STARTING AI GENERATION ===');

      // Generate the study set (this includes upload progress internally)
      final studySet = await notifier.generateStudySet();

      debugPrint('=== GENERATION COMPLETE ===');
      debugPrint('Study set ID: ${studySet.id}');
      debugPrint('Study set name: ${studySet.name}');
      debugPrint('Quizzes: ${studySet.quizzes.length}');
      debugPrint('Flashcard sets: ${studySet.flashcardSets.length}');
      debugPrint('Notes: ${studySet.notes.length}');

      if (!mounted) return;

      // Save to database
      try {
        debugPrint('=== SAVING TO DATABASE ===');
        await StudySetService.saveStudySet(studySet);
        debugPrint('=== SAVE SUCCESSFUL ===');
      } catch (saveError) {
        debugPrint('=== SAVE ERROR: $saveError ===');
        // Show error but don't fail the whole process
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Save Error'),
            content: Text('Study set generated but failed to save: $saveError'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Show success dialog
      await QuizSavedDialog.show(
        context,
        title: 'Study Set Generated!',
        message:
            'Your AI-powered study set has been created and saved successfully.',
        onDismiss: () async {
          if (mounted) {
            // Trigger library reload FIRST using the provider directly
            await ref.read(quizLibraryProvider.notifier).reload();

            // Pop back to create page
            Navigator.of(context).popUntil((route) => route.isFirst);

            // Switch to library tab (index 1)
            bottomNavbarKey.currentState?.setIndex(1);
          }
        },
      );

      // Reset provider
      notifier.reset();
    } catch (e) {
      if (!mounted) return;

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              const Text('Generation Failed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'An error occurred while generating your study set:',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Text(
                  e.toString().replaceAll('Exception: ', ''),
                  style: TextStyle(fontSize: 13, color: Colors.red.shade700),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to config
              },
              child: const Text('Go Back'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _startGeneration(); // Retry
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiStudySetProvider);

    return PopScope(
      canPop: !state.isGenerating,
      onPopInvokedWithResult: (didPop, result) async {
        // If already popped or not generating, do nothing
        if (didPop || !state.isGenerating) return;

        // Show confirmation dialog
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancel Generation?'),
            content: const Text(
              'Are you sure you want to cancel? Your progress will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Continue Generating'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );

        if (shouldExit == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Generating Your Study Set',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Lottie loading animation
                    Lottie.asset(
                      'assets/animations/loading.json',
                      width: 200,
                      height: 200,
                      repeat: true,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.auto_awesome,
                          size: 100,
                          color: AppColors.primary.withOpacity(0.5),
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: state.progress / 100,
                        minHeight: 12,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Progress percentage
                    Text(
                      '${state.progress.toInt()}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Status text
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.hourglass_empty,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              state.currentStep.isEmpty
                                  ? 'Initializing...'
                                  : state.currentStep,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Fun tip
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.amber.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'AI is analyzing your documents and creating personalized study materials just for you!',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
