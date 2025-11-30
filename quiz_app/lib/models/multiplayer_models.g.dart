// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multiplayer_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Participant _$ParticipantFromJson(Map<String, dynamic> json) => _Participant(
  userId: json['user_id'] as String? ?? '',
  username: json['username'] as String? ?? '',
  joinedAt: json['joined_at'] as String? ?? '',
  connected: json['connected'] as bool? ?? true,
  score: (json['score'] as num?)?.toInt() ?? 0,
  answers:
      (json['answers'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
);

Map<String, dynamic> _$ParticipantToJson(_Participant instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'joined_at': instance.joinedAt,
      'connected': instance.connected,
      'score': instance.score,
      'answers': instance.answers,
    };

_SessionState _$SessionStateFromJson(Map<String, dynamic> json) =>
    _SessionState(
      sessionCode: json['session_code'] as String,
      quizId: json['quiz_id'] as String,
      hostId: json['host_id'] as String,
      status: json['status'] as String? ?? 'waiting',
      mode: json['mode'] as String? ?? 'live',
      currentQuestionIndex:
          (json['current_question_index'] as num?)?.toInt() ?? 0,
      quizTitle: json['quiz_title'] as String? ?? '',
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((e) => Participant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      participantCount: (json['participant_count'] as num?)?.toInt() ?? 0,
      hostEndedQuiz: json['host_ended_quiz'] as bool? ?? false,
    );

Map<String, dynamic> _$SessionStateToJson(_SessionState instance) =>
    <String, dynamic>{
      'session_code': instance.sessionCode,
      'quiz_id': instance.quizId,
      'host_id': instance.hostId,
      'status': instance.status,
      'mode': instance.mode,
      'current_question_index': instance.currentQuestionIndex,
      'quiz_title': instance.quizTitle,
      'total_questions': instance.totalQuestions,
      'participants': instance.participants,
      'participant_count': instance.participantCount,
      'host_ended_quiz': instance.hostEndedQuiz,
    };

_GameState _$GameStateFromJson(Map<String, dynamic> json) => _GameState(
  currentQuestion: json['current_question'] as Map<String, dynamic>?,
  questionIndex: (json['question_index'] as num?)?.toInt() ?? 0,
  totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
  timeRemaining: (json['time_remaining'] as num?)?.toInt() ?? 30,
  timeLimit: (json['time_limit'] as num?)?.toInt() ?? 30,
  hasAnswered: json['has_answered'] as bool? ?? false,
  isCorrect: json['is_correct'] as bool?,
  pointsEarned: (json['points_earned'] as num?)?.toInt(),
  timeBonus: (json['time_bonus'] as num?)?.toInt(),
  multiplier: (json['multiplier'] as num?)?.toDouble(),
  correctAnswer: json['correct_answer'],
  rankings: (json['rankings'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  lastAnswerCorrect: json['last_answer_correct'] as bool?,
  selectedAnswer: json['selected_answer'],
  answerDistribution: (json['answer_distribution'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, (e as num).toInt())),
  showingFeedback: json['showing_feedback'] as bool? ?? false,
  showingCorrectAnswer: json['showing_correct_answer'] as bool? ?? false,
  showingLeaderboard: json['showing_leaderboard'] as bool? ?? false,
  feedbackCountdown: (json['feedback_countdown'] as num?)?.toInt() ?? 0,
  isHost: json['is_host'] as bool? ?? false,
  currentScore: (json['current_score'] as num?)?.toInt() ?? 0,
  isPartial: json['is_partial'] as bool? ?? false,
  partialCredit: (json['partial_credit'] as num?)?.toDouble(),
  streak: (json['streak'] as num?)?.toInt() ?? 0,
  streakBonus: (json['streak_bonus'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$GameStateToJson(_GameState instance) =>
    <String, dynamic>{
      'current_question': instance.currentQuestion,
      'question_index': instance.questionIndex,
      'total_questions': instance.totalQuestions,
      'time_remaining': instance.timeRemaining,
      'time_limit': instance.timeLimit,
      'has_answered': instance.hasAnswered,
      'is_correct': instance.isCorrect,
      'points_earned': instance.pointsEarned,
      'time_bonus': instance.timeBonus,
      'multiplier': instance.multiplier,
      'correct_answer': instance.correctAnswer,
      'rankings': instance.rankings,
      'last_answer_correct': instance.lastAnswerCorrect,
      'selected_answer': instance.selectedAnswer,
      'answer_distribution': instance.answerDistribution,
      'showing_feedback': instance.showingFeedback,
      'showing_correct_answer': instance.showingCorrectAnswer,
      'showing_leaderboard': instance.showingLeaderboard,
      'feedback_countdown': instance.feedbackCountdown,
      'is_host': instance.isHost,
      'current_score': instance.currentScore,
      'is_partial': instance.isPartial,
      'partial_credit': instance.partialCredit,
      'streak': instance.streak,
      'streak_bonus': instance.streakBonus,
    };

_LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) =>
    _LeaderboardEntry(
      rank: (json['rank'] as num).toInt(),
      userId: json['user_id'] as String,
      score: (json['score'] as num).toInt(),
    );

Map<String, dynamic> _$LeaderboardEntryToJson(_LeaderboardEntry instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'user_id': instance.userId,
      'score': instance.score,
    };

_LeaderboardState _$LeaderboardStateFromJson(Map<String, dynamic> json) =>
    _LeaderboardState(
      rankings:
          (json['rankings'] as List<dynamic>?)
              ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentUserEntry: json['current_user_entry'] == null
          ? null
          : LeaderboardEntry.fromJson(
              json['current_user_entry'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$LeaderboardStateToJson(_LeaderboardState instance) =>
    <String, dynamic>{
      'rankings': instance.rankings,
      'current_user_entry': instance.currentUserEntry,
    };
