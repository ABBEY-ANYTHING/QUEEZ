import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/multiplayer_models.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/services/websocket_service.dart';

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
    debugPrint('⏱️ GAME_PROVIDER - Setting time: perQuestion=${perQuestionTimeLimit}s');
    state = state.copyWith(
      timeLimit: perQuestionTimeLimit,
    );
  }
  
  void _onQuestionTimeout() {
    debugPrint('⏰ GAME_PROVIDER - Question time expired!');
    
    if (state.hasAnswered) {
      debugPrint('⏰ GAME_PROVIDER - Already answered, skipping timeout handling');
      return;
    }
    
    // Auto-submit with no answer (will be marked wrong)
    debugPrint('⏰ GAME_PROVIDER - Auto-submitting due to timeout');
    _wsService.sendMessage('submit_answer', {
      'answer': null, // No answer - timeout
      'timestamp': state.timeLimit.toDouble(), // Full time elapsed
      'timeout': true,
    });
    
    state = state.copyWith(hasAnswered: true);
  }

  void submitAnswer(dynamic answer) {
    if (state.hasAnswered) {
      debugPrint('⚠️ GAME_PROVIDER - Already answered, ignoring');
      return;
    }

    // Calculate elapsed time since question was shown
    double elapsedSeconds = 0;
    if (_questionStartTime != null) {
      elapsedSeconds = DateTime.now().difference(_questionStartTime!).inMilliseconds / 1000.0;
    }

    debugPrint('📤 GAME_PROVIDER - Submitting answer: $answer');
    debugPrint('⏱️ GAME_PROVIDER - Elapsed time: ${elapsedSeconds.toStringAsFixed(2)}s');
    
    _wsService.sendMessage('submit_answer', {
      'answer': answer,
      'timestamp': elapsedSeconds, // Send elapsed time, not absolute timestamp
    });

    // Only mark as answered, don't set selectedAnswer yet (wait for backend response)
    state = state.copyWith(hasAnswered: true);
    debugPrint('✅ GAME_PROVIDER - Answer submitted, hasAnswered=true');
  }

  void showLeaderboard() {
    debugPrint('🏆 GAME_PROVIDER - Showing leaderboard popup');
    state = state.copyWith(showingLeaderboard: true);
  }

  void hideLeaderboard() {
    debugPrint('🏆 GAME_PROVIDER - Hiding leaderboard popup');
    state = state.copyWith(showingLeaderboard: false);
  }

  void requestNextQuestion() {
    debugPrint('➡️ GAME_PROVIDER - Requesting next question from backend');
    // Send request to backend for next question
    _wsService.sendMessage('request_next_question', {});
    // DON'T reset state here - let it reset when new question arrives
    // This prevents the flash of old answers before new question loads
    debugPrint('✅ GAME_PROVIDER - Request sent, waiting for new question');
  }

  void requestLeaderboard() {
    debugPrint('🏆 GAME_PROVIDER - Requesting real-time leaderboard from backend');
    _wsService.sendMessage('request_leaderboard', {});
  }

  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type'];
    final payload = message['payload'];

    if (type == 'question') {
      // New question received - start tracking time for scoring
      debugPrint('📚 GAME_PROVIDER - Processing question message');
      debugPrint('📦 GAME_PROVIDER - Question payload: $payload');
      
      // Get per-question time limit
      final questionTimeLimit = payload['time_limit'] ?? payload['time_remaining'] ?? state.timeLimit;
      
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
      debugPrint(
        '✅ GAME_PROVIDER - State updated, currentQuestion is now: ${state.currentQuestion != null ? "SET" : "NULL"}',
      );
      debugPrint('⏱️ GAME_PROVIDER - Time limit for this question: ${questionTimeLimit}s');
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
      
      // Get the user's submitted answer from the payload if available
      final userAnswer = payload['user_answer'];

      if (isPartial && partialCredit != null) {
        debugPrint('⚠️ GAME_PROVIDER - Partial credit: ${partialCredit.toStringAsFixed(1)}%');
      } else {
        debugPrint('✅ GAME_PROVIDER - Answer result: ${isCorrect ? "CORRECT" : "INCORRECT"}');
      }
      debugPrint('💰 GAME_PROVIDER - Points earned: $points (base: 1000, time bonus: $timeBonus, multiplier: ${multiplier}x)');
      debugPrint('🏆 GAME_PROVIDER - New total score: $newScore');
      debugPrint('🎯 GAME_PROVIDER - Correct answer was: $correctAnswer');
      debugPrint('👤 GAME_PROVIDER - User answer was: $userAnswer');
      debugPrint('📝 GAME_PROVIDER - Question type: $questionType');

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
      );
      
      // Auto-advance for single choice, true/false, and multi-select after delay
      // Reduced delays for faster gameplay (matching single player's 800ms)
      if (questionType == 'singleMcq' || questionType == 'trueFalse') {
        debugPrint('⏱️ GAME_PROVIDER - Auto-advancing to next question in 800ms (single/tf)');
        Future.delayed(const Duration(milliseconds: 800), () {
          if (state.hasAnswered && state.correctAnswer != null) {
            debugPrint('➡️ GAME_PROVIDER - Auto-requesting next question');
            requestNextQuestion();
          }
        });
      } else if (questionType == 'multiMcq') {
        debugPrint('⏱️ GAME_PROVIDER - Auto-advancing to next question in 800ms (multi-select)');
        Future.delayed(const Duration(milliseconds: 800), () {
          if (state.hasAnswered && state.correctAnswer != null) {
            debugPrint('➡️ GAME_PROVIDER - Auto-requesting next question (multi-select)');
            requestNextQuestion();
          }
        });
      } else if (questionType == 'dragAndDrop') {
        debugPrint('⏱️ GAME_PROVIDER - Auto-advancing to next question in 800ms (drag-drop)');
        Future.delayed(const Duration(milliseconds: 800), () {
          if (state.hasAnswered && state.correctAnswer != null) {
            debugPrint('➡️ GAME_PROVIDER - Auto-requesting next question (drag-drop)');
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
      final answerDistribution =
          payload['answer_distribution'] != null
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

      debugPrint('🏆 GAME_PROVIDER - Leaderboard update received');

      if (leaderboard != null) {
        final rankings =
            leaderboard is List
                ? List<Map<String, dynamic>>.from(
                  leaderboard.map((item) => Map<String, dynamic>.from(item)),
                )
                : null;

        if (rankings != null) {
          debugPrint('📊 GAME_PROVIDER - ${rankings.length} participants in leaderboard');
          for (var i = 0; i < rankings.length && i < 3; i++) {
            debugPrint('   ${i + 1}. ${rankings[i]['username']}: ${rankings[i]['score']} pts');
          }
          
          // Update rankings but DON'T show popup (disabled for now)
          state = state.copyWith(
            rankings: rankings,
            showingLeaderboard: false, // DISABLED
          );
          
          debugPrint('✅ GAME_PROVIDER - Rankings updated (popup disabled)');
        }
      }
    } else if (type == 'answer_reveal') {
      // Host reveals answer and shows rankings
      _stopTimer();

      final correctAnswer = payload['correct_answer'];
      final rankings =
          payload['rankings'] != null
              ? List<Map<String, dynamic>>.from(
                payload['rankings'].map(
                  (item) => Map<String, dynamic>.from(item),
                ),
              )
              : null;

      state = state.copyWith(correctAnswer: correctAnswer, rankings: rankings);
    } else if (type == 'quiz_started') {
      // Quiz started - set time settings
      final perQuestionTimeLimit = payload['per_question_time_limit'] as int? ?? 30;
      debugPrint('🚀 GAME_PROVIDER - Quiz started with time settings: perQuestion=${perQuestionTimeLimit}s');
      
      setTimeSettings(perQuestionTimeLimit);
    } else if (type == 'quiz_completed' || type == 'quiz_ended') {
      // Quiz finished
      debugPrint('🏁 GAME_PROVIDER - Quiz completed!');
      _stopTimer();

      final finalRankings = payload['final_rankings'] ?? payload['results'];
      if (finalRankings != null) {
        final rankings = List<Map<String, dynamic>>.from(
          finalRankings.map((item) => Map<String, dynamic>.from(item)),
        );
        debugPrint('📊 GAME_PROVIDER - Final rankings: ${rankings.length} participants');
        state = state.copyWith(rankings: rankings);
      }
    } else if (type == 'leaderboard_response') {
      // Real-time leaderboard response
      debugPrint('🏆 GAME_PROVIDER - Leaderboard response received');
      final leaderboard = payload['leaderboard'];
      
      if (leaderboard != null) {
        final rankings = List<Map<String, dynamic>>.from(
          leaderboard.map((item) => Map<String, dynamic>.from(item)),
        );
        debugPrint('📊 GAME_PROVIDER - ${rankings.length} participants in real-time leaderboard');
        for (var i = 0; i < rankings.length && i < 3; i++) {
          debugPrint('   ${i + 1}. ${rankings[i]['username']}: ${rankings[i]['score']} pts (Q${rankings[i]['answered_count']}/${rankings[i]['total_questions']})');
        }
        
        state = state.copyWith(rankings: rankings);
        debugPrint('✅ GAME_PROVIDER - Real-time rankings updated');
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
