// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'multiplayer_models.freezed.dart';
part 'multiplayer_models.g.dart';

@freezed
abstract class Participant with _$Participant {
  const factory Participant({
    @JsonKey(name: 'user_id') @Default('') String userId,
    @Default('') String username,
    @JsonKey(name: 'joined_at') @Default('') String joinedAt,
    @Default(true) bool connected,
    @Default(0) int score,
    @Default([]) List<Map<String, dynamic>> answers,
  }) = _Participant;

  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class SessionState with _$SessionState {
  const factory SessionState({
    @JsonKey(name: 'session_code') required String sessionCode,
    @JsonKey(name: 'quiz_id') required String quizId,
    @JsonKey(name: 'host_id') required String hostId,
    @Default('waiting') String status,
    @Default('live') String mode,
    @JsonKey(name: 'current_question_index')
    @Default(0)
    int currentQuestionIndex,
    @JsonKey(name: 'quiz_title') @Default('') String quizTitle,
    @JsonKey(name: 'total_questions') @Default(0) int totalQuestions,
    @Default([]) List<Participant> participants,
    @JsonKey(name: 'participant_count') @Default(0) int participantCount,
    @JsonKey(name: 'host_ended_quiz')
    @Default(false)
    bool hostEndedQuiz, // Flag for host manually ending
  }) = _SessionState;

  factory SessionState.fromJson(Map<String, dynamic> json) =>
      _$SessionStateFromJson(json);
}

@freezed
abstract class GameState with _$GameState {
  const factory GameState({
    @JsonKey(name: 'current_question') Map<String, dynamic>? currentQuestion,
    @JsonKey(name: 'question_index') @Default(0) int questionIndex,
    @JsonKey(name: 'total_questions') @Default(0) int totalQuestions,
    @JsonKey(name: 'time_remaining') @Default(30) int timeRemaining,
    @JsonKey(name: 'time_limit')
    @Default(30)
    int timeLimit, // Per-question time limit
    @JsonKey(name: 'has_answered') @Default(false) bool hasAnswered,
    @JsonKey(name: 'is_correct') bool? isCorrect,
    @JsonKey(name: 'points_earned') int? pointsEarned,
    @JsonKey(name: 'time_bonus') int? timeBonus, // Time-based bonus points
    @JsonKey(name: 'multiplier')
    double? multiplier, // Speed multiplier (1.0 - 2.0)
    @JsonKey(name: 'correct_answer') dynamic correctAnswer,
    List<Map<String, dynamic>>? rankings,
    // Answer feedback properties
    @JsonKey(name: 'last_answer_correct') bool? lastAnswerCorrect,
    @JsonKey(name: 'selected_answer') dynamic selectedAnswer,
    @JsonKey(name: 'answer_distribution') Map<dynamic, int>? answerDistribution,
    // Animation state properties
    @JsonKey(name: 'showing_feedback') @Default(false) bool showingFeedback,
    @JsonKey(name: 'showing_correct_answer')
    @Default(false)
    bool showingCorrectAnswer,
    @JsonKey(name: 'showing_leaderboard')
    @Default(false)
    bool showingLeaderboard,
    @JsonKey(name: 'feedback_countdown') @Default(0) int feedbackCountdown,
    // Role and score properties
    @JsonKey(name: 'is_host') @Default(false) bool isHost,
    @JsonKey(name: 'current_score') @Default(0) int currentScore,
    // Partial credit properties
    @JsonKey(name: 'is_partial') @Default(false) bool isPartial,
    @JsonKey(name: 'partial_credit') double? partialCredit,
    // Streak properties
    @JsonKey(name: 'streak') @Default(0) int streak,
    @JsonKey(name: 'streak_bonus') @Default(0) int streakBonus,
  }) = _GameState;

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);
}

@freezed
abstract class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required int rank,
    @JsonKey(name: 'user_id') required String userId,
    required int score,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}

@freezed
abstract class LeaderboardState with _$LeaderboardState {
  const factory LeaderboardState({
    @Default([]) List<LeaderboardEntry> rankings,
    @JsonKey(name: 'current_user_entry') LeaderboardEntry? currentUserEntry,
  }) = _LeaderboardState;

  factory LeaderboardState.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardStateFromJson(json);
}
