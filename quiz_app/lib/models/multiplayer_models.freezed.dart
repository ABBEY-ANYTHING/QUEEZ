// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'multiplayer_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Participant {

@JsonKey(name: 'user_id') String get userId; String get username;@JsonKey(name: 'joined_at') String get joinedAt; bool get connected; int get score; List<Map<String, dynamic>> get answers;
/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParticipantCopyWith<Participant> get copyWith => _$ParticipantCopyWithImpl<Participant>(this as Participant, _$identity);

  /// Serializes this Participant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Participant&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.connected, connected) || other.connected == connected)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other.answers, answers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,joinedAt,connected,score,const DeepCollectionEquality().hash(answers));

@override
String toString() {
  return 'Participant(userId: $userId, username: $username, joinedAt: $joinedAt, connected: $connected, score: $score, answers: $answers)';
}


}

/// @nodoc
abstract mixin class $ParticipantCopyWith<$Res>  {
  factory $ParticipantCopyWith(Participant value, $Res Function(Participant) _then) = _$ParticipantCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username,@JsonKey(name: 'joined_at') String joinedAt, bool connected, int score, List<Map<String, dynamic>> answers
});




}
/// @nodoc
class _$ParticipantCopyWithImpl<$Res>
    implements $ParticipantCopyWith<$Res> {
  _$ParticipantCopyWithImpl(this._self, this._then);

  final Participant _self;
  final $Res Function(Participant) _then;

/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? joinedAt = null,Object? connected = null,Object? score = null,Object? answers = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String,connected: null == connected ? _self.connected : connected // ignore: cast_nullable_to_non_nullable
as bool,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

}


/// Adds pattern-matching-related methods to [Participant].
extension ParticipantPatterns on Participant {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Participant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Participant() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Participant value)  $default,){
final _that = this;
switch (_that) {
case _Participant():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Participant value)?  $default,){
final _that = this;
switch (_that) {
case _Participant() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'joined_at')  String joinedAt,  bool connected,  int score,  List<Map<String, dynamic>> answers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Participant() when $default != null:
return $default(_that.userId,_that.username,_that.joinedAt,_that.connected,_that.score,_that.answers);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'joined_at')  String joinedAt,  bool connected,  int score,  List<Map<String, dynamic>> answers)  $default,) {final _that = this;
switch (_that) {
case _Participant():
return $default(_that.userId,_that.username,_that.joinedAt,_that.connected,_that.score,_that.answers);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'joined_at')  String joinedAt,  bool connected,  int score,  List<Map<String, dynamic>> answers)?  $default,) {final _that = this;
switch (_that) {
case _Participant() when $default != null:
return $default(_that.userId,_that.username,_that.joinedAt,_that.connected,_that.score,_that.answers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Participant implements Participant {
  const _Participant({@JsonKey(name: 'user_id') this.userId = '', this.username = '', @JsonKey(name: 'joined_at') this.joinedAt = '', this.connected = true, this.score = 0, final  List<Map<String, dynamic>> answers = const []}): _answers = answers;
  factory _Participant.fromJson(Map<String, dynamic> json) => _$ParticipantFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey() final  String username;
@override@JsonKey(name: 'joined_at') final  String joinedAt;
@override@JsonKey() final  bool connected;
@override@JsonKey() final  int score;
 final  List<Map<String, dynamic>> _answers;
@override@JsonKey() List<Map<String, dynamic>> get answers {
  if (_answers is EqualUnmodifiableListView) return _answers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_answers);
}


/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParticipantCopyWith<_Participant> get copyWith => __$ParticipantCopyWithImpl<_Participant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParticipantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Participant&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.connected, connected) || other.connected == connected)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other._answers, _answers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,joinedAt,connected,score,const DeepCollectionEquality().hash(_answers));

@override
String toString() {
  return 'Participant(userId: $userId, username: $username, joinedAt: $joinedAt, connected: $connected, score: $score, answers: $answers)';
}


}

/// @nodoc
abstract mixin class _$ParticipantCopyWith<$Res> implements $ParticipantCopyWith<$Res> {
  factory _$ParticipantCopyWith(_Participant value, $Res Function(_Participant) _then) = __$ParticipantCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username,@JsonKey(name: 'joined_at') String joinedAt, bool connected, int score, List<Map<String, dynamic>> answers
});




}
/// @nodoc
class __$ParticipantCopyWithImpl<$Res>
    implements _$ParticipantCopyWith<$Res> {
  __$ParticipantCopyWithImpl(this._self, this._then);

  final _Participant _self;
  final $Res Function(_Participant) _then;

/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? joinedAt = null,Object? connected = null,Object? score = null,Object? answers = null,}) {
  return _then(_Participant(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String,connected: null == connected ? _self.connected : connected // ignore: cast_nullable_to_non_nullable
as bool,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,answers: null == answers ? _self._answers : answers // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}


}


/// @nodoc
mixin _$SessionState {

@JsonKey(name: 'session_code') String get sessionCode;@JsonKey(name: 'quiz_id') String get quizId;@JsonKey(name: 'host_id') String get hostId; String get status; String get mode;@JsonKey(name: 'current_question_index') int get currentQuestionIndex;@JsonKey(name: 'quiz_title') String get quizTitle;@JsonKey(name: 'total_questions') int get totalQuestions; List<Participant> get participants;@JsonKey(name: 'participant_count') int get participantCount;@JsonKey(name: 'host_ended_quiz') bool get hostEndedQuiz;
/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionStateCopyWith<SessionState> get copyWith => _$SessionStateCopyWithImpl<SessionState>(this as SessionState, _$identity);

  /// Serializes this SessionState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionState&&(identical(other.sessionCode, sessionCode) || other.sessionCode == sessionCode)&&(identical(other.quizId, quizId) || other.quizId == quizId)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.status, status) || other.status == status)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.currentQuestionIndex, currentQuestionIndex) || other.currentQuestionIndex == currentQuestionIndex)&&(identical(other.quizTitle, quizTitle) || other.quizTitle == quizTitle)&&(identical(other.totalQuestions, totalQuestions) || other.totalQuestions == totalQuestions)&&const DeepCollectionEquality().equals(other.participants, participants)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&(identical(other.hostEndedQuiz, hostEndedQuiz) || other.hostEndedQuiz == hostEndedQuiz));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionCode,quizId,hostId,status,mode,currentQuestionIndex,quizTitle,totalQuestions,const DeepCollectionEquality().hash(participants),participantCount,hostEndedQuiz);

@override
String toString() {
  return 'SessionState(sessionCode: $sessionCode, quizId: $quizId, hostId: $hostId, status: $status, mode: $mode, currentQuestionIndex: $currentQuestionIndex, quizTitle: $quizTitle, totalQuestions: $totalQuestions, participants: $participants, participantCount: $participantCount, hostEndedQuiz: $hostEndedQuiz)';
}


}

/// @nodoc
abstract mixin class $SessionStateCopyWith<$Res>  {
  factory $SessionStateCopyWith(SessionState value, $Res Function(SessionState) _then) = _$SessionStateCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'session_code') String sessionCode,@JsonKey(name: 'quiz_id') String quizId,@JsonKey(name: 'host_id') String hostId, String status, String mode,@JsonKey(name: 'current_question_index') int currentQuestionIndex,@JsonKey(name: 'quiz_title') String quizTitle,@JsonKey(name: 'total_questions') int totalQuestions, List<Participant> participants,@JsonKey(name: 'participant_count') int participantCount,@JsonKey(name: 'host_ended_quiz') bool hostEndedQuiz
});




}
/// @nodoc
class _$SessionStateCopyWithImpl<$Res>
    implements $SessionStateCopyWith<$Res> {
  _$SessionStateCopyWithImpl(this._self, this._then);

  final SessionState _self;
  final $Res Function(SessionState) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionCode = null,Object? quizId = null,Object? hostId = null,Object? status = null,Object? mode = null,Object? currentQuestionIndex = null,Object? quizTitle = null,Object? totalQuestions = null,Object? participants = null,Object? participantCount = null,Object? hostEndedQuiz = null,}) {
  return _then(_self.copyWith(
sessionCode: null == sessionCode ? _self.sessionCode : sessionCode // ignore: cast_nullable_to_non_nullable
as String,quizId: null == quizId ? _self.quizId : quizId // ignore: cast_nullable_to_non_nullable
as String,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,currentQuestionIndex: null == currentQuestionIndex ? _self.currentQuestionIndex : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
as int,quizTitle: null == quizTitle ? _self.quizTitle : quizTitle // ignore: cast_nullable_to_non_nullable
as String,totalQuestions: null == totalQuestions ? _self.totalQuestions : totalQuestions // ignore: cast_nullable_to_non_nullable
as int,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<Participant>,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,hostEndedQuiz: null == hostEndedQuiz ? _self.hostEndedQuiz : hostEndedQuiz // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionState].
extension SessionStatePatterns on SessionState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionState value)  $default,){
final _that = this;
switch (_that) {
case _SessionState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionState value)?  $default,){
final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_code')  String sessionCode, @JsonKey(name: 'quiz_id')  String quizId, @JsonKey(name: 'host_id')  String hostId,  String status,  String mode, @JsonKey(name: 'current_question_index')  int currentQuestionIndex, @JsonKey(name: 'quiz_title')  String quizTitle, @JsonKey(name: 'total_questions')  int totalQuestions,  List<Participant> participants, @JsonKey(name: 'participant_count')  int participantCount, @JsonKey(name: 'host_ended_quiz')  bool hostEndedQuiz)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that.sessionCode,_that.quizId,_that.hostId,_that.status,_that.mode,_that.currentQuestionIndex,_that.quizTitle,_that.totalQuestions,_that.participants,_that.participantCount,_that.hostEndedQuiz);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_code')  String sessionCode, @JsonKey(name: 'quiz_id')  String quizId, @JsonKey(name: 'host_id')  String hostId,  String status,  String mode, @JsonKey(name: 'current_question_index')  int currentQuestionIndex, @JsonKey(name: 'quiz_title')  String quizTitle, @JsonKey(name: 'total_questions')  int totalQuestions,  List<Participant> participants, @JsonKey(name: 'participant_count')  int participantCount, @JsonKey(name: 'host_ended_quiz')  bool hostEndedQuiz)  $default,) {final _that = this;
switch (_that) {
case _SessionState():
return $default(_that.sessionCode,_that.quizId,_that.hostId,_that.status,_that.mode,_that.currentQuestionIndex,_that.quizTitle,_that.totalQuestions,_that.participants,_that.participantCount,_that.hostEndedQuiz);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'session_code')  String sessionCode, @JsonKey(name: 'quiz_id')  String quizId, @JsonKey(name: 'host_id')  String hostId,  String status,  String mode, @JsonKey(name: 'current_question_index')  int currentQuestionIndex, @JsonKey(name: 'quiz_title')  String quizTitle, @JsonKey(name: 'total_questions')  int totalQuestions,  List<Participant> participants, @JsonKey(name: 'participant_count')  int participantCount, @JsonKey(name: 'host_ended_quiz')  bool hostEndedQuiz)?  $default,) {final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that.sessionCode,_that.quizId,_that.hostId,_that.status,_that.mode,_that.currentQuestionIndex,_that.quizTitle,_that.totalQuestions,_that.participants,_that.participantCount,_that.hostEndedQuiz);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionState implements SessionState {
  const _SessionState({@JsonKey(name: 'session_code') required this.sessionCode, @JsonKey(name: 'quiz_id') required this.quizId, @JsonKey(name: 'host_id') required this.hostId, this.status = 'waiting', this.mode = 'live', @JsonKey(name: 'current_question_index') this.currentQuestionIndex = 0, @JsonKey(name: 'quiz_title') this.quizTitle = '', @JsonKey(name: 'total_questions') this.totalQuestions = 0, this.participants = const [], @JsonKey(name: 'participant_count') this.participantCount = 0, @JsonKey(name: 'host_ended_quiz') this.hostEndedQuiz = false});
  factory _SessionState.fromJson(Map<String, dynamic> json) => _$SessionStateFromJson(json);

@override@JsonKey(name: 'session_code') final  String sessionCode;
@override@JsonKey(name: 'quiz_id') final  String quizId;
@override@JsonKey(name: 'host_id') final  String hostId;
@override@JsonKey() final  String status;
@override@JsonKey() final  String mode;
@override@JsonKey(name: 'current_question_index') final  int currentQuestionIndex;
@override@JsonKey(name: 'quiz_title') final  String quizTitle;
@override@JsonKey(name: 'total_questions') final  int totalQuestions;
@override@JsonKey() final  List<Participant> participants;
@override@JsonKey(name: 'participant_count') final  int participantCount;
@override@JsonKey(name: 'host_ended_quiz') final  bool hostEndedQuiz;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionStateCopyWith<_SessionState> get copyWith => __$SessionStateCopyWithImpl<_SessionState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionState&&(identical(other.sessionCode, sessionCode) || other.sessionCode == sessionCode)&&(identical(other.quizId, quizId) || other.quizId == quizId)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.status, status) || other.status == status)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.currentQuestionIndex, currentQuestionIndex) || other.currentQuestionIndex == currentQuestionIndex)&&(identical(other.quizTitle, quizTitle) || other.quizTitle == quizTitle)&&(identical(other.totalQuestions, totalQuestions) || other.totalQuestions == totalQuestions)&&const DeepCollectionEquality().equals(other.participants, participants)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&(identical(other.hostEndedQuiz, hostEndedQuiz) || other.hostEndedQuiz == hostEndedQuiz));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionCode,quizId,hostId,status,mode,currentQuestionIndex,quizTitle,totalQuestions,const DeepCollectionEquality().hash(participants),participantCount,hostEndedQuiz);

@override
String toString() {
  return 'SessionState(sessionCode: $sessionCode, quizId: $quizId, hostId: $hostId, status: $status, mode: $mode, currentQuestionIndex: $currentQuestionIndex, quizTitle: $quizTitle, totalQuestions: $totalQuestions, participants: $participants, participantCount: $participantCount, hostEndedQuiz: $hostEndedQuiz)';
}


}

/// @nodoc
abstract mixin class _$SessionStateCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory _$SessionStateCopyWith(_SessionState value, $Res Function(_SessionState) _then) = __$SessionStateCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'session_code') String sessionCode,@JsonKey(name: 'quiz_id') String quizId,@JsonKey(name: 'host_id') String hostId, String status, String mode,@JsonKey(name: 'current_question_index') int currentQuestionIndex,@JsonKey(name: 'quiz_title') String quizTitle,@JsonKey(name: 'total_questions') int totalQuestions, List<Participant> participants,@JsonKey(name: 'participant_count') int participantCount,@JsonKey(name: 'host_ended_quiz') bool hostEndedQuiz
});




}
/// @nodoc
class __$SessionStateCopyWithImpl<$Res>
    implements _$SessionStateCopyWith<$Res> {
  __$SessionStateCopyWithImpl(this._self, this._then);

  final _SessionState _self;
  final $Res Function(_SessionState) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionCode = null,Object? quizId = null,Object? hostId = null,Object? status = null,Object? mode = null,Object? currentQuestionIndex = null,Object? quizTitle = null,Object? totalQuestions = null,Object? participants = null,Object? participantCount = null,Object? hostEndedQuiz = null,}) {
  return _then(_SessionState(
sessionCode: null == sessionCode ? _self.sessionCode : sessionCode // ignore: cast_nullable_to_non_nullable
as String,quizId: null == quizId ? _self.quizId : quizId // ignore: cast_nullable_to_non_nullable
as String,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,currentQuestionIndex: null == currentQuestionIndex ? _self.currentQuestionIndex : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
as int,quizTitle: null == quizTitle ? _self.quizTitle : quizTitle // ignore: cast_nullable_to_non_nullable
as String,totalQuestions: null == totalQuestions ? _self.totalQuestions : totalQuestions // ignore: cast_nullable_to_non_nullable
as int,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<Participant>,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,hostEndedQuiz: null == hostEndedQuiz ? _self.hostEndedQuiz : hostEndedQuiz // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$GameState {

@JsonKey(name: 'current_question') Map<String, dynamic>? get currentQuestion;@JsonKey(name: 'question_index') int get questionIndex;@JsonKey(name: 'total_questions') int get totalQuestions;@JsonKey(name: 'time_remaining') int get timeRemaining;@JsonKey(name: 'time_limit') int get timeLimit;// Per-question time limit
@JsonKey(name: 'has_answered') bool get hasAnswered;@JsonKey(name: 'is_correct') bool? get isCorrect;@JsonKey(name: 'points_earned') int? get pointsEarned;@JsonKey(name: 'time_bonus') int? get timeBonus;// Time-based bonus points
@JsonKey(name: 'multiplier') double? get multiplier;// Speed multiplier (1.0 - 2.0)
@JsonKey(name: 'correct_answer') dynamic get correctAnswer; List<Map<String, dynamic>>? get rankings;// Answer feedback properties
@JsonKey(name: 'last_answer_correct') bool? get lastAnswerCorrect;@JsonKey(name: 'selected_answer') dynamic get selectedAnswer;@JsonKey(name: 'answer_distribution') Map<dynamic, int>? get answerDistribution;// Animation state properties
@JsonKey(name: 'showing_feedback') bool get showingFeedback;@JsonKey(name: 'showing_correct_answer') bool get showingCorrectAnswer;@JsonKey(name: 'showing_leaderboard') bool get showingLeaderboard;@JsonKey(name: 'feedback_countdown') int get feedbackCountdown;// Role and score properties
@JsonKey(name: 'is_host') bool get isHost;@JsonKey(name: 'current_score') int get currentScore;// Partial credit properties
@JsonKey(name: 'is_partial') bool get isPartial;@JsonKey(name: 'partial_credit') double? get partialCredit;// Streak properties
@JsonKey(name: 'streak') int get streak;@JsonKey(name: 'streak_bonus') int get streakBonus;
/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameStateCopyWith<GameState> get copyWith => _$GameStateCopyWithImpl<GameState>(this as GameState, _$identity);

  /// Serializes this GameState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameState&&const DeepCollectionEquality().equals(other.currentQuestion, currentQuestion)&&(identical(other.questionIndex, questionIndex) || other.questionIndex == questionIndex)&&(identical(other.totalQuestions, totalQuestions) || other.totalQuestions == totalQuestions)&&(identical(other.timeRemaining, timeRemaining) || other.timeRemaining == timeRemaining)&&(identical(other.timeLimit, timeLimit) || other.timeLimit == timeLimit)&&(identical(other.hasAnswered, hasAnswered) || other.hasAnswered == hasAnswered)&&(identical(other.isCorrect, isCorrect) || other.isCorrect == isCorrect)&&(identical(other.pointsEarned, pointsEarned) || other.pointsEarned == pointsEarned)&&(identical(other.timeBonus, timeBonus) || other.timeBonus == timeBonus)&&(identical(other.multiplier, multiplier) || other.multiplier == multiplier)&&const DeepCollectionEquality().equals(other.correctAnswer, correctAnswer)&&const DeepCollectionEquality().equals(other.rankings, rankings)&&(identical(other.lastAnswerCorrect, lastAnswerCorrect) || other.lastAnswerCorrect == lastAnswerCorrect)&&const DeepCollectionEquality().equals(other.selectedAnswer, selectedAnswer)&&const DeepCollectionEquality().equals(other.answerDistribution, answerDistribution)&&(identical(other.showingFeedback, showingFeedback) || other.showingFeedback == showingFeedback)&&(identical(other.showingCorrectAnswer, showingCorrectAnswer) || other.showingCorrectAnswer == showingCorrectAnswer)&&(identical(other.showingLeaderboard, showingLeaderboard) || other.showingLeaderboard == showingLeaderboard)&&(identical(other.feedbackCountdown, feedbackCountdown) || other.feedbackCountdown == feedbackCountdown)&&(identical(other.isHost, isHost) || other.isHost == isHost)&&(identical(other.currentScore, currentScore) || other.currentScore == currentScore)&&(identical(other.isPartial, isPartial) || other.isPartial == isPartial)&&(identical(other.partialCredit, partialCredit) || other.partialCredit == partialCredit)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.streakBonus, streakBonus) || other.streakBonus == streakBonus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(currentQuestion),questionIndex,totalQuestions,timeRemaining,timeLimit,hasAnswered,isCorrect,pointsEarned,timeBonus,multiplier,const DeepCollectionEquality().hash(correctAnswer),const DeepCollectionEquality().hash(rankings),lastAnswerCorrect,const DeepCollectionEquality().hash(selectedAnswer),const DeepCollectionEquality().hash(answerDistribution),showingFeedback,showingCorrectAnswer,showingLeaderboard,feedbackCountdown,isHost,currentScore,isPartial,partialCredit,streak,streakBonus]);

@override
String toString() {
  return 'GameState(currentQuestion: $currentQuestion, questionIndex: $questionIndex, totalQuestions: $totalQuestions, timeRemaining: $timeRemaining, timeLimit: $timeLimit, hasAnswered: $hasAnswered, isCorrect: $isCorrect, pointsEarned: $pointsEarned, timeBonus: $timeBonus, multiplier: $multiplier, correctAnswer: $correctAnswer, rankings: $rankings, lastAnswerCorrect: $lastAnswerCorrect, selectedAnswer: $selectedAnswer, answerDistribution: $answerDistribution, showingFeedback: $showingFeedback, showingCorrectAnswer: $showingCorrectAnswer, showingLeaderboard: $showingLeaderboard, feedbackCountdown: $feedbackCountdown, isHost: $isHost, currentScore: $currentScore, isPartial: $isPartial, partialCredit: $partialCredit, streak: $streak, streakBonus: $streakBonus)';
}


}

/// @nodoc
abstract mixin class $GameStateCopyWith<$Res>  {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) _then) = _$GameStateCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'current_question') Map<String, dynamic>? currentQuestion,@JsonKey(name: 'question_index') int questionIndex,@JsonKey(name: 'total_questions') int totalQuestions,@JsonKey(name: 'time_remaining') int timeRemaining,@JsonKey(name: 'time_limit') int timeLimit,@JsonKey(name: 'has_answered') bool hasAnswered,@JsonKey(name: 'is_correct') bool? isCorrect,@JsonKey(name: 'points_earned') int? pointsEarned,@JsonKey(name: 'time_bonus') int? timeBonus,@JsonKey(name: 'multiplier') double? multiplier,@JsonKey(name: 'correct_answer') dynamic correctAnswer, List<Map<String, dynamic>>? rankings,@JsonKey(name: 'last_answer_correct') bool? lastAnswerCorrect,@JsonKey(name: 'selected_answer') dynamic selectedAnswer,@JsonKey(name: 'answer_distribution') Map<dynamic, int>? answerDistribution,@JsonKey(name: 'showing_feedback') bool showingFeedback,@JsonKey(name: 'showing_correct_answer') bool showingCorrectAnswer,@JsonKey(name: 'showing_leaderboard') bool showingLeaderboard,@JsonKey(name: 'feedback_countdown') int feedbackCountdown,@JsonKey(name: 'is_host') bool isHost,@JsonKey(name: 'current_score') int currentScore,@JsonKey(name: 'is_partial') bool isPartial,@JsonKey(name: 'partial_credit') double? partialCredit,@JsonKey(name: 'streak') int streak,@JsonKey(name: 'streak_bonus') int streakBonus
});




}
/// @nodoc
class _$GameStateCopyWithImpl<$Res>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._self, this._then);

  final GameState _self;
  final $Res Function(GameState) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentQuestion = freezed,Object? questionIndex = null,Object? totalQuestions = null,Object? timeRemaining = null,Object? timeLimit = null,Object? hasAnswered = null,Object? isCorrect = freezed,Object? pointsEarned = freezed,Object? timeBonus = freezed,Object? multiplier = freezed,Object? correctAnswer = freezed,Object? rankings = freezed,Object? lastAnswerCorrect = freezed,Object? selectedAnswer = freezed,Object? answerDistribution = freezed,Object? showingFeedback = null,Object? showingCorrectAnswer = null,Object? showingLeaderboard = null,Object? feedbackCountdown = null,Object? isHost = null,Object? currentScore = null,Object? isPartial = null,Object? partialCredit = freezed,Object? streak = null,Object? streakBonus = null,}) {
  return _then(_self.copyWith(
currentQuestion: freezed == currentQuestion ? _self.currentQuestion : currentQuestion // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,questionIndex: null == questionIndex ? _self.questionIndex : questionIndex // ignore: cast_nullable_to_non_nullable
as int,totalQuestions: null == totalQuestions ? _self.totalQuestions : totalQuestions // ignore: cast_nullable_to_non_nullable
as int,timeRemaining: null == timeRemaining ? _self.timeRemaining : timeRemaining // ignore: cast_nullable_to_non_nullable
as int,timeLimit: null == timeLimit ? _self.timeLimit : timeLimit // ignore: cast_nullable_to_non_nullable
as int,hasAnswered: null == hasAnswered ? _self.hasAnswered : hasAnswered // ignore: cast_nullable_to_non_nullable
as bool,isCorrect: freezed == isCorrect ? _self.isCorrect : isCorrect // ignore: cast_nullable_to_non_nullable
as bool?,pointsEarned: freezed == pointsEarned ? _self.pointsEarned : pointsEarned // ignore: cast_nullable_to_non_nullable
as int?,timeBonus: freezed == timeBonus ? _self.timeBonus : timeBonus // ignore: cast_nullable_to_non_nullable
as int?,multiplier: freezed == multiplier ? _self.multiplier : multiplier // ignore: cast_nullable_to_non_nullable
as double?,correctAnswer: freezed == correctAnswer ? _self.correctAnswer : correctAnswer // ignore: cast_nullable_to_non_nullable
as dynamic,rankings: freezed == rankings ? _self.rankings : rankings // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,lastAnswerCorrect: freezed == lastAnswerCorrect ? _self.lastAnswerCorrect : lastAnswerCorrect // ignore: cast_nullable_to_non_nullable
as bool?,selectedAnswer: freezed == selectedAnswer ? _self.selectedAnswer : selectedAnswer // ignore: cast_nullable_to_non_nullable
as dynamic,answerDistribution: freezed == answerDistribution ? _self.answerDistribution : answerDistribution // ignore: cast_nullable_to_non_nullable
as Map<dynamic, int>?,showingFeedback: null == showingFeedback ? _self.showingFeedback : showingFeedback // ignore: cast_nullable_to_non_nullable
as bool,showingCorrectAnswer: null == showingCorrectAnswer ? _self.showingCorrectAnswer : showingCorrectAnswer // ignore: cast_nullable_to_non_nullable
as bool,showingLeaderboard: null == showingLeaderboard ? _self.showingLeaderboard : showingLeaderboard // ignore: cast_nullable_to_non_nullable
as bool,feedbackCountdown: null == feedbackCountdown ? _self.feedbackCountdown : feedbackCountdown // ignore: cast_nullable_to_non_nullable
as int,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,currentScore: null == currentScore ? _self.currentScore : currentScore // ignore: cast_nullable_to_non_nullable
as int,isPartial: null == isPartial ? _self.isPartial : isPartial // ignore: cast_nullable_to_non_nullable
as bool,partialCredit: freezed == partialCredit ? _self.partialCredit : partialCredit // ignore: cast_nullable_to_non_nullable
as double?,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,streakBonus: null == streakBonus ? _self.streakBonus : streakBonus // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GameState].
extension GameStatePatterns on GameState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameState value)  $default,){
final _that = this;
switch (_that) {
case _GameState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameState value)?  $default,){
final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_question')  Map<String, dynamic>? currentQuestion, @JsonKey(name: 'question_index')  int questionIndex, @JsonKey(name: 'total_questions')  int totalQuestions, @JsonKey(name: 'time_remaining')  int timeRemaining, @JsonKey(name: 'time_limit')  int timeLimit, @JsonKey(name: 'has_answered')  bool hasAnswered, @JsonKey(name: 'is_correct')  bool? isCorrect, @JsonKey(name: 'points_earned')  int? pointsEarned, @JsonKey(name: 'time_bonus')  int? timeBonus, @JsonKey(name: 'multiplier')  double? multiplier, @JsonKey(name: 'correct_answer')  dynamic correctAnswer,  List<Map<String, dynamic>>? rankings, @JsonKey(name: 'last_answer_correct')  bool? lastAnswerCorrect, @JsonKey(name: 'selected_answer')  dynamic selectedAnswer, @JsonKey(name: 'answer_distribution')  Map<dynamic, int>? answerDistribution, @JsonKey(name: 'showing_feedback')  bool showingFeedback, @JsonKey(name: 'showing_correct_answer')  bool showingCorrectAnswer, @JsonKey(name: 'showing_leaderboard')  bool showingLeaderboard, @JsonKey(name: 'feedback_countdown')  int feedbackCountdown, @JsonKey(name: 'is_host')  bool isHost, @JsonKey(name: 'current_score')  int currentScore, @JsonKey(name: 'is_partial')  bool isPartial, @JsonKey(name: 'partial_credit')  double? partialCredit, @JsonKey(name: 'streak')  int streak, @JsonKey(name: 'streak_bonus')  int streakBonus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that.currentQuestion,_that.questionIndex,_that.totalQuestions,_that.timeRemaining,_that.timeLimit,_that.hasAnswered,_that.isCorrect,_that.pointsEarned,_that.timeBonus,_that.multiplier,_that.correctAnswer,_that.rankings,_that.lastAnswerCorrect,_that.selectedAnswer,_that.answerDistribution,_that.showingFeedback,_that.showingCorrectAnswer,_that.showingLeaderboard,_that.feedbackCountdown,_that.isHost,_that.currentScore,_that.isPartial,_that.partialCredit,_that.streak,_that.streakBonus);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_question')  Map<String, dynamic>? currentQuestion, @JsonKey(name: 'question_index')  int questionIndex, @JsonKey(name: 'total_questions')  int totalQuestions, @JsonKey(name: 'time_remaining')  int timeRemaining, @JsonKey(name: 'time_limit')  int timeLimit, @JsonKey(name: 'has_answered')  bool hasAnswered, @JsonKey(name: 'is_correct')  bool? isCorrect, @JsonKey(name: 'points_earned')  int? pointsEarned, @JsonKey(name: 'time_bonus')  int? timeBonus, @JsonKey(name: 'multiplier')  double? multiplier, @JsonKey(name: 'correct_answer')  dynamic correctAnswer,  List<Map<String, dynamic>>? rankings, @JsonKey(name: 'last_answer_correct')  bool? lastAnswerCorrect, @JsonKey(name: 'selected_answer')  dynamic selectedAnswer, @JsonKey(name: 'answer_distribution')  Map<dynamic, int>? answerDistribution, @JsonKey(name: 'showing_feedback')  bool showingFeedback, @JsonKey(name: 'showing_correct_answer')  bool showingCorrectAnswer, @JsonKey(name: 'showing_leaderboard')  bool showingLeaderboard, @JsonKey(name: 'feedback_countdown')  int feedbackCountdown, @JsonKey(name: 'is_host')  bool isHost, @JsonKey(name: 'current_score')  int currentScore, @JsonKey(name: 'is_partial')  bool isPartial, @JsonKey(name: 'partial_credit')  double? partialCredit, @JsonKey(name: 'streak')  int streak, @JsonKey(name: 'streak_bonus')  int streakBonus)  $default,) {final _that = this;
switch (_that) {
case _GameState():
return $default(_that.currentQuestion,_that.questionIndex,_that.totalQuestions,_that.timeRemaining,_that.timeLimit,_that.hasAnswered,_that.isCorrect,_that.pointsEarned,_that.timeBonus,_that.multiplier,_that.correctAnswer,_that.rankings,_that.lastAnswerCorrect,_that.selectedAnswer,_that.answerDistribution,_that.showingFeedback,_that.showingCorrectAnswer,_that.showingLeaderboard,_that.feedbackCountdown,_that.isHost,_that.currentScore,_that.isPartial,_that.partialCredit,_that.streak,_that.streakBonus);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'current_question')  Map<String, dynamic>? currentQuestion, @JsonKey(name: 'question_index')  int questionIndex, @JsonKey(name: 'total_questions')  int totalQuestions, @JsonKey(name: 'time_remaining')  int timeRemaining, @JsonKey(name: 'time_limit')  int timeLimit, @JsonKey(name: 'has_answered')  bool hasAnswered, @JsonKey(name: 'is_correct')  bool? isCorrect, @JsonKey(name: 'points_earned')  int? pointsEarned, @JsonKey(name: 'time_bonus')  int? timeBonus, @JsonKey(name: 'multiplier')  double? multiplier, @JsonKey(name: 'correct_answer')  dynamic correctAnswer,  List<Map<String, dynamic>>? rankings, @JsonKey(name: 'last_answer_correct')  bool? lastAnswerCorrect, @JsonKey(name: 'selected_answer')  dynamic selectedAnswer, @JsonKey(name: 'answer_distribution')  Map<dynamic, int>? answerDistribution, @JsonKey(name: 'showing_feedback')  bool showingFeedback, @JsonKey(name: 'showing_correct_answer')  bool showingCorrectAnswer, @JsonKey(name: 'showing_leaderboard')  bool showingLeaderboard, @JsonKey(name: 'feedback_countdown')  int feedbackCountdown, @JsonKey(name: 'is_host')  bool isHost, @JsonKey(name: 'current_score')  int currentScore, @JsonKey(name: 'is_partial')  bool isPartial, @JsonKey(name: 'partial_credit')  double? partialCredit, @JsonKey(name: 'streak')  int streak, @JsonKey(name: 'streak_bonus')  int streakBonus)?  $default,) {final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that.currentQuestion,_that.questionIndex,_that.totalQuestions,_that.timeRemaining,_that.timeLimit,_that.hasAnswered,_that.isCorrect,_that.pointsEarned,_that.timeBonus,_that.multiplier,_that.correctAnswer,_that.rankings,_that.lastAnswerCorrect,_that.selectedAnswer,_that.answerDistribution,_that.showingFeedback,_that.showingCorrectAnswer,_that.showingLeaderboard,_that.feedbackCountdown,_that.isHost,_that.currentScore,_that.isPartial,_that.partialCredit,_that.streak,_that.streakBonus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameState implements GameState {
  const _GameState({@JsonKey(name: 'current_question') final  Map<String, dynamic>? currentQuestion, @JsonKey(name: 'question_index') this.questionIndex = 0, @JsonKey(name: 'total_questions') this.totalQuestions = 0, @JsonKey(name: 'time_remaining') this.timeRemaining = 30, @JsonKey(name: 'time_limit') this.timeLimit = 30, @JsonKey(name: 'has_answered') this.hasAnswered = false, @JsonKey(name: 'is_correct') this.isCorrect, @JsonKey(name: 'points_earned') this.pointsEarned, @JsonKey(name: 'time_bonus') this.timeBonus, @JsonKey(name: 'multiplier') this.multiplier, @JsonKey(name: 'correct_answer') this.correctAnswer, final  List<Map<String, dynamic>>? rankings, @JsonKey(name: 'last_answer_correct') this.lastAnswerCorrect, @JsonKey(name: 'selected_answer') this.selectedAnswer, @JsonKey(name: 'answer_distribution') final  Map<dynamic, int>? answerDistribution, @JsonKey(name: 'showing_feedback') this.showingFeedback = false, @JsonKey(name: 'showing_correct_answer') this.showingCorrectAnswer = false, @JsonKey(name: 'showing_leaderboard') this.showingLeaderboard = false, @JsonKey(name: 'feedback_countdown') this.feedbackCountdown = 0, @JsonKey(name: 'is_host') this.isHost = false, @JsonKey(name: 'current_score') this.currentScore = 0, @JsonKey(name: 'is_partial') this.isPartial = false, @JsonKey(name: 'partial_credit') this.partialCredit, @JsonKey(name: 'streak') this.streak = 0, @JsonKey(name: 'streak_bonus') this.streakBonus = 0}): _currentQuestion = currentQuestion,_rankings = rankings,_answerDistribution = answerDistribution;
  factory _GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);

 final  Map<String, dynamic>? _currentQuestion;
@override@JsonKey(name: 'current_question') Map<String, dynamic>? get currentQuestion {
  final value = _currentQuestion;
  if (value == null) return null;
  if (_currentQuestion is EqualUnmodifiableMapView) return _currentQuestion;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'question_index') final  int questionIndex;
@override@JsonKey(name: 'total_questions') final  int totalQuestions;
@override@JsonKey(name: 'time_remaining') final  int timeRemaining;
@override@JsonKey(name: 'time_limit') final  int timeLimit;
// Per-question time limit
@override@JsonKey(name: 'has_answered') final  bool hasAnswered;
@override@JsonKey(name: 'is_correct') final  bool? isCorrect;
@override@JsonKey(name: 'points_earned') final  int? pointsEarned;
@override@JsonKey(name: 'time_bonus') final  int? timeBonus;
// Time-based bonus points
@override@JsonKey(name: 'multiplier') final  double? multiplier;
// Speed multiplier (1.0 - 2.0)
@override@JsonKey(name: 'correct_answer') final  dynamic correctAnswer;
 final  List<Map<String, dynamic>>? _rankings;
@override List<Map<String, dynamic>>? get rankings {
  final value = _rankings;
  if (value == null) return null;
  if (_rankings is EqualUnmodifiableListView) return _rankings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// Answer feedback properties
@override@JsonKey(name: 'last_answer_correct') final  bool? lastAnswerCorrect;
@override@JsonKey(name: 'selected_answer') final  dynamic selectedAnswer;
 final  Map<dynamic, int>? _answerDistribution;
@override@JsonKey(name: 'answer_distribution') Map<dynamic, int>? get answerDistribution {
  final value = _answerDistribution;
  if (value == null) return null;
  if (_answerDistribution is EqualUnmodifiableMapView) return _answerDistribution;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Animation state properties
@override@JsonKey(name: 'showing_feedback') final  bool showingFeedback;
@override@JsonKey(name: 'showing_correct_answer') final  bool showingCorrectAnswer;
@override@JsonKey(name: 'showing_leaderboard') final  bool showingLeaderboard;
@override@JsonKey(name: 'feedback_countdown') final  int feedbackCountdown;
// Role and score properties
@override@JsonKey(name: 'is_host') final  bool isHost;
@override@JsonKey(name: 'current_score') final  int currentScore;
// Partial credit properties
@override@JsonKey(name: 'is_partial') final  bool isPartial;
@override@JsonKey(name: 'partial_credit') final  double? partialCredit;
// Streak properties
@override@JsonKey(name: 'streak') final  int streak;
@override@JsonKey(name: 'streak_bonus') final  int streakBonus;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameStateCopyWith<_GameState> get copyWith => __$GameStateCopyWithImpl<_GameState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameState&&const DeepCollectionEquality().equals(other._currentQuestion, _currentQuestion)&&(identical(other.questionIndex, questionIndex) || other.questionIndex == questionIndex)&&(identical(other.totalQuestions, totalQuestions) || other.totalQuestions == totalQuestions)&&(identical(other.timeRemaining, timeRemaining) || other.timeRemaining == timeRemaining)&&(identical(other.timeLimit, timeLimit) || other.timeLimit == timeLimit)&&(identical(other.hasAnswered, hasAnswered) || other.hasAnswered == hasAnswered)&&(identical(other.isCorrect, isCorrect) || other.isCorrect == isCorrect)&&(identical(other.pointsEarned, pointsEarned) || other.pointsEarned == pointsEarned)&&(identical(other.timeBonus, timeBonus) || other.timeBonus == timeBonus)&&(identical(other.multiplier, multiplier) || other.multiplier == multiplier)&&const DeepCollectionEquality().equals(other.correctAnswer, correctAnswer)&&const DeepCollectionEquality().equals(other._rankings, _rankings)&&(identical(other.lastAnswerCorrect, lastAnswerCorrect) || other.lastAnswerCorrect == lastAnswerCorrect)&&const DeepCollectionEquality().equals(other.selectedAnswer, selectedAnswer)&&const DeepCollectionEquality().equals(other._answerDistribution, _answerDistribution)&&(identical(other.showingFeedback, showingFeedback) || other.showingFeedback == showingFeedback)&&(identical(other.showingCorrectAnswer, showingCorrectAnswer) || other.showingCorrectAnswer == showingCorrectAnswer)&&(identical(other.showingLeaderboard, showingLeaderboard) || other.showingLeaderboard == showingLeaderboard)&&(identical(other.feedbackCountdown, feedbackCountdown) || other.feedbackCountdown == feedbackCountdown)&&(identical(other.isHost, isHost) || other.isHost == isHost)&&(identical(other.currentScore, currentScore) || other.currentScore == currentScore)&&(identical(other.isPartial, isPartial) || other.isPartial == isPartial)&&(identical(other.partialCredit, partialCredit) || other.partialCredit == partialCredit)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.streakBonus, streakBonus) || other.streakBonus == streakBonus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_currentQuestion),questionIndex,totalQuestions,timeRemaining,timeLimit,hasAnswered,isCorrect,pointsEarned,timeBonus,multiplier,const DeepCollectionEquality().hash(correctAnswer),const DeepCollectionEquality().hash(_rankings),lastAnswerCorrect,const DeepCollectionEquality().hash(selectedAnswer),const DeepCollectionEquality().hash(_answerDistribution),showingFeedback,showingCorrectAnswer,showingLeaderboard,feedbackCountdown,isHost,currentScore,isPartial,partialCredit,streak,streakBonus]);

@override
String toString() {
  return 'GameState(currentQuestion: $currentQuestion, questionIndex: $questionIndex, totalQuestions: $totalQuestions, timeRemaining: $timeRemaining, timeLimit: $timeLimit, hasAnswered: $hasAnswered, isCorrect: $isCorrect, pointsEarned: $pointsEarned, timeBonus: $timeBonus, multiplier: $multiplier, correctAnswer: $correctAnswer, rankings: $rankings, lastAnswerCorrect: $lastAnswerCorrect, selectedAnswer: $selectedAnswer, answerDistribution: $answerDistribution, showingFeedback: $showingFeedback, showingCorrectAnswer: $showingCorrectAnswer, showingLeaderboard: $showingLeaderboard, feedbackCountdown: $feedbackCountdown, isHost: $isHost, currentScore: $currentScore, isPartial: $isPartial, partialCredit: $partialCredit, streak: $streak, streakBonus: $streakBonus)';
}


}

/// @nodoc
abstract mixin class _$GameStateCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory _$GameStateCopyWith(_GameState value, $Res Function(_GameState) _then) = __$GameStateCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'current_question') Map<String, dynamic>? currentQuestion,@JsonKey(name: 'question_index') int questionIndex,@JsonKey(name: 'total_questions') int totalQuestions,@JsonKey(name: 'time_remaining') int timeRemaining,@JsonKey(name: 'time_limit') int timeLimit,@JsonKey(name: 'has_answered') bool hasAnswered,@JsonKey(name: 'is_correct') bool? isCorrect,@JsonKey(name: 'points_earned') int? pointsEarned,@JsonKey(name: 'time_bonus') int? timeBonus,@JsonKey(name: 'multiplier') double? multiplier,@JsonKey(name: 'correct_answer') dynamic correctAnswer, List<Map<String, dynamic>>? rankings,@JsonKey(name: 'last_answer_correct') bool? lastAnswerCorrect,@JsonKey(name: 'selected_answer') dynamic selectedAnswer,@JsonKey(name: 'answer_distribution') Map<dynamic, int>? answerDistribution,@JsonKey(name: 'showing_feedback') bool showingFeedback,@JsonKey(name: 'showing_correct_answer') bool showingCorrectAnswer,@JsonKey(name: 'showing_leaderboard') bool showingLeaderboard,@JsonKey(name: 'feedback_countdown') int feedbackCountdown,@JsonKey(name: 'is_host') bool isHost,@JsonKey(name: 'current_score') int currentScore,@JsonKey(name: 'is_partial') bool isPartial,@JsonKey(name: 'partial_credit') double? partialCredit,@JsonKey(name: 'streak') int streak,@JsonKey(name: 'streak_bonus') int streakBonus
});




}
/// @nodoc
class __$GameStateCopyWithImpl<$Res>
    implements _$GameStateCopyWith<$Res> {
  __$GameStateCopyWithImpl(this._self, this._then);

  final _GameState _self;
  final $Res Function(_GameState) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentQuestion = freezed,Object? questionIndex = null,Object? totalQuestions = null,Object? timeRemaining = null,Object? timeLimit = null,Object? hasAnswered = null,Object? isCorrect = freezed,Object? pointsEarned = freezed,Object? timeBonus = freezed,Object? multiplier = freezed,Object? correctAnswer = freezed,Object? rankings = freezed,Object? lastAnswerCorrect = freezed,Object? selectedAnswer = freezed,Object? answerDistribution = freezed,Object? showingFeedback = null,Object? showingCorrectAnswer = null,Object? showingLeaderboard = null,Object? feedbackCountdown = null,Object? isHost = null,Object? currentScore = null,Object? isPartial = null,Object? partialCredit = freezed,Object? streak = null,Object? streakBonus = null,}) {
  return _then(_GameState(
currentQuestion: freezed == currentQuestion ? _self._currentQuestion : currentQuestion // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,questionIndex: null == questionIndex ? _self.questionIndex : questionIndex // ignore: cast_nullable_to_non_nullable
as int,totalQuestions: null == totalQuestions ? _self.totalQuestions : totalQuestions // ignore: cast_nullable_to_non_nullable
as int,timeRemaining: null == timeRemaining ? _self.timeRemaining : timeRemaining // ignore: cast_nullable_to_non_nullable
as int,timeLimit: null == timeLimit ? _self.timeLimit : timeLimit // ignore: cast_nullable_to_non_nullable
as int,hasAnswered: null == hasAnswered ? _self.hasAnswered : hasAnswered // ignore: cast_nullable_to_non_nullable
as bool,isCorrect: freezed == isCorrect ? _self.isCorrect : isCorrect // ignore: cast_nullable_to_non_nullable
as bool?,pointsEarned: freezed == pointsEarned ? _self.pointsEarned : pointsEarned // ignore: cast_nullable_to_non_nullable
as int?,timeBonus: freezed == timeBonus ? _self.timeBonus : timeBonus // ignore: cast_nullable_to_non_nullable
as int?,multiplier: freezed == multiplier ? _self.multiplier : multiplier // ignore: cast_nullable_to_non_nullable
as double?,correctAnswer: freezed == correctAnswer ? _self.correctAnswer : correctAnswer // ignore: cast_nullable_to_non_nullable
as dynamic,rankings: freezed == rankings ? _self._rankings : rankings // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,lastAnswerCorrect: freezed == lastAnswerCorrect ? _self.lastAnswerCorrect : lastAnswerCorrect // ignore: cast_nullable_to_non_nullable
as bool?,selectedAnswer: freezed == selectedAnswer ? _self.selectedAnswer : selectedAnswer // ignore: cast_nullable_to_non_nullable
as dynamic,answerDistribution: freezed == answerDistribution ? _self._answerDistribution : answerDistribution // ignore: cast_nullable_to_non_nullable
as Map<dynamic, int>?,showingFeedback: null == showingFeedback ? _self.showingFeedback : showingFeedback // ignore: cast_nullable_to_non_nullable
as bool,showingCorrectAnswer: null == showingCorrectAnswer ? _self.showingCorrectAnswer : showingCorrectAnswer // ignore: cast_nullable_to_non_nullable
as bool,showingLeaderboard: null == showingLeaderboard ? _self.showingLeaderboard : showingLeaderboard // ignore: cast_nullable_to_non_nullable
as bool,feedbackCountdown: null == feedbackCountdown ? _self.feedbackCountdown : feedbackCountdown // ignore: cast_nullable_to_non_nullable
as int,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,currentScore: null == currentScore ? _self.currentScore : currentScore // ignore: cast_nullable_to_non_nullable
as int,isPartial: null == isPartial ? _self.isPartial : isPartial // ignore: cast_nullable_to_non_nullable
as bool,partialCredit: freezed == partialCredit ? _self.partialCredit : partialCredit // ignore: cast_nullable_to_non_nullable
as double?,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,streakBonus: null == streakBonus ? _self.streakBonus : streakBonus // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$LeaderboardEntry {

 int get rank;@JsonKey(name: 'user_id') String get userId; int get score;
/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaderboardEntryCopyWith<LeaderboardEntry> get copyWith => _$LeaderboardEntryCopyWithImpl<LeaderboardEntry>(this as LeaderboardEntry, _$identity);

  /// Serializes this LeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaderboardEntry&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.score, score) || other.score == score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,userId,score);

@override
String toString() {
  return 'LeaderboardEntry(rank: $rank, userId: $userId, score: $score)';
}


}

/// @nodoc
abstract mixin class $LeaderboardEntryCopyWith<$Res>  {
  factory $LeaderboardEntryCopyWith(LeaderboardEntry value, $Res Function(LeaderboardEntry) _then) = _$LeaderboardEntryCopyWithImpl;
@useResult
$Res call({
 int rank,@JsonKey(name: 'user_id') String userId, int score
});




}
/// @nodoc
class _$LeaderboardEntryCopyWithImpl<$Res>
    implements $LeaderboardEntryCopyWith<$Res> {
  _$LeaderboardEntryCopyWithImpl(this._self, this._then);

  final LeaderboardEntry _self;
  final $Res Function(LeaderboardEntry) _then;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rank = null,Object? userId = null,Object? score = null,}) {
  return _then(_self.copyWith(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaderboardEntry].
extension LeaderboardEntryPatterns on LeaderboardEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaderboardEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaderboardEntry value)  $default,){
final _that = this;
switch (_that) {
case _LeaderboardEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaderboardEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rank, @JsonKey(name: 'user_id')  String userId,  int score)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that.rank,_that.userId,_that.score);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rank, @JsonKey(name: 'user_id')  String userId,  int score)  $default,) {final _that = this;
switch (_that) {
case _LeaderboardEntry():
return $default(_that.rank,_that.userId,_that.score);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rank, @JsonKey(name: 'user_id')  String userId,  int score)?  $default,) {final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that.rank,_that.userId,_that.score);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaderboardEntry implements LeaderboardEntry {
  const _LeaderboardEntry({required this.rank, @JsonKey(name: 'user_id') required this.userId, required this.score});
  factory _LeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryFromJson(json);

@override final  int rank;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  int score;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaderboardEntryCopyWith<_LeaderboardEntry> get copyWith => __$LeaderboardEntryCopyWithImpl<_LeaderboardEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaderboardEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaderboardEntry&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.score, score) || other.score == score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,userId,score);

@override
String toString() {
  return 'LeaderboardEntry(rank: $rank, userId: $userId, score: $score)';
}


}

/// @nodoc
abstract mixin class _$LeaderboardEntryCopyWith<$Res> implements $LeaderboardEntryCopyWith<$Res> {
  factory _$LeaderboardEntryCopyWith(_LeaderboardEntry value, $Res Function(_LeaderboardEntry) _then) = __$LeaderboardEntryCopyWithImpl;
@override @useResult
$Res call({
 int rank,@JsonKey(name: 'user_id') String userId, int score
});




}
/// @nodoc
class __$LeaderboardEntryCopyWithImpl<$Res>
    implements _$LeaderboardEntryCopyWith<$Res> {
  __$LeaderboardEntryCopyWithImpl(this._self, this._then);

  final _LeaderboardEntry _self;
  final $Res Function(_LeaderboardEntry) _then;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rank = null,Object? userId = null,Object? score = null,}) {
  return _then(_LeaderboardEntry(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$LeaderboardState {

 List<LeaderboardEntry> get rankings;@JsonKey(name: 'current_user_entry') LeaderboardEntry? get currentUserEntry;
/// Create a copy of LeaderboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaderboardStateCopyWith<LeaderboardState> get copyWith => _$LeaderboardStateCopyWithImpl<LeaderboardState>(this as LeaderboardState, _$identity);

  /// Serializes this LeaderboardState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaderboardState&&const DeepCollectionEquality().equals(other.rankings, rankings)&&(identical(other.currentUserEntry, currentUserEntry) || other.currentUserEntry == currentUserEntry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(rankings),currentUserEntry);

@override
String toString() {
  return 'LeaderboardState(rankings: $rankings, currentUserEntry: $currentUserEntry)';
}


}

/// @nodoc
abstract mixin class $LeaderboardStateCopyWith<$Res>  {
  factory $LeaderboardStateCopyWith(LeaderboardState value, $Res Function(LeaderboardState) _then) = _$LeaderboardStateCopyWithImpl;
@useResult
$Res call({
 List<LeaderboardEntry> rankings,@JsonKey(name: 'current_user_entry') LeaderboardEntry? currentUserEntry
});


$LeaderboardEntryCopyWith<$Res>? get currentUserEntry;

}
/// @nodoc
class _$LeaderboardStateCopyWithImpl<$Res>
    implements $LeaderboardStateCopyWith<$Res> {
  _$LeaderboardStateCopyWithImpl(this._self, this._then);

  final LeaderboardState _self;
  final $Res Function(LeaderboardState) _then;

/// Create a copy of LeaderboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rankings = null,Object? currentUserEntry = freezed,}) {
  return _then(_self.copyWith(
rankings: null == rankings ? _self.rankings : rankings // ignore: cast_nullable_to_non_nullable
as List<LeaderboardEntry>,currentUserEntry: freezed == currentUserEntry ? _self.currentUserEntry : currentUserEntry // ignore: cast_nullable_to_non_nullable
as LeaderboardEntry?,
  ));
}
/// Create a copy of LeaderboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeaderboardEntryCopyWith<$Res>? get currentUserEntry {
    if (_self.currentUserEntry == null) {
    return null;
  }

  return $LeaderboardEntryCopyWith<$Res>(_self.currentUserEntry!, (value) {
    return _then(_self.copyWith(currentUserEntry: value));
  });
}
}


/// Adds pattern-matching-related methods to [LeaderboardState].
extension LeaderboardStatePatterns on LeaderboardState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaderboardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaderboardState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaderboardState value)  $default,){
final _that = this;
switch (_that) {
case _LeaderboardState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaderboardState value)?  $default,){
final _that = this;
switch (_that) {
case _LeaderboardState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LeaderboardEntry> rankings, @JsonKey(name: 'current_user_entry')  LeaderboardEntry? currentUserEntry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaderboardState() when $default != null:
return $default(_that.rankings,_that.currentUserEntry);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LeaderboardEntry> rankings, @JsonKey(name: 'current_user_entry')  LeaderboardEntry? currentUserEntry)  $default,) {final _that = this;
switch (_that) {
case _LeaderboardState():
return $default(_that.rankings,_that.currentUserEntry);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LeaderboardEntry> rankings, @JsonKey(name: 'current_user_entry')  LeaderboardEntry? currentUserEntry)?  $default,) {final _that = this;
switch (_that) {
case _LeaderboardState() when $default != null:
return $default(_that.rankings,_that.currentUserEntry);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaderboardState implements LeaderboardState {
  const _LeaderboardState({final  List<LeaderboardEntry> rankings = const [], @JsonKey(name: 'current_user_entry') this.currentUserEntry}): _rankings = rankings;
  factory _LeaderboardState.fromJson(Map<String, dynamic> json) => _$LeaderboardStateFromJson(json);

 final  List<LeaderboardEntry> _rankings;
@override@JsonKey() List<LeaderboardEntry> get rankings {
  if (_rankings is EqualUnmodifiableListView) return _rankings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rankings);
}

@override@JsonKey(name: 'current_user_entry') final  LeaderboardEntry? currentUserEntry;

/// Create a copy of LeaderboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaderboardStateCopyWith<_LeaderboardState> get copyWith => __$LeaderboardStateCopyWithImpl<_LeaderboardState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaderboardStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaderboardState&&const DeepCollectionEquality().equals(other._rankings, _rankings)&&(identical(other.currentUserEntry, currentUserEntry) || other.currentUserEntry == currentUserEntry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rankings),currentUserEntry);

@override
String toString() {
  return 'LeaderboardState(rankings: $rankings, currentUserEntry: $currentUserEntry)';
}


}

/// @nodoc
abstract mixin class _$LeaderboardStateCopyWith<$Res> implements $LeaderboardStateCopyWith<$Res> {
  factory _$LeaderboardStateCopyWith(_LeaderboardState value, $Res Function(_LeaderboardState) _then) = __$LeaderboardStateCopyWithImpl;
@override @useResult
$Res call({
 List<LeaderboardEntry> rankings,@JsonKey(name: 'current_user_entry') LeaderboardEntry? currentUserEntry
});


@override $LeaderboardEntryCopyWith<$Res>? get currentUserEntry;

}
/// @nodoc
class __$LeaderboardStateCopyWithImpl<$Res>
    implements _$LeaderboardStateCopyWith<$Res> {
  __$LeaderboardStateCopyWithImpl(this._self, this._then);

  final _LeaderboardState _self;
  final $Res Function(_LeaderboardState) _then;

/// Create a copy of LeaderboardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rankings = null,Object? currentUserEntry = freezed,}) {
  return _then(_LeaderboardState(
rankings: null == rankings ? _self._rankings : rankings // ignore: cast_nullable_to_non_nullable
as List<LeaderboardEntry>,currentUserEntry: freezed == currentUserEntry ? _self.currentUserEntry : currentUserEntry // ignore: cast_nullable_to_non_nullable
as LeaderboardEntry?,
  ));
}

/// Create a copy of LeaderboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeaderboardEntryCopyWith<$Res>? get currentUserEntry {
    if (_self.currentUserEntry == null) {
    return null;
  }

  return $LeaderboardEntryCopyWith<$Res>(_self.currentUserEntry!, (value) {
    return _then(_self.copyWith(currentUserEntry: value));
  });
}
}

// dart format on
