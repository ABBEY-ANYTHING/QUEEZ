import 'dart:async';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_host_view.dart';
import 'package:quiz_app/LibrarySection/services/session_service.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/services/active_session_service.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';
import 'package:quiz_app/widgets/appbar/universal_appbar.dart';
import 'package:quiz_app/widgets/core/core_widgets.dart';
import 'package:share_plus/share_plus.dart';

class HostingPage extends ConsumerStatefulWidget {
  final String itemId; // Can be quizId or coursePackId
  final String itemTitle;
  final String mode;
  final String hostId;
  final bool isCoursePack;
  final String?
  existingSessionCode; // For reconnection - skip creating new session

  const HostingPage({
    super.key,
    required this.itemId,
    required this.itemTitle,
    required this.mode,
    required this.hostId,
    this.isCoursePack = false,
    this.existingSessionCode,
  });

  // Backward compatibility getters
  String get quizId => itemId;
  String get quizTitle => itemTitle;

  @override
  ConsumerState<HostingPage> createState() => _HostingPageState();
}

class _HostingPageState extends ConsumerState<HostingPage> {
  String? sessionCode;
  int participantCount = 0;
  List<Map<String, dynamic>> participants = [];
  int remainingSeconds = 600;
  bool isLoading = true;
  bool isSessionExpired = false;
  String? errorMessage;
  Timer? countdownTimer;
  final GlobalKey _qrKey = GlobalKey();
  bool _isStartingQuiz = false;
  bool _hasNavigatedToLiveHostView = false; // Prevent duplicate navigation

  // Time settings for live multiplayer
  int _perQuestionTimeLimit = 30; // Default 30 seconds per question

  @override
  void initState() {
    super.initState();
    if (widget.existingSessionCode != null) {
      // Reconnecting to existing session - skip creation
      _reconnectToSession();
    } else {
      // New session - create it
      _createSession();
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  void _updateParticipantsFromWebSocket() {
    // Safety check - don't access ref if widget is unmounted
    if (!mounted) return;

    final sessionState = ref.read(sessionProvider);
    if (sessionState != null && widget.mode == 'live_multiplayer') {
      debugPrint(
        '🔄 HOST - WebSocket update: ${sessionState.participants.length} participants',
      );
      setState(() {
        participants = sessionState.participants
            .map(
              (p) => {
                'user_id': p.userId,
                'username': p.username,
                'joined_at': p.joinedAt,
                'connected': p.connected,
                'score': p.score,
              },
            )
            .toList();
        participantCount = participants.length;
      });
      debugPrint(
        '✅ HOST - Updated participant list: $participantCount participants',
      );
    }
  }

  Future<void> _createSession() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final Map<String, dynamic> result;

      if (widget.isCoursePack) {
        // For course packs, use course pack share code endpoint
        result = await SessionService.createCoursePackShareCode(
          coursePackId: widget.itemId,
          hostId: widget.hostId,
        );
      } else {
        // For quizzes, use regular session creation
        result = await SessionService.createSession(
          quizId: widget.quizId,
          hostId: widget.hostId,
          mode: widget.mode,
        );
      }

      if (result['success'] == true) {
        setState(() {
          sessionCode = result['session_code'];
          remainingSeconds = result['expires_in'] ?? 600;
          isLoading = false;
        });

        // Save active session for host reconnection (with quiz info for proper navigation)
        await ActiveSessionService.saveActiveSession(
          sessionCode: result['session_code'],
          userId: widget.hostId,
          username: 'Host', // Will be updated in _connectHostToWebSocket
          isHost: true,
          quizId: widget.quizId,
          quizTitle: widget.quizTitle,
          mode: widget.mode,
        );

        _startCountdownTimer();

        if (widget.mode == 'live_multiplayer') {
          // Connect host to WebSocket for real-time participant updates
          // Note: WebSocket already broadcasts session_update events,
          // so HTTP polling is not needed
          await _connectHostToWebSocket();
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  /// Reconnect to an existing session (used when host reopens app)
  Future<void> _reconnectToSession() async {
    debugPrint(
      '🔄 HOST RECONNECTION - Reconnecting to session: ${widget.existingSessionCode}',
    );

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Get session info from backend to verify it still exists
      final response = await SessionService.getSessionInfo(
        widget.existingSessionCode!,
      );

      // Backend returns: {"success": true, "session": {...}}
      final sessionData = response['session'] as Map<String, dynamic>? ?? {};

      if (response['success'] == true && sessionData.isNotEmpty) {
        setState(() {
          sessionCode = widget.existingSessionCode;
          // Use remaining time from backend if available
          remainingSeconds = sessionData['expires_in'] ?? 600;
          isLoading = false;

          // Update participants if available
          final participantsMap =
              sessionData['participants'] as Map<String, dynamic>? ?? {};
          participantCount = participantsMap.length;
          participants = participantsMap.entries.map((e) {
            final p = e.value as Map<String, dynamic>;
            return {
              'user_id': e.key,
              'username': p['username'] ?? 'Anonymous',
              'joined_at': p['joined_at'],
              'connected': p['connected'] ?? true,
              'score': p['score'] ?? 0,
            };
          }).toList();
        });

        debugPrint(
          '✅ HOST RECONNECTION - Session validated, $participantCount participants',
        );

        _startCountdownTimer();

        if (widget.mode == 'live_multiplayer') {
          await _connectHostToWebSocket();
        }
      } else {
        // Session no longer valid
        debugPrint('❌ HOST RECONNECTION - Session no longer valid');
        setState(() {
          isLoading = false;
          errorMessage = 'Session has expired. Please create a new quiz.';
        });
        await ActiveSessionService.clearActiveSession();
      }
    } catch (e) {
      debugPrint('❌ HOST RECONNECTION - Error: $e');
      setState(() {
        isLoading = false;
        errorMessage =
            'Could not reconnect to session: ${e.toString().replaceAll('Exception: ', '')}';
      });
      await ActiveSessionService.clearActiveSession();
    }
  }

  Future<void> _connectHostToWebSocket() async {
    if (sessionCode == null) return;

    try {
      final user = FirebaseAuth.instance.currentUser;

      // ✅ FIXED: Fetch username from Firestore (same as profile page)
      String username = 'Host';

      if (user != null) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data();
            username = userData?['name'] ?? username;
          } else {
            // Fallback to displayName or email if Firestore doc doesn't exist
            username = user.displayName?.trim().isNotEmpty == true
                ? user.displayName!
                : (user.email?.split('@')[0] ?? username);
          }
        } catch (e) {
          debugPrint('Error fetching user data from Firestore: $e');
          // Fallback to displayName or email
          username = user.displayName?.trim().isNotEmpty == true
              ? user.displayName!
              : (user.email?.split('@')[0] ?? username);
        }
      }

      debugPrint(
        '🎯 HOST - Attempting to join session $sessionCode as $username',
      );
      debugPrint('🎯 HOST - User ID: ${widget.hostId}');
      debugPrint('🎯 HOST - Mode: ${widget.mode}');

      // Connect host to WebSocket (isHost: true to preserve host status)
      await ref
          .read(sessionProvider.notifier)
          .joinSession(sessionCode!, widget.hostId, username, isHost: true)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint(
                '⚠️ HOST - Join timeout after 10s, but continuing anyway (host can still control session)',
              );
            },
          );

      debugPrint(
        '✅ HOST - Successfully connected to WebSocket for session $sessionCode',
      );
      debugPrint('✅ HOST - Now listening for participant updates in real-time');

      // ✅ IMPORTANT: Update participants from WebSocket state AFTER connection
      // This ensures we get the latest participants list from session_state
      await Future.delayed(const Duration(milliseconds: 500));
      _updateParticipantsFromWebSocket();
    } catch (e, stackTrace) {
      debugPrint('⚠️ HOST - WebSocket connection issue: $e');
      debugPrint('⚠️ HOST - Stack trace: $stackTrace');
      debugPrint(
        '⚠️ HOST - Continuing anyway - host can still start quiz via HTTP API',
      );
      // Don't show error - host can still start the quiz via HTTP API
    }
  }

  void _startCountdownTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          isSessionExpired = true;
          timer.cancel();
        }
      });
    });
  }

  void _copyToClipboard() {
    if (sessionCode != null) {
      Clipboard.setData(ClipboardData(text: sessionCode!));
      AppSnackBar.showSuccess(context, 'Session code copied!');
    }
  }

  Future<void> _startQuiz() async {
    if (sessionCode == null || _isStartingQuiz) return;

    setState(() {
      _isStartingQuiz = true;
    });

    try {
      debugPrint('🎯 HOST - Starting quiz via WebSocket...');
      debugPrint(
        '⏱️ HOST - Time settings: perQuestion=${_perQuestionTimeLimit}s',
      );

      // Use WebSocket to start quiz with time settings
      ref
          .read(sessionProvider.notifier)
          .startQuiz(perQuestionTimeLimit: _perQuestionTimeLimit);

      debugPrint(
        '✅ HOST - Start quiz message sent via WebSocket, waiting for confirmation...',
      );

      // Fallback: Poll for status change in case listener doesn't fire
      _startQuizPolling();

      // Don't navigate immediately - wait for WebSocket to confirm status == 'active'
      // The ref.listen above will handle navigation when backend sends quiz_started
    } catch (e) {
      setState(() {
        _isStartingQuiz = false;
      });
      if (mounted) {
        AppSnackBar.showError(
          context,
          'Failed to start quiz: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    }
  }

  void _startQuizPolling() {
    // Poll every 500ms for up to 10 seconds to check if quiz started
    int attempts = 0;
    const maxAttempts = 20;

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      attempts++;

      if (!mounted || !_isStartingQuiz) {
        timer.cancel();
        return;
      }

      // Check current state
      final session = ref.read(sessionProvider);
      debugPrint(
        '🔄 HOST - Polling status (attempt $attempts): ${session?.status}',
      );

      if (session?.status == 'active') {
        debugPrint('🎯 HOST - Polling detected active status! Navigating...');
        timer.cancel();
        _isStartingQuiz = false;

        if (mounted && !_hasNavigatedToLiveHostView) {
          _hasNavigatedToLiveHostView = true;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LiveHostView(sessionCode: sessionCode!),
            ),
          );
        }
        return;
      }

      if (attempts >= maxAttempts) {
        debugPrint(
          '⚠️ HOST - Polling timeout after ${maxAttempts * 500}ms, resetting...',
        );
        timer.cancel();
        if (mounted) {
          setState(() {
            _isStartingQuiz = false;
          });
          AppSnackBar.showError(
            context,
            'Quiz start timed out. Please try again.',
          );
        }
      }
    });
  }

  Future<void> _shareQRCode() async {
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      await SharePlus.instance.share(
        ShareParams(
          text: 'Join my quiz with code: $sessionCode',
          files: [
            XFile.fromData(
              pngBytes,
              name: 'quiz_qr_code.png',
              mimeType: 'image/png',
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Error sharing: ${e.toString()}');
    }
  }

  void _showEnlargedQR() {
    showDialog(
      context: context,
      barrierColor: AppColors.primary.withValues(alpha: 0.3),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(QuizSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(QuizBorderRadius.xl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Scan to Join',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: QuizSpacing.lg),
              RepaintBoundary(
                key: _qrKey,
                child: Container(
                  padding: const EdgeInsets.all(QuizSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
                  ),
                  child: QrImageView(
                    data: sessionCode ?? '',
                    version: QrVersions.auto,
                    size: 280,
                    backgroundColor: AppColors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.primary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: QuizSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppButton.primary(
                    text: 'Share',
                    icon: Icons.share,
                    onPressed: _shareQRCode,
                  ),
                  AppButton.outlined(
                    text: 'Close',
                    icon: Icons.close,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Watch session provider to trigger rebuild when participants change
    final sessionState = ref.watch(sessionProvider);

    // ✅ Listen to WebSocket updates for real-time participant sync
    ref.listen(sessionProvider, (previous, next) {
      debugPrint(
        '🔔 HOST - sessionProvider changed: prev=${previous?.status}, next=${next?.status}, _isStartingQuiz=$_isStartingQuiz',
      );
      debugPrint(
        '🔔 HOST - Participants: prev=${previous?.participants.length ?? 0}, next=${next?.participants.length ?? 0}',
      );

      if (next != null && widget.mode == 'live_multiplayer') {
        // ✅ Always update participants when state changes
        _updateParticipantsFromWebSocket();

        // ✅ Navigate to LiveHostView when quiz becomes active
        // Check if status changed TO 'active' (not already active)
        final wasActive = previous?.status == 'active';
        final isNowActive = next.status == 'active';

        if (isNowActive &&
            _isStartingQuiz &&
            !wasActive &&
            !_hasNavigatedToLiveHostView) {
          debugPrint(
            '🎯 HOST - Quiz is now active! Navigating to LiveHostView',
          );
          // Reset flags before navigation
          _isStartingQuiz = false;
          _hasNavigatedToLiveHostView = true;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LiveHostView(sessionCode: sessionCode!),
            ),
          );
        }
      }
    });

    // ✅ Also sync participants from watched state (belt and suspenders approach)
    if (sessionState != null &&
        widget.mode == 'live_multiplayer' &&
        sessionState.participants.length != participantCount) {
      // Schedule update for next frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateParticipantsFromWebSocket();
        }
      });
    }

    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.white),
                SizedBox(height: QuizSpacing.md),
                Text(
                  'Creating Session...',
                  style: TextStyle(color: AppColors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: const UniversalAppBar(title: 'Error'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: QuizSpacing.md),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: QuizSpacing.lg),
                AppButton.primary(
                  text: 'Go Back',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (isSessionExpired) {
      return Scaffold(
        appBar: const UniversalAppBar(title: 'Session Expired'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_off, size: 64, color: AppColors.warning),
                const SizedBox(height: QuizSpacing.md),
                const Text(
                  'Session has expired',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: QuizSpacing.sm),
                const Text(
                  'Please create a new session',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: QuizSpacing.lg),
                AppButton.primary(
                  text: 'Go Back',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UniversalAppBar(
        title: '',
        showNotificationBell: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: QuizSpacing.md),
            padding: const EdgeInsets.symmetric(
              horizontal: QuizSpacing.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(QuizBorderRadius.circular),
              border: Border.all(color: AppColors.primaryLighter),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                Text(
                  _formatTime(remainingSeconds),
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            QuizSpacing.lg,
            QuizSpacing.lg,
            QuizSpacing.lg,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: QuizSpacing.lg),
              Text(
                widget.quizTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: QuizSpacing.xs),
              Text(
                'Invite players and start the quiz',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: QuizSpacing.xl),

              // Session Code & QR Code Cards
              _buildInfoCards(),

              const SizedBox(height: QuizSpacing.xl),

              // Time Settings Section (only for live_multiplayer)
              if (widget.mode == 'live_multiplayer') ...[
                _buildTimeSettingsSection(),
                const SizedBox(height: QuizSpacing.xl),
              ],

              // Participants Section (only for live_multiplayer)
              if (widget.mode == 'live_multiplayer') ...[
                _buildParticipantsSection(),
                const SizedBox(height: QuizSpacing.xl),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        // Session Code Card
        Container(
          padding: const EdgeInsets.all(QuizSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
            border: Border.all(color: AppColors.primaryLighter),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'QUIZ CODE',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sessionCode ?? '------',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy, color: AppColors.primary),
                    tooltip: 'Copy Code',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: QuizSpacing.md),
        // QR Code Card
        InkWell(
          onTap: _showEnlargedQR,
          borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(QuizSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
              border: Border.all(color: AppColors.primaryLighter),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_2, color: AppColors.primary, size: 40),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QR CODE',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap to expand and share',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.iconInactive,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(QuizSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
        border: Border.all(color: AppColors.primaryLighter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timer,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'TIME PER QUESTION',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: QuizSpacing.lg),

          // Per Question Time Limit
          _buildTimeSetting(
            value: _perQuestionTimeLimit,
            options: const [10, 15, 20, 30, 45, 60, 90, 120],
            onChanged: (value) {
              setState(() {
                _perQuestionTimeLimit = value;
              });
            },
            formatValue: (v) => '${v}s',
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSetting({
    required int value,
    required List<int> options,
    required Function(int) onChanged,
    required String Function(int) formatValue,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = value == option;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primaryLighter,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  formatValue(option),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Players Joined',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$participantCount',
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: QuizSpacing.md),
        if (participants.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: QuizSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
              border: Border.all(color: AppColors.primaryLighter),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: AppColors.iconInactive,
                  ),
                  const SizedBox(height: QuizSpacing.md),
                  Text(
                    'Waiting for participants...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              final username = participant['username'] ?? 'Anonymous';
              final firstLetter = username.isNotEmpty
                  ? username[0].toUpperCase()
                  : '?';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 20,
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        username,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        // START QUIZ Button (for host to start the quiz for all participants)
        if (participantCount >= 1) ...[
          const SizedBox(height: QuizSpacing.lg),
          AppButton(
            text: 'START QUIZ',
            onPressed: (participantCount >= 1 && !_isStartingQuiz)
                ? _startQuiz
                : null,
            icon: Icons.play_arrow,
            style: AppButtonStyle.success,
            size: AppButtonSize.medium,
            fullWidth: true,
            isLoading: _isStartingQuiz,
          ),
          if (participantCount < 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Waiting for participants...',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ],
    );
  }
}
