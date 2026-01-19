import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/LibrarySection/PlaySection/models/quiz_attempt.dart';
import 'package:quiz_app/LibrarySection/PlaySection/screens/quiz_play_screen.dart';
import 'package:quiz_app/LibrarySection/screens/library_page.dart';
import 'package:quiz_app/LibrarySection/widgets/quiz_library_item.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/globals.dart';

class QuizResultsScreen extends StatefulWidget {
  final QuizLibraryItem quizItem;
  final QuizAttempt quizAttempt;

  const QuizResultsScreen({
    super.key,
    required this.quizItem,
    required this.quizAttempt,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  @override
  void initState() {
    super.initState();
    _handlePostQuizActions();
  }

  Future<void> _handlePostQuizActions() async {
    final isRestrictiveMode =
        widget.quizItem.sharedMode == 'self_paced' ||
        widget.quizItem.sharedMode == 'timed_individual';

    if (isRestrictiveMode) {
      try {
        await QuizService.deleteQuiz(widget.quizItem.id);
        // No need to show a snackbar, it's expected behavior.
      } catch (e) {
        // Optionally handle error if deletion fails
        AppLogger.error("Failed to delete quiz from library: $e");
      }
    }
  }

  void _goHome() {
    // Reload library to reflect potential deletion
    LibraryPage.reloadItems();
    // Pop until we are at the root of the navigator (Dashboard)
    Navigator.of(context).popUntil((route) => route.isFirst);
    // Switch to library tab
    bottomNavbarKey.currentState?.setIndex(1);
  }

  void _replayQuiz() {
    Navigator.of(context).pushReplacement(
      customRoute(
        QuizPlayScreen(quizItem: widget.quizItem),
        AnimationType.fade,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.quizAttempt.score;
    final total = widget.quizAttempt.questions.length;
    final percentage = total > 0 ? (score / total) * 100 : 0.0;

    final bool showReplayButton =
        widget.quizItem.sharedMode == 'share' ||
        widget.quizItem.sharedMode == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Quiz Complete!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.quizItem.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primaryLighter, width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'YOUR SCORE',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score out of $total correct',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              if (showReplayButton)
                ElevatedButton.icon(
                  onPressed: _replayQuiz,
                  icon: const Icon(Icons.replay, color: Colors.white),
                  label: const Text('Replay Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              if (showReplayButton) const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _goHome,
                icon: const Icon(Icons.home_rounded),
                label: const Text('Back to Home'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
