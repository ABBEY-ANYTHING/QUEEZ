import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_lobby.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/widgets/appbar/universal_appbar.dart';

import '../../../utils/app_logger.dart';

class LiveMultiplayerDashboard extends ConsumerStatefulWidget {
  final String quizId;
  final String sessionCode;

  const LiveMultiplayerDashboard({
    super.key,
    required this.quizId,
    required this.sessionCode,
  });

  @override
  ConsumerState<LiveMultiplayerDashboard> createState() =>
      _LiveMultiplayerDashboardState();
}

class _LiveMultiplayerDashboardState
    extends ConsumerState<LiveMultiplayerDashboard> {
  bool _isJoining = false;

  Future<void> _joinSession() async {
    setState(() => _isJoining = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId =
          user?.uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}';

      // ✅ FIXED: Fetch username from Firestore (same as profile page)
      String username = 'Player_${userId.substring(userId.length - 4)}';

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
          AppLogger.error('Error fetching user data from Firestore: $e');
          // Fallback to displayName or email
          username = user.displayName?.trim().isNotEmpty == true
              ? user.displayName!
              : (user.email?.split('@')[0] ?? username);
        }
      }

      // Wait for join to complete and session state to be received
      await ref
          .read(sessionProvider.notifier)
          .joinSession(widget.sessionCode, userId, username);

      // Only navigate after successful join
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LiveMultiplayerLobby(
              sessionCode: widget.sessionCode,
              isHost: false,
            ),
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Connection timeout. Please check your internet and try again.',
            ),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to join session';
        if (e.toString().contains('Session not found')) {
          errorMessage = 'Invalid session code. Please check and try again.';
        } else if (e.toString().contains('already active')) {
          errorMessage = 'This session has already started.';
        } else {
          errorMessage =
              'Failed to join: ${e.toString().replaceAll('Exception: ', '')}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const UniversalAppBar(title: 'Live Multiplayer'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Live Multiplayer\nSession',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Session Code Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Session Code',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.sessionCode,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info text
                Text(
                  'This is a temporary live multiplayer session.\nThe quiz will not be saved to your library.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Join button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isJoining ? null : _joinSession,
                    icon: _isJoining
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Icon(Icons.login, size: 20),
                    label: Text(
                      _isJoining ? 'Joining...' : 'Join Session',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
