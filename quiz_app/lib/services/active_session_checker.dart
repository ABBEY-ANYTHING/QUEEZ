import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_host_view.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_lobby.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_quiz.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/services/active_session_service.dart';
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
        // Merge local session info for username etc
        result['username'] = localSession['username'];
        result['is_host'] = localSession['is_host'] ?? result['is_host'];
        result['user_id'] = userId; // Ensure user_id is set

        debugPrint('🔄 ACTIVE_SESSION_CHECKER - Found active session:');
        debugPrint('   session_code: ${result['session_code']}');
        debugPrint('   user_id: ${result['user_id']}');
        debugPrint('   is_host: ${result['is_host']}');
        debugPrint('   status: ${result['status']}');

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
      debugPrint('❌ ACTIVE_SESSION_CHECKER - Error checking: $e');
      ref.read(activeSessionCheckDoneProvider.notifier).markDone();
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _rejoinSession() async {
    if (_activeSessionInfo == null) {
      debugPrint('❌ ACTIVE_SESSION_CHECKER - _activeSessionInfo is null');
      _showError('No session info available. Please start a new quiz.');
      await _dismissPrompt();
      return;
    }

    final sessionCode = _activeSessionInfo!['session_code'] as String?;
    final sessionStatus = _activeSessionInfo!['status'] as String?;
    final isHost = _activeSessionInfo!['is_host'] as bool? ?? false;
    final userId = _activeSessionInfo!['user_id'] as String?;
    final username = _activeSessionInfo!['username'] as String? ?? 'Player';

    debugPrint('🔄 ACTIVE_SESSION_CHECKER - Rejoin data:');
    debugPrint('   sessionCode: $sessionCode');
    debugPrint('   userId: $userId');
    debugPrint('   isHost: $isHost');
    debugPrint('   status: $sessionStatus');

    if (sessionCode == null || userId == null) {
      debugPrint('❌ ACTIVE_SESSION_CHECKER - Missing required data');
      debugPrint('   sessionCode null: ${sessionCode == null}');
      debugPrint('   userId null: ${userId == null}');
      _showError('Invalid session data. Please start a new quiz.');
      await _dismissPrompt();
      return;
    }

    debugPrint(
      '🔄 ACTIVE_SESSION_CHECKER - Rejoining session $sessionCode as ${isHost ? "host" : "participant"}',
    );
    debugPrint('📊 Session status: $sessionStatus');

    // Mark as done before navigating
    ref.read(activeSessionCheckDoneProvider.notifier).markDone();
    setState(() {
      _showRejoinPrompt = false;
      _isChecking = true; // Show loading while connecting
    });

    try {
      if (isHost) {
        // HOST RECONNECTION: Don't call joinSession - just set user and navigate
        debugPrint('🔄 HOST RECONNECTION - Skipping join, navigating directly');
        ref.read(currentUserProvider.notifier).setUser(userId);

        // Restore active session tracking
        await ActiveSessionService.saveActiveSession(
          sessionCode: sessionCode,
          userId: userId,
          username: username,
          isHost: true,
        );
      } else {
        // PARTICIPANT: Join the session via the provider
        await ref
            .read(sessionProvider.notifier)
            .joinSession(sessionCode, userId, username, isHost: false);
      }

      if (!mounted) return;

      // Navigate based on session status and role
      if (sessionStatus == 'active') {
        // Quiz is in progress
        if (isHost) {
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
        // Still in lobby
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                LiveMultiplayerLobby(sessionCode: sessionCode, isHost: isHost),
          ),
        );
      } else {
        // Session is completed or in unknown state
        _showError('The session has ended.');
        await ActiveSessionService.fullCleanup(userId);
        setState(() => _isChecking = false);
      }
    } catch (e) {
      debugPrint('❌ ACTIVE_SESSION_CHECKER - Error rejoining: $e');
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
