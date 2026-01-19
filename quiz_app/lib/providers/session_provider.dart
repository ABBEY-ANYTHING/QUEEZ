import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/multiplayer_models.dart';
import 'package:quiz_app/services/active_session_service.dart';
import 'package:quiz_app/services/websocket_service.dart';
import 'package:quiz_app/utils/app_logger.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});

final sessionProvider = NotifierProvider<SessionNotifier, SessionState?>(
  SessionNotifier.new,
);

final currentUserProvider = NotifierProvider<CurrentUserNotifier, String?>(
  CurrentUserNotifier.new,
);

class CurrentUserNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setUser(String userId) {
    state = userId;
  }
}

final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.connectionStatusStream;
});

class SessionNotifier extends Notifier<SessionState?> {
  late final WebSocketService _wsService;
  Completer<void>? _joinCompleter;

  @override
  SessionState? build() {
    _wsService = ref.watch(webSocketServiceProvider);
    _wsService.messageStream.listen((message) {
      _handleMessage(message);
    });
    return null;
  }

  Future<void> joinSession(
    String sessionCode,
    String userId,
    String username, {
    bool isHost = false,
  }) async {
    AppLogger.debug(
      'Joining session $sessionCode as $username (host: $isHost)',
    );
    _joinCompleter = Completer<void>();

    ref.read(currentUserProvider.notifier).setUser(userId);

    AppLogger.network('Connecting to WebSocket...');
    await _wsService.connect(sessionCode, userId);

    // Wait for connection to stabilize through ngrok
    AppLogger.debug('Waiting for connection to stabilize...');
    await Future.delayed(const Duration(milliseconds: 1000));

    AppLogger.debug('Sending join message...');
    // Send join message ONCE
    _wsService.sendMessage('join', {
      'session_code': sessionCode,
      'user_id': userId,
      'username': username,
    });

    AppLogger.debug('Waiting for server response...');
    // Wait for session_state response
    try {
      await _joinCompleter!.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          AppLogger.warning('Join timeout - checking if we have any state...');
          // If we received session_update but not session_state, that's okay
          if (state != null) {
            AppLogger.success('Have state from session_update, proceeding');
            return;
          }
          throw TimeoutException(
            'Connection timeout. Please check your internet and try again.',
          );
        },
      );

      // Save active session for reconnection (skip for hosts - already saved in HostingPage)
      if (!isHost) {
        await ActiveSessionService.saveActiveSession(
          sessionCode: sessionCode,
          userId: userId,
          username: username,
          isHost: false,
        );
      }

      AppLogger.success('Joined session successfully');
    } catch (e) {
      AppLogger.error('Join failed: $e');
      _joinCompleter = null;
      rethrow;
    }
  }

  /// Leave the current session and clean up
  Future<void> leaveSession(String userId) async {
    AppLogger.debug('Leaving session...');
    _wsService.disconnect();
    state = null;
    await ActiveSessionService.fullCleanup(userId);
    AppLogger.success('Left session and cleaned up');
  }

  void startQuiz({int? perQuestionTimeLimit}) {
    AppLogger.debug('HOST - Sending start_quiz message');
    if (!_wsService.isConnected) {
      AppLogger.warning('HOST - WebSocket not connected! Cannot start quiz.');
      _errorController.add('Not connected to session. Please refresh.');
      return;
    }
    _wsService.sendMessage('start_quiz', {
      'per_question_time_limit': perQuestionTimeLimit ?? 30,
    });
  }

  void endQuiz() {
    _wsService.sendMessage('end_quiz');
  }

  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  Stream<String> get errorStream => _errorController.stream;

  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type'];
    final payload = message['payload'];

    AppLogger.debug('FLUTTER - Received message type: $type');

    if (type == 'error') {
      final errorMessage = payload['message'] ?? 'An unknown error occurred';
      AppLogger.error('FLUTTER - Error received: $errorMessage');
      _errorController.add(errorMessage);
      // Complete join with error if waiting
      if (_joinCompleter != null && !_joinCompleter!.isCompleted) {
        final completer = _joinCompleter;
        _joinCompleter = null;
        completer?.completeError(Exception(errorMessage));
      }
    } else if (type == 'session_state') {
      AppLogger.success('FLUTTER - Session state received, completing join');
      AppLogger.debug('Raw payload: $payload');
      try {
        state = SessionState.fromJson(payload);
        AppLogger.success('Successfully parsed SessionState');
        // Complete join successfully if waiting
        if (_joinCompleter != null && !_joinCompleter!.isCompleted) {
          final completer = _joinCompleter;
          _joinCompleter = null;
          completer?.complete();
        }
      } catch (e, stackTrace) {
        AppLogger.error('Failed to parse session_state: $e');
        AppLogger.error('Stack trace: $stackTrace');
        if (_joinCompleter != null && !_joinCompleter!.isCompleted) {
          final completer = _joinCompleter;
          _joinCompleter = null;
          completer?.completeError(e);
        }
      }
    } else if (type == 'session_update') {
      AppLogger.debug('FLUTTER - Session update received');

      if (state != null) {
        // Update existing state
        state = state!.copyWith(
          status: payload['status'],
          participantCount: payload['participant_count'],
          participants: (payload['participants'] as List)
              .map((e) => Participant.fromJson(e))
              .toList(),
        );
      }

      // If we're waiting for join confirmation, session_update means we're in
      if (_joinCompleter != null && !_joinCompleter!.isCompleted) {
        if (state == null) {
          AppLogger.debug(
            'FLUTTER - Session update received, waiting for full state...',
          );
        } else {
          AppLogger.success('FLUTTER - Join confirmed with session_update');
          final completer = _joinCompleter;
          _joinCompleter = null;
          completer?.complete();
        }
      }
    } else if (type == 'quiz_started') {
      AppLogger.debug('FLUTTER - Quiz started!');
      final overallTimeLimit = payload['overall_time_limit'] as int? ?? 0;
      final perQuestionTimeLimit =
          payload['per_question_time_limit'] as int? ?? 30;
      AppLogger.debug(
        'Time settings: overall=${overallTimeLimit}s, perQuestion=${perQuestionTimeLimit}s',
      );

      if (state != null) {
        AppLogger.debug('FLUTTER - Updating state status to active');
        state = state!.copyWith(status: 'active');
      } else {
        // Edge case: state is null but we received quiz_started
        // This can happen if host reconnects and WebSocket hasn't fully synced
        AppLogger.warning('FLUTTER - State is null but quiz_started received');
        // Create a minimal state so navigation can work
        state = SessionState(
          sessionCode: '',
          quizId: '',
          hostId: '',
          status: 'active',
          participants: [],
          participantCount: 0,
        );
      }
      AppLogger.success('FLUTTER - State status is now: ${state?.status}');
      // Time settings will be handled by game_provider when it receives the first question
    } else if (type == 'quiz_completed' || type == 'quiz_ended') {
      AppLogger.debug('FLUTTER - Quiz completed/ended');
      final hostEnded = payload['host_ended'] == true;
      AppLogger.debug('Host manually ended: $hostEnded');

      if (state != null) {
        state = state!.copyWith(status: 'completed', hostEndedQuiz: hostEnded);
      }
      // Clear active session since quiz is done
      final userId = ref.read(currentUserProvider);
      if (userId != null) {
        ActiveSessionService.clearActiveSession();
      }
    } else if (type == 'host_disconnected') {
      AppLogger.warning('FLUTTER - Host disconnected');
      final message = payload['message'] ?? 'Host has disconnected';
      _errorController.add(message);
      // Quiz can continue in self-paced mode, just notify user
    } else if (type == 'host_reconnected') {
      AppLogger.success('FLUTTER - Host reconnected');
      // Could show a toast notification here
    }
    // ✅ REMOVED: Don't handle 'question', 'answer_result', etc. here
    // Let game_provider handle those
  }
}
