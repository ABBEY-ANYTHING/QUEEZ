import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/multiplayer_models.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/services/websocket_service.dart';
import 'package:quiz_app/utils/app_logger.dart';

final gameProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);

class GameNotifier extends Notifier<GameState> {
  late final WebSocketService _wsService;
  Timer? _timer;
  DateTime? _questionStartTime; // Track when question was received for scoring

  @override
  GameState build() {
    _wsService = ref.watch(webSocketServiceProvider);
    _wsService.messageStream.listen((message) {
      _handleMessage(message);
    });

    ref.onDispose(() {
      _stopTimer();
    });

    return const GameState();
  }

  void setTimeSettings(int perQuestionTimeLimit) {
    AppLogger.debug(
      'GAME_PROVIDER - Setting time: perQuestion=${perQuestionTimeLimit}s',
    );
    state = state.copyWith(timeLimit: perQuestionTimeLimit);
  }

  void _onQuestionTimeout() {
    AppLogger.warning('GAME_PROVIDER - Question time expired!');

    if (state.hasAnswered) {
      AppLogger.debug(
        'GAME_PROVIDER - Already answered, skipping timeout handling',
      );
      return;
    }

    // Auto-submit with no answer (will be marked wrong)
    AppLogger.warning('GAME_PROVIDER - Auto-submitting due to timeout');
    _wsService.sendMessage('submit_answer', {
      'answer': null, // No answer - timeout
      'timestamp': state.timeLimit.toDouble(), // Full time elapsed
      'timeout': true,
    });

    state = state.copyWith(hasAnswered: true);
  }

  void submitAnswer(dynamic answer) {
    if (state.hasAnswered) {
      AppLogger.warning('GAME_PROVIDER - Already answered, ignoring');
      return;
    }

    // Calculate elapsed time since question was shown
    double elapsedSeconds = 0;
    if (_questionStartTime != null) {
      elapsedSeconds =
          DateTime.now().difference(_questionStartTime!).inMilliseconds /
          1000.0;
    }

    AppLogger.debug('GAME_PROVIDER - Submitting answer: $answer');
    AppLogger.debug('Elapsed time: ${elapsedSeconds.toStringAsFixed(2)}s');

    _wsService.sendMessage('submit_answer', {
      'answer': answer,
      'timestamp': elapsedSeconds, // Send elapsed time, not absolute timestamp
    });

    // Only mark as answered, don't set selectedAnswer yet (wait for backend response)
    state = state.copyWith(hasAnswered: true);
    AppLogger.success('GAME_PROVIDER - Answer submitted, hasAnswered=true');
  }

  void showLeaderboard() {
    AppLogger.debug('GAME_PROVIDER - Showing leaderboard popup');
    state = state.copyWith(showingLeaderboard: true);
  }

  void hideLeaderboard() {
    AppLogger.debug('GAME_PROVIDER - Hiding leaderboard popup');
    state = state.copyWith(showingLeaderboard: false);
  }

  void requestNextQuestion() {
    AppLogger.debug('GAME_PROVIDER - Requesting next question from backend');
    // Send request to backend for next question
    _wsService.sendMessage('request_next_question', {});
    // DON'T reset state here - let it reset when new question arrives
    // This prevents the flash of old answers before new question loads
    AppLogger.debug('GAME_PROVIDER - Request sent, waiting for new question');
  }

  void requestLeaderboard() {
    AppLogger.debug('GAME_PROVIDER - Requesting leaderboard');
    _wsService.sendMessage('request_leaderboard', {});
  }

  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type'];
    final payload = message['payload'];

    if (type == 'question') {
      // New question received - start tracking time for scoring
      AppLogger.debug('Processing new question');

      // Get per-question time limit
      final questionTimeLimit =
          payload['time_limit'] ?? payload['time_remaining'] ?? state.timeLimit;

      _questionStartTime = DateTime.now(); // Start timing for score calculation

      _startTimer(payload['time_remaining'] ?? questionTimeLimit);
      state = state.copyWith(
        currentQuestion: payload['question'],
        questionIndex: payload['index'],
        totalQuestions: payload['total'],
        timeRemaining: payload['time_remaining'] ?? questionTimeLimit,
        timeLimit: questionTimeLimit,
        hasAnswered: false,
        selectedAnswer: null,
        isCorrect: null,
        correctAnswer: null,
        pointsEarned: null,
        timeBonus: null,
        multiplier: null,
        // DON'T reset rankings - keep the leaderboard visible for host
        // rankings: null,
        showingLeaderboard: false,
      );
    } else if (type == 'answer_result') {
      // Handle answer result - update state with user's answer and correctness
      final isCorrect = payload['is_correct'] as bool? ?? false;
      final points = payload['points'] as int? ?? 0;
      final timeBonus = payload['time_bonus'] as int? ?? 0;
      final multiplier = (payload['multiplier'] as num?)?.toDouble() ?? 1.0;
      final correctAnswer = payload['correct_answer'];
      final newScore = payload['new_total_score'] as int? ?? state.currentScore;
      final questionType = payload['question_type'] as String?;
      final isPartial = payload['is_partial'] as bool? ?? false;
      final partialCredit = (payload['partial_credit'] as num?)?.toDouble();
      final streak = payload['streak'] as int? ?? 0;
      final streakBonus = payload['streak_bonus'] as int? ?? 0;

      // Get the user's submitted answer from the payload if available
      final userAnswer = payload['user_answer'];

      if (!isPartial) {
        AppLogger.info(
          'Answer: ${isCorrect ? "CORRECT" : "INCORRECT"} | +$points pts',
        );
      }

      state = state.copyWith(
        isCorrect: isCorrect,
        correctAnswer: correctAnswer,
        selectedAnswer: userAnswer,
        pointsEarned: points,
        timeBonus: timeBonus,
        multiplier: multiplier,
        currentScore: newScore,
        isPartial: isPartial,
        partialCredit: partialCredit,
        streak: streak,
        streakBonus: streakBonus,
      );

      // Auto-advance for single choice, true/false, and multi-select after delay
      // Reduced delays for faster gameplay (matching single player's 800ms)
      if (questionType == 'singleMcq' || questionType == 'trueFalse') {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (state.hasAnswered && state.correctAnswer != null) {
            requestNextQuestion();
          }
        });
      } else if (questionType == 'multiMcq') {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (state.hasAnswered && state.correctAnswer != null) {
            requestNextQuestion();
          }
        });
      } else if (questionType == 'dragAndDrop') {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (state.hasAnswered && state.correctAnswer != null) {
            requestNextQuestion();
          }
        });
      }
    } else if (type == 'answer_feedback') {
      // Handle answer feedback message for participants (alternative message type)
      final isCorrect = payload['is_correct'] as bool? ?? false;
      final pointsEarned = payload['points_earned'] as int? ?? 0;
      final correctAnswer = payload['correct_answer'];
      final yourScore = payload['your_score'] as int? ?? state.currentScore;
      final answerDistribution = payload['answer_distribution'] != null
          ? Map<dynamic, int>.from(payload['answer_distribution'])
          : null;

      state = state.copyWith(
        lastAnswerCorrect: isCorrect,
        isCorrect: isCorrect,
        pointsEarned: pointsEarned,
        correctAnswer: correctAnswer,
        currentScore: yourScore,
        answerDistribution: answerDistribution,
      );
    } else if (type == 'leaderboard_update') {
      // Update leaderboard - POPUP DISABLED, just update rankings
      final leaderboard = payload['leaderboard'];
      AppLogger.info('Leaderboard updated with scores');

      if (leaderboard != null) {
        final rankings = leaderboard is List
            ? List<Map<String, dynamic>>.from(
                leaderboard.map((item) => Map<String, dynamic>.from(item)),
              )
            : null;

        if (rankings != null) {
          // Update rankings but DON'T show popup (disabled for now)
          state = state.copyWith(
            rankings: rankings,
            showingLeaderboard: false, // DISABLED
          );
        }
      }
    } else if (type == 'answer_reveal') {
      // Host reveals answer and shows rankings
      _stopTimer();

      final correctAnswer = payload['correct_answer'];
      final rankings = payload['rankings'] != null
          ? List<Map<String, dynamic>>.from(
              payload['rankings'].map(
                (item) => Map<String, dynamic>.from(item),
              ),
            )
          : null;

      state = state.copyWith(correctAnswer: correctAnswer, rankings: rankings);
    } else if (type == 'quiz_started') {
      // Quiz started - set time settings
      final perQuestionTimeLimit =
          payload['per_question_time_limit'] as int? ?? 30;
      AppLogger.info(
        'Quiz started: $perQuestionTimeLimit seconds per question',
      );

      setTimeSettings(perQuestionTimeLimit);
    } else if (type == 'quiz_completed' || type == 'quiz_ended') {
      // Quiz finished
      AppLogger.success('Quiz completed');
      _stopTimer();

      final finalRankings = payload['final_rankings'] ?? payload['results'];
      if (finalRankings != null) {
        final rankings = List<Map<String, dynamic>>.from(
          finalRankings.map((item) => Map<String, dynamic>.from(item)),
        );
        AppLogger.success('Quiz completed: ${rankings.length} final rankings');
        state = state.copyWith(rankings: rankings);
      }
    } else if (type == 'leaderboard_response') {
      // Real-time leaderboard response
      AppLogger.info('Real-time leaderboard updated');
      final leaderboard = payload['leaderboard'];

      if (leaderboard != null) {
        final rankings = List<Map<String, dynamic>>.from(
          leaderboard.map((item) => Map<String, dynamic>.from(item)),
        );

        state = state.copyWith(rankings: rankings);
      }
    }
  }

  void _startTimer(int duration) {
    _stopTimer();
    state = state.copyWith(timeRemaining: duration);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0) {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else {
        _stopTimer();
        // Time's up - auto-submit
        _onQuestionTimeout();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
