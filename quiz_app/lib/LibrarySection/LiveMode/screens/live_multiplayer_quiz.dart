import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_results.dart';
import 'package:quiz_app/LibrarySection/LiveMode/utils/question_type_handler.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/question_text_widget.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/reconnection_overlay.dart';
import 'package:quiz_app/providers/game_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/widgets/core/app_dialog.dart';

class LiveMultiplayerQuiz extends ConsumerStatefulWidget {
  const LiveMultiplayerQuiz({super.key});

  @override
  ConsumerState<LiveMultiplayerQuiz> createState() =>
      _LiveMultiplayerQuizState();
}

class _LiveMultiplayerQuizState extends ConsumerState<LiveMultiplayerQuiz>
    with SingleTickerProviderStateMixin {
  bool _hasNavigatedToResults = false;
  bool _isShowingHostEndedDialog = false;
  StreamSubscription<String>? _errorSubscription;

  // Streak toast state
  bool _showStreakToast = false;
  int _streakToastValue = 0;
  bool _isStreakLost = false;

  // Streak visual feedback state
  bool _streakGained = false;
  bool _streakLost = false;
  int _previousStreak = 0;

  // Animation controller for pulse effects
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Initialize pulse animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Subscribe to error stream once in initState, not on every build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _errorSubscription = ref
          .read(sessionProvider.notifier)
          .errorStream
          .listen((error) {
            if (mounted) {
              AppDialog.show(
                context: context,
                title: 'Error',
                content: error,
                primaryActionText: 'OK',
                primaryActionCallback: () => Navigator.pop(context),
              );
            }
          });
    });
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  /// Trigger visual feedback when streak is gained
  void _triggerStreakGain() {
    if (!mounted) return;
    setState(() => _streakGained = true);
    _pulseController.forward(from: 0).then((_) {
      if (mounted) setState(() => _streakGained = false);
    });
  }

  /// Trigger visual feedback when streak is lost
  void _triggerStreakLoss() {
    if (!mounted) return;
    setState(() => _streakLost = true);
    _pulseController.forward(from: 0).then((_) {
      if (mounted) setState(() => _streakLost = false);
    });
  }

  /// Show a modern streak notification toast
  void _showStreakNotification(int streak, bool isLost) {
    if (!mounted) return;

    setState(() {
      _showStreakToast = true;
      _streakToastValue = streak;
      _isStreakLost = isLost;
    });

    // Auto-hide after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showStreakToast = false;
        });
      }
    });
  }

  void _navigateToResults() {
    if (_hasNavigatedToResults) {
      debugPrint('🏁 QUIZ_SCREEN - Already navigated to results, skipping');
      return;
    }

    _hasNavigatedToResults = true;
    debugPrint('🏁 QUIZ_SCREEN - Navigating to results');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LiveMultiplayerResults()),
      );
    }
  }

  void _showHostEndedDialog() {
    if (_isShowingHostEndedDialog || _hasNavigatedToResults) return;
    _isShowingHostEndedDialog = true;

    debugPrint('🏁 QUIZ_SCREEN - Showing host ended dialog');

    AppDialog.show(
      context: context,
      title: 'Quiz Ended',
      content:
          'The host has ended the quiz. Tap below to see the final results!',
      primaryActionText: 'View Results',
      primaryActionCallback: () {
        Navigator.of(context).pop(); // Close dialog
        _navigateToResults();
      },
      dismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get user/host info early for all listeners
    final currentUserId = ref.watch(currentUserProvider);
    final sessionState = ref.watch(sessionProvider);
    final isHost = sessionState?.hostId == currentUserId;

    ref.listen(sessionProvider, (previous, next) {
      if (next != null && next.status == 'completed') {
        debugPrint(
          '🏁 QUIZ_SCREEN - Session completed, hostEnded: ${next.hostEndedQuiz}',
        );

        // If host manually ended AND we're not the host, show dialog
        if (next.hostEndedQuiz && !isHost) {
          _showHostEndedDialog();
        } else {
          // Natural completion or we are host - just navigate
          _navigateToResults();
        }
      }
    });

    ref.listen(gameProvider, (previous, next) {
      debugPrint(
        '🎮 UI - Game state changed, currentQuestion: ${next.currentQuestion != null ? "SET" : "NULL"}',
      );

      // Track streak changes for visual feedback
      if (next.streak > _previousStreak) {
        _triggerStreakGain();
      }
      _previousStreak = next.streak;

      // 🎯 Haptic feedback when answer result is received
      if (previous?.isCorrect == null && next.isCorrect != null) {
        if (next.isCorrect == true) {
          // Correct answer - satisfying medium impact
          HapticFeedback.mediumImpact();
          // Show streak toast for streak >= 2
          if (next.streak >= 2) {
            Future.delayed(const Duration(milliseconds: 100), () {
              HapticFeedback.lightImpact();
            });
            _showStreakNotification(next.streak, false);
          }
        } else {
          // Wrong answer - heavy impact
          HapticFeedback.heavyImpact();
          // Show streak lost if they had any streak before
          if ((previous?.streak ?? 0) >= 1) {
            _showStreakNotification(previous!.streak, true);
            _triggerStreakLoss();
          }
        }
      }

      // Check if quiz completed message received
      if (previous?.currentQuestion != null &&
          next.currentQuestion == null &&
          next.rankings != null &&
          next.rankings!.isNotEmpty) {
        debugPrint('🏁 QUIZ_SCREEN - Quiz completed message received');
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigateToResults();
        });
      }

      // Check if last question answered - navigate to results
      debugPrint(
        '🔍 LAST_Q_CHECK - hasAnswered: ${next.hasAnswered}, rankings: ${next.rankings != null ? "YES (${next.rankings!.length})" : "NULL"}, questionIndex: ${next.questionIndex}, totalQuestions: ${next.totalQuestions}, showingLeaderboard: ${next.showingLeaderboard}',
      );

      if (next.hasAnswered &&
          next.rankings != null &&
          next.rankings!.isNotEmpty &&
          next.questionIndex + 1 >= next.totalQuestions &&
          !next.showingLeaderboard) {
        debugPrint(
          '🏁 QUIZ_SCREEN - ✅ LAST QUESTION DETECTED! Navigating to results in 2s...',
        );
        debugPrint(
          '🏁 QUIZ_SCREEN - Details: index=${next.questionIndex}, total=${next.totalQuestions}, calc=${next.questionIndex + 1}',
        );
        Future.delayed(const Duration(milliseconds: 2000), () {
          debugPrint('🏁 QUIZ_SCREEN - NOW NAVIGATING TO RESULTS!');
          _navigateToResults();
        });
      }
    });

    // Error stream is now handled in initState to prevent memory leak

    final gameState = ref.watch(gameProvider);
    final currentQuestion = gameState.currentQuestion;
    debugPrint(
      '🎮 UI - Building with currentQuestion: ${currentQuestion != null ? "SET" : "NULL"}',
    );

    if (currentQuestion == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Loading question...',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ReconnectionOverlay(
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Clean compact header bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.5,
                            ),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Question counter
                            Text(
                              'Q ${gameState.questionIndex + 1}/${gameState.totalQuestions}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const Spacer(),

                            // Streak indicator with visual feedback
                            Builder(
                              builder: (context) {
                                final hasActiveStreak = gameState.streak >= 2;

                                // Determine glow color (orange for gain, red for loss)
                                Color? glowColor;
                                if (_streakGained) {
                                  glowColor = AppColors.warning; // Orange glow
                                } else if (_streakLost) {
                                  glowColor = AppColors.error;
                                }

                                return TweenAnimationBuilder<double>(
                                  key: ValueKey(
                                    'streak_${gameState.streak}_${_streakGained}_$_streakLost',
                                  ),
                                  duration: const Duration(milliseconds: 400),
                                  tween: Tween(
                                    begin: _streakGained
                                        ? 1.4
                                        : (_streakLost ? 0.8 : 1.0),
                                    end: 1.0,
                                  ),
                                  curve: _streakGained
                                      ? Curves.elasticOut
                                      : Curves.easeOutBack,
                                  builder: (context, scale, child) {
                                    return Transform.scale(
                                      scale: scale,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        curve: Curves.easeInOut,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  (glowColor ??
                                                          Colors.transparent)
                                                      .withValues(
                                                        alpha: glowColor != null
                                                            ? 0.6
                                                            : 0.0,
                                                      ),
                                              blurRadius: glowColor != null
                                                  ? 12
                                                  : 0,
                                              spreadRadius: glowColor != null
                                                  ? 2
                                                  : 0,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Always show Lottie fire animation
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Lottie.asset(
                                                'assets/animations/fire_streak.json',
                                                fit: BoxFit.contain,
                                                repeat: true,
                                                animate: true,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            AnimatedSwitcher(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              transitionBuilder:
                                                  (child, animation) {
                                                    return ScaleTransition(
                                                      scale: animation,
                                                      child: child,
                                                    );
                                                  },
                                              child: Text(
                                                '${gameState.streak}',
                                                key: ValueKey(gameState.streak),
                                                style: TextStyle(
                                                  color: _streakLost
                                                      ? AppColors.error
                                                      : (hasActiveStreak
                                                            ? AppColors.warning
                                                            : AppColors
                                                                  .textSecondary),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),

                            const SizedBox(width: 12),

                            // Timer badge
                            _buildCompactTimer(
                              gameState.timeRemaining,
                              gameState.timeLimit,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Secondary row: Ranks + Points (for participants)
                  if (!isHost)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Ranks button
                            GestureDetector(
                              onTap: () =>
                                  _showLeaderboardBottomSheet(context, ref),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  border: Border.all(
                                    color: AppColors.primaryLight,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.leaderboard_rounded,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Ranks',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Animated Points Badge
                            _buildPointsBadge(gameState),
                          ],
                        ),
                      ),
                    ),

                  // Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: Text(
                        currentQuestion['question'] ?? 'Match the capitals',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  // Question content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Question Text Widget (if there's an image)
                          if (currentQuestion['imageUrl'] != null)
                            QuestionTextWidget(
                              questionText: currentQuestion['question'] ?? '',
                              imageUrl: currentQuestion['imageUrl'],
                            ),
                          if (currentQuestion['imageUrl'] != null)
                            const SizedBox(height: 20),

                          // Question UI based on question type
                          QuestionTypeHandler.buildQuestionUI(
                            question: currentQuestion,
                            onAnswerSelected: (answer) {
                              debugPrint(
                                '🎮 QUIZ_SCREEN - Answer selected: $answer',
                              );
                              ref
                                  .read(gameProvider.notifier)
                                  .submitAnswer(answer);
                            },
                            onNextQuestion: () {
                              debugPrint(
                                '🎮 QUIZ_SCREEN - Next question requested',
                              );
                              ref
                                  .read(gameProvider.notifier)
                                  .requestNextQuestion();
                            },
                            hasAnswered: gameState.hasAnswered,
                            selectedAnswer: gameState.selectedAnswer,
                            isCorrect: gameState.isCorrect,
                            correctAnswer: gameState.correctAnswer,
                          ),

                          // Partial credit indicator
                          if (gameState.hasAnswered &&
                              gameState.isPartial &&
                              gameState.partialCredit != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF9800,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFF9800),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF9800),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.star_half,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Partial Credit',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFFF9800),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'You got ${gameState.partialCredit!.toStringAsFixed(0)}% of the answer correct',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '+${gameState.pointsEarned ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFFF9800),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Host controls section
                  if (isHost)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // Divider before host controls
                            Container(height: 1, color: Colors.grey.shade200),
                            const SizedBox(height: 16),

                            // Status message
                            if (gameState.hasAnswered &&
                                gameState.correctAnswer == null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  'Waiting for other players...',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                            // Next Question button (not on last question)
                            if (gameState.hasAnswered &&
                                gameState.rankings != null &&
                                gameState.questionIndex + 1 <
                                    gameState.totalQuestions)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ref
                                          .read(webSocketServiceProvider)
                                          .sendMessage('next_question', {});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'NEXT QUESTION',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            // End Quiz button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  AppDialog.show(
                                    context: context,
                                    title: 'End Quiz?',
                                    content:
                                        'Are you sure you want to end the quiz early? All progress will be saved.',
                                    secondaryActionText: 'CANCEL',
                                    secondaryActionCallback: () =>
                                        Navigator.pop(context),
                                    primaryActionText: 'END NOW',
                                    primaryActionCallback: () {
                                      Navigator.pop(context);
                                      ref
                                          .read(sessionProvider.notifier)
                                          .endQuiz();
                                    },
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFE53935),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'END QUIZ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE53935),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),

          // Streak Toast Notification
          if (_showStreakToast)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _isStreakLost
                          ? AppColors.textSecondary
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isStreakLost)
                          const Text('💔', style: TextStyle(fontSize: 18))
                        else
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: Lottie.asset(
                              'assets/animations/fire_streak.json',
                              fit: BoxFit.contain,
                              repeat: true,
                              animate: true,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _isStreakLost
                              ? 'Streak Lost!'
                              : '$_streakToastValue Streak!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!_isStreakLost && _streakToastValue >= 3) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '+${((_streakToastValue - 1) * 10).clamp(0, 50)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showLeaderboardBottomSheet(BuildContext context, WidgetRef ref) {
    ref.read(gameProvider.notifier).requestLeaderboard();
    debugPrint('🏆 QUIZ_SCREEN - Requested leaderboard, showing bottom sheet');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final gameState = ref.watch(gameProvider);
          ref.watch(currentUserProvider);
          final rankings = gameState.rankings ?? [];

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Live Leaderboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Leaderboard content
                Expanded(
                  child: rankings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Loading...',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: rankings.length,
                          itemBuilder: (context, index) {
                            final entry = rankings[index];
                            final rank = index + 1;
                            final answeredCount = entry['answered_count'] ?? 0;
                            final totalQuestions =
                                entry['total_questions'] ??
                                gameState.totalQuestions;
                            final score = entry['score'] ?? 0;
                            final username = entry['username'] ?? 'Unknown';

                            // Medal colors for top 3
                            Color? medalColor;
                            if (rank == 1) {
                              medalColor = const Color(0xFFFFD700); // Gold
                            } else if (rank == 2) {
                              medalColor = const Color(0xFFC0C0C0); // Silver
                            } else if (rank == 3) {
                              medalColor = const Color(0xFFCD7F32); // Bronze
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  // Rank badge
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          medalColor ?? AppColors.primaryLight,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$rank',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: medalColor != null
                                              ? AppColors.white
                                              : AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Username and progress
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          username,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          'Q$answeredCount/$totalQuestions',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Score
                                  Text(
                                    '$score',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Refresh button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(gameProvider.notifier).requestLeaderboard();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text(
                        'Refresh',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getPointsColor(double multiplier, bool isPartial) {
    if (isPartial) return const Color(0xFFFF9800); // Orange for partial credit
    if (multiplier >= 1.8) {
      return const Color(0xFFFFD700); // Gold for super fast
    }
    if (multiplier >= 1.5) return const Color(0xFF4CAF50); // Green for fast
    if (multiplier >= 1.2) return AppColors.primary; // Primary for good
    return const Color(0xFF2196F3); // Blue for normal
  }

  /// Build animated points badge
  Widget _buildPointsBadge(dynamic gameState) {
    return TweenAnimationBuilder<int>(
      key: ValueKey(gameState.currentScore),
      duration: const Duration(milliseconds: 800),
      tween: IntTween(
        begin: gameState.currentScore - (gameState.pointsEarned ?? 0),
        end: gameState.currentScore,
      ),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final isAnimating = value != gameState.currentScore;
        final pointsEarned = gameState.pointsEarned ?? 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Main points badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isAnimating && pointsEarned > 0
                    ? _getPointsColor(
                        gameState.multiplier ?? 1.0,
                        gameState.isPartial,
                      )
                    : const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isAnimating && pointsEarned > 0
                    ? [
                        BoxShadow(
                          color: _getPointsColor(
                            gameState.multiplier ?? 1.0,
                            gameState.isPartial,
                          ).withValues(alpha: 0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppColors.white,
                    size: isAnimating ? 18 : 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$value',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: isAnimating ? 16 : 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Floating +points animation
            if (isAnimating && pointsEarned > 0)
              Positioned(
                right: -8,
                top: -8,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1200),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOut,
                  builder: (context, progress, child) {
                    return Transform.translate(
                      offset: Offset(0, -progress * 25),
                      child: Opacity(
                        opacity: (1.0 - progress).clamp(0.0, 1.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPointsColor(
                              gameState.multiplier ?? 1.0,
                              gameState.isPartial,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _getPointsColor(
                                  gameState.multiplier ?? 1.0,
                                  gameState.isPartial,
                                ).withValues(alpha: 0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add,
                                color: AppColors.white,
                                size: 12,
                              ),
                              Text(
                                '$pointsEarned',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  /// Build compact timer badge for the unified header
  Widget _buildCompactTimer(int timeRemaining, int timeLimit) {
    final progress = timeLimit > 0 ? timeRemaining / timeLimit : 0.0;
    final isLowTime = timeRemaining <= 5;
    final isCriticalTime = timeRemaining <= 3;

    Color timerColor;
    if (isLowTime) {
      timerColor = AppColors.error; // Red from theme
    } else if (progress > 0.6) {
      timerColor = AppColors.success; // Green from theme
    } else if (progress > 0.3) {
      timerColor = AppColors.warning; // Amber from theme
    } else {
      timerColor = AppColors.error; // Red from theme
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey('timer_$timeRemaining'),
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: isCriticalTime ? 1.1 : 1.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: isCriticalTime ? scale : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: timerColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isCriticalTime
                  ? [
                      BoxShadow(
                        color: timerColor.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded, color: AppColors.white, size: 14),
                const SizedBox(width: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    '${timeRemaining}s',
                    key: ValueKey(timeRemaining),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
