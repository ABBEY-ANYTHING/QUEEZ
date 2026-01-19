import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_host_view.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_lobby.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_quiz.dart';
import 'package:quiz_app/LibrarySection/screens/hosting_page.dart';
import 'package:quiz_app/providers/game_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/services/active_session_service.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/widgets/core/app_dialog.dart';

/// Simple Notifier to track if active session check has been performed this app session
class ActiveSessionCheckNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void markDone() => state = true;
  void reset() => state = false;
}

final activeSessionCheckDoneProvider =
    NotifierProvider<ActiveSessionCheckNotifier, bool>(
      ActiveSessionCheckNotifier.new,
    );

/// Widget that checks for active session on app startup and offers to rejoin
class ActiveSessionChecker extends ConsumerStatefulWidget {
  final Widget child;

  const ActiveSessionChecker({super.key, required this.child});

  @override
  ConsumerState<ActiveSessionChecker> createState() =>
      _ActiveSessionCheckerState();
}

class _ActiveSessionCheckerState extends ConsumerState<ActiveSessionChecker> {
  bool _isChecking =
      false; // Start false - only show loading when we have something to check
  bool _showRejoinPrompt = false;
  Map<String, dynamic>? _activeSessionInfo;

  @override
  void initState() {
    super.initState();
    _checkForActiveSession();
  }

  Future<void> _checkForActiveSession() async {
    // Only check once per app session
    if (ref.read(activeSessionCheckDoneProvider)) {
      return;
    }

    try {
      // First get local session info to get the userId
      final localSession = await ActiveSessionService.getLocalActiveSession();

      if (localSession == null) {
        // No local session, nothing to check - no loading overlay needed
        ref.read(activeSessionCheckDoneProvider.notifier).markDone();
        return;
      }

      final userId = localSession['user_id'] as String?;
      if (userId == null) {
        await ActiveSessionService.clearActiveSession();
        ref.read(activeSessionCheckDoneProvider.notifier).markDone();
        return;
      }

      // We have a local session - NOW show loading while we verify with backend
      if (mounted) {
        setState(() => _isChecking = true);
      }

      // Check with backend
      final result = await ActiveSessionService.checkActiveSessionWithBackend(
        userId,
      );

      if (result != null && result['has_active_session'] == true) {
        // Merge local session info for username and quiz details
        // Backend provides: session_code, status, quiz_id, quiz_title, mode, is_host, participant_count
        // Local provides: username (more reliable), quiz_id/title/mode (as fallback)
        result['username'] = localSession['username'];
        result['is_host'] = localSession['is_host'] ?? result['is_host'];
        result['user_id'] = userId; // Ensure user_id is set

        // Use backend values if available, fallback to local
        result['quiz_id'] = result['quiz_id'] ?? localSession['quiz_id'];
        result['quiz_title'] =
            result['quiz_title'] ?? localSession['quiz_title'];
        result['mode'] = result['mode'] ?? localSession['mode'];

        AppLogger.debug('ACTIVE_SESSION_CHECKER - Found active session:');
        AppLogger.debug('   session_code: ${result['session_code']}');
        AppLogger.debug('   user_id: ${result['user_id']}');
        AppLogger.debug('   is_host: ${result['is_host']}');
        AppLogger.debug('   status: ${result['status']}');
        AppLogger.debug('   quiz_id: ${result['quiz_id']}');
        AppLogger.debug('   quiz_title: ${result['quiz_title']}');
        AppLogger.debug('   mode: ${result['mode']}');

        setState(() {
          _activeSessionInfo = result;
          _showRejoinPrompt = true;
          _isChecking = false;
        });
      } else {
        // No active session, clear any stale local data
        await ActiveSessionService.clearActiveSession();
        ref.read(activeSessionCheckDoneProvider.notifier).markDone();
        if (mounted) {
          setState(() => _isChecking = false);
        }
      }
    } catch (e) {
      AppLogger.error('ACTIVE_SESSION_CHECKER - Error checking: $e');
      ref.read(activeSessionCheckDoneProvider.notifier).markDone();
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _rejoinSession() async {
    if (_activeSessionInfo == null) {
      AppLogger.error('ACTIVE_SESSION_CHECKER - _activeSessionInfo is null');
      _showError('No session info available. Please start a new quiz.');
      await _dismissPrompt();
      return;
    }

    final sessionCode = _activeSessionInfo!['session_code'] as String?;
    final sessionStatus = _activeSessionInfo!['status'] as String?;
    final isHost = _activeSessionInfo!['is_host'] as bool? ?? false;
    final userId = _activeSessionInfo!['user_id'] as String?;
    final username = _activeSessionInfo!['username'] as String? ?? 'Player';
    final quizId = _activeSessionInfo!['quiz_id'] as String?;
    final quizTitle = _activeSessionInfo!['quiz_title'] as String? ?? 'Quiz';
    final mode = _activeSessionInfo!['mode'] as String? ?? 'live_multiplayer';

    AppLogger.debug('ACTIVE_SESSION_CHECKER - Rejoin data:');
    AppLogger.debug('   sessionCode: $sessionCode');
    AppLogger.debug('   userId: $userId');
    AppLogger.debug('   isHost: $isHost');
    AppLogger.debug('   status: $sessionStatus');
    AppLogger.debug('   quizId: $quizId');
    AppLogger.debug('   quizTitle: $quizTitle');
    AppLogger.debug('   mode: $mode');

    if (sessionCode == null || userId == null) {
      AppLogger.error('ACTIVE_SESSION_CHECKER - Missing required data');
      AppLogger.debug('   sessionCode null: ${sessionCode == null}');
      AppLogger.debug('   userId null: ${userId == null}');
      _showError('Invalid session data. Please start a new quiz.');
      await _dismissPrompt();
      return;
    }

    AppLogger.debug(
      'ACTIVE_SESSION_CHECKER - Rejoining session $sessionCode as ${isHost ? "host" : "participant"}',
    );
    AppLogger.debug('Session status: $sessionStatus');

    // Mark as done before navigating
    ref.read(activeSessionCheckDoneProvider.notifier).markDone();
    setState(() {
      _showRejoinPrompt = false;
      _isChecking = true; // Show loading while connecting
    });

    try {
      if (isHost) {
        // HOST RECONNECTION: Connect to WebSocket first, then navigate
        AppLogger.debug('HOST RECONNECTION - Connecting to WebSocket first');
        ref.read(currentUserProvider.notifier).setUser(userId);

        // ✅ FIX: Initialize gameProvider BEFORE joining to ensure it receives messages
        // This triggers gameProvider.build() which sets up the WebSocket listener
        ref.read(gameProvider);
        AppLogger.success('HOST RECONNECTION - gameProvider initialized');

        // Connect to WebSocket as host
        await ref
            .read(sessionProvider.notifier)
            .joinSession(sessionCode, userId, username, isHost: true);

        AppLogger.success('HOST RECONNECTION - WebSocket connected');

        // Restore active session tracking with quiz info
        await ActiveSessionService.saveActiveSession(
          sessionCode: sessionCode,
          userId: userId,
          username: username,
          isHost: true,
          quizId: quizId,
          quizTitle: quizTitle,
          mode: mode,
        );
      } else {
        // PARTICIPANT: Join the session via the provider
        await ref
            .read(sessionProvider.notifier)
            .joinSession(sessionCode, userId, username, isHost: false);
      }

      if (!mounted) return;

      // Navigate based on session status and role
      if (sessionStatus == 'active' || sessionStatus == 'completed') {
        // Quiz is in progress OR completed - Host sees LiveHostView (leaderboard/podium)
        if (isHost) {
          AppLogger.debug(
            'HOST RECONNECTION - Navigating to LiveHostView (status: $sessionStatus)',
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => LiveHostView(sessionCode: sessionCode),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LiveMultiplayerQuiz(),
            ),
          );
        }
      } else if (sessionStatus == 'waiting') {
        // Still in lobby - Host goes to HostingPage (Dashboard), Participants go to lobby
        if (isHost && quizId != null) {
          AppLogger.debug(
            'HOST RECONNECTION - Navigating to HostingPage (Dashboard)',
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HostingPage(
                itemId: quizId,
                itemTitle: quizTitle,
                mode: mode,
                hostId: userId,
                existingSessionCode: sessionCode, // Skip session creation
              ),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => LiveMultiplayerLobby(
                sessionCode: sessionCode,
                isHost: isHost,
              ),
            ),
          );
        }
      } else {
        // Unknown status - clear and show error
        AppLogger.error(
          'ACTIVE_SESSION_CHECKER - Unknown status: $sessionStatus',
        );
        _showError('Session status unknown. Please start a new quiz.');
        await ActiveSessionService.fullCleanup(userId);
        setState(() => _isChecking = false);
      }
    } catch (e) {
      AppLogger.error('ACTIVE_SESSION_CHECKER - Error rejoining: $e');
      _showError('Could not rejoin the session. It may have ended.');
      await ActiveSessionService.clearActiveSession();
      setState(() => _isChecking = false);
    }
  }

  Future<void> _dismissPrompt() async {
    final userId = _activeSessionInfo?['user_id'] as String?;

    // Clear both local and remote active session
    if (userId != null) {
      await ActiveSessionService.fullCleanup(userId);
    } else {
      await ActiveSessionService.clearActiveSession();
    }

    ref.read(activeSessionCheckDoneProvider.notifier).markDone();
    setState(() {
      _showRejoinPrompt = false;
      _activeSessionInfo = null;
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If checking, show child with loading overlay briefly
    if (_isChecking) {
      return Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: Material(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Checking for active quiz...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // If rejoin prompt, show AppDialog
    if (_showRejoinPrompt && _activeSessionInfo != null) {
      final sessionCode = _activeSessionInfo!['session_code'] ?? 'Unknown';
      final quizTitle = _activeSessionInfo!['quiz_title'] ?? 'Live Quiz';
      final sessionStatus = _activeSessionInfo!['status'] ?? 'active';
      final isHost = _activeSessionInfo!['is_host'] ?? false;
      final participantCount = _activeSessionInfo!['participant_count'] ?? 0;

      // Show AppDialog after frame renders
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_showRejoinPrompt && mounted) {
          AppDialog.show(
            context: context,
            title: 'Rejoin Quiz?',
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have an active session for "$quizTitle".',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  'Session: $sessionCode',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Status: ${_getStatusText(sessionStatus)}',
                  style: const TextStyle(fontSize: 14),
                ),
                if (participantCount > 0)
                  Text(
                    'Players: $participantCount',
                    style: const TextStyle(fontSize: 14),
                  ),
                if (isHost)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'You are the host of this session.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
            primaryActionText: 'Rejoin',
            primaryActionCallback: () {
              Navigator.of(context).pop();
              _rejoinSession();
            },
            secondaryActionText: 'Dismiss',
            secondaryActionCallback: () {
              Navigator.of(context).pop();
              _dismissPrompt();
            },
            dismissible: false,
          );
          // Prevent showing again
          setState(() => _showRejoinPrompt = false);
        }
      });
    }

    // Normal state - just show child
    return widget.child;
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'waiting':
        return 'In Lobby';
      case 'active':
        return 'Quiz Running';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }
}
