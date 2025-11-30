import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_host_view.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_lobby.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_quiz.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/services/active_session_service.dart';
import 'package:quiz_app/utils/color.dart';

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
  bool _isChecking = true;
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
      setState(() => _isChecking = false);
      return;
    }

    try {
      // First get local session info to get the userId
      final localSession = await ActiveSessionService.getLocalActiveSession();

      if (localSession == null) {
        // No local session, nothing to check
        ref.read(activeSessionCheckDoneProvider.notifier).markDone();
        setState(() => _isChecking = false);
        return;
      }

      final userId = localSession['user_id'] as String?;
      if (userId == null) {
        await ActiveSessionService.clearActiveSession();
        ref.read(activeSessionCheckDoneProvider.notifier).markDone();
        setState(() => _isChecking = false);
        return;
      }

      // Check with backend
      final result = await ActiveSessionService.checkActiveSessionWithBackend(
        userId,
      );

      if (result != null && result['has_active_session'] == true) {
        // Merge local session info for username etc
        result['username'] = localSession['username'];
        result['is_host'] = localSession['is_host'] ?? result['is_host'];

        setState(() {
          _activeSessionInfo = result;
          _showRejoinPrompt = true;
          _isChecking = false;
        });
      } else {
        // No active session, clear any stale local data
        await ActiveSessionService.clearActiveSession();
        ref.read(activeSessionCheckDoneProvider.notifier).markDone();
        setState(() => _isChecking = false);
      }
    } catch (e) {
      debugPrint('❌ ACTIVE_SESSION_CHECKER - Error checking: $e');
      ref.read(activeSessionCheckDoneProvider.notifier).markDone();
      setState(() => _isChecking = false);
    }
  }

  Future<void> _rejoinSession() async {
    if (_activeSessionInfo == null) return;

    final sessionCode = _activeSessionInfo!['session_code'] as String?;
    final sessionStatus = _activeSessionInfo!['session_status'] as String?;
    final isHost = _activeSessionInfo!['is_host'] as bool? ?? false;
    final userId = _activeSessionInfo!['user_id'] as String?;
    final username = _activeSessionInfo!['username'] as String? ?? 'Player';

    if (sessionCode == null || userId == null) {
      _showError('Invalid session data. Please start a new quiz.');
      await _dismissPrompt();
      return;
    }

    debugPrint(
      '🔄 ACTIVE_SESSION_CHECKER - Rejoining session $sessionCode as ${isHost ? "host" : "participant"}',
    );

    // Mark as done before navigating
    ref.read(activeSessionCheckDoneProvider.notifier).markDone();
    setState(() {
      _showRejoinPrompt = false;
      _isChecking = true; // Show loading while connecting
    });

    try {
      // Join the session via the provider (positional args)
      await ref
          .read(sessionProvider.notifier)
          .joinSession(sessionCode, userId, username, isHost: isHost);

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
            child: Container(
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

    // If rejoin prompt, show overlay
    if (_showRejoinPrompt && _activeSessionInfo != null) {
      final sessionCode = _activeSessionInfo!['session_code'] ?? 'Unknown';
      final quizTitle = _activeSessionInfo!['quiz_title'] ?? 'Live Quiz';
      final sessionStatus = _activeSessionInfo!['session_status'] ?? 'active';
      final isHost = _activeSessionInfo!['is_host'] ?? false;
      final participantCount = _activeSessionInfo!['participant_count'] ?? 0;

      return Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        'Quiz in Progress!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Quiz info
                      Text(
                        quizTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Session details
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('Session Code', sessionCode),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              'Status',
                              _getStatusText(sessionStatus),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              'Your Role',
                              isHost ? 'Host' : 'Participant',
                            ),
                            if (participantCount > 0) ...[
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'Players',
                                participantCount.toString(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _rejoinSession,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isHost ? 'REJOIN AS HOST' : 'REJOIN QUIZ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _dismissPrompt,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Don't rejoin",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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

    // Normal state - just show child
    return widget.child;
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
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
