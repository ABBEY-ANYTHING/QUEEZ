import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/podium_widget.dart';
import 'package:quiz_app/providers/game_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/utils/color.dart';

import '../../../models/multiplayer_models.dart';

class LiveHostView extends ConsumerStatefulWidget {
  final String sessionCode;

  const LiveHostView({super.key, required this.sessionCode});

  @override
  ConsumerState<LiveHostView> createState() => _LiveHostViewState();
}

class _LiveHostViewState extends ConsumerState<LiveHostView> {
  bool _hasRequestedLeaderboard = false;
  Timer? _leaderboardPollingTimer;

  @override
  void initState() {
    super.initState();
    // Request leaderboard after frame renders to ensure WebSocket is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLeaderboardIfNeeded();
    });
  }

  @override
  void dispose() {
    _leaderboardPollingTimer?.cancel();
    super.dispose();
  }

  void _requestLeaderboardIfNeeded() {
    if (_hasRequestedLeaderboard) return;

    debugPrint('🏆 LiveHostView - Requesting initial leaderboard');
    _hasRequestedLeaderboard = true;

    // ✅ FIX: Small delay to ensure gameProvider's WebSocket listener is set up
    // This fixes the race condition on host reconnection
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        debugPrint('🏆 LiveHostView - Sending leaderboard request');
        ref.read(gameProvider.notifier).requestLeaderboard();
      }
    });

    // ✅ FIX: Start polling for leaderboard updates every 3 seconds
    // This ensures host sees real-time updates even after reconnection
    _startLeaderboardPolling();
  }

  void _startLeaderboardPolling() {
    _leaderboardPollingTimer?.cancel();
    _leaderboardPollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final sessionState = ref.read(sessionProvider);
      // Only poll if session is still active
      if (sessionState?.status == 'active') {
        debugPrint('🔄 LiveHostView - Polling leaderboard...');
        ref.read(gameProvider.notifier).requestLeaderboard();
      } else if (sessionState?.status == 'completed') {
        // Stop polling when quiz is completed
        _leaderboardPollingTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final sessionState = ref.watch(sessionProvider);
    final rankings = gameState.rankings ?? [];

    // Get ALL participants from session, not just rankings
    final allParticipants = sessionState?.participants ?? [];
    final participantCount = allParticipants.length;

    // Check if all participants have completed the quiz
    final totalQuestions =
        sessionState?.totalQuestions ?? gameState.totalQuestions;
    final allCompleted =
        rankings.isNotEmpty &&
        rankings.every((entry) {
          final answeredCount = entry['answered_count'] ?? 0;
          return answeredCount >= totalQuestions;
        });

    // Calculate average score across all participants

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          'Live Leaderboard',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: allCompleted
            ? _buildCompletionView(rankings)
            : _buildLiveLeaderboard(
                rankings,
                participantCount,
                sessionState,
                gameState,
              ),
      ),
    );
  }

  /// Builds the completion view with podium (same as participants see)
  Widget _buildCompletionView(List<Map<String, dynamic>> rankings) {
    final topThree = rankings.take(3).toList();
    final remainingPlayers = rankings.skip(3).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Trophy Icon Circle
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: AppColors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        const Text(
          'Quiz Completed!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          'All participants have finished',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),

        // Podium Section
        if (topThree.isNotEmpty)
          PodiumWidget(
            topThree: topThree,
            currentUserId: '', // Host doesn't need highlighting
          ),

        // Other Players (Ranks 4+)
        if (remainingPlayers.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Divider(height: 32),
          const Text(
            'Other Players',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...remainingPlayers.map((user) {
            final rank = rankings.indexOf(user) + 1;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Rank Badge
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLighter,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$rank',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Username
                      Text(
                        user['username'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  // Points
                  Text(
                    '${user['score']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  /// Builds the live leaderboard view
  Widget _buildLiveLeaderboard(
    List<Map<String, dynamic>> rankings,
    int participantCount,
    SessionState? sessionState,
    GameState gameState,
  ) {
    return rankings.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'Waiting for participants...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: rankings.length + 1, // +1 for header
            itemBuilder: (context, index) {
              // Header row
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Players',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$participantCount',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Leaderboard items
              final entryIndex = index - 1;
              final entry = rankings[entryIndex];
              final rank = entryIndex + 1;
              final answeredCount = entry['answered_count'] ?? 0;
              final totalQuestions =
                  sessionState?.totalQuestions ?? gameState.totalQuestions;
              final score = entry['score'] ?? 0;
              final username = entry['username'] ?? 'Unknown';

              // Medal colors for top 3
              Color? medalColor;
              if (rank == 1) {
                medalColor = const Color(0xFFFFD700); // Gold
              } else if (rank == 2) {
                medalColor = const Color(0xFFC0C0C0); // Silver
              } else if (rank == 3) {
                medalColor = const Color(0xFFCD7F32); // Bronze
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: medalColor ?? AppColors.primaryLight,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: medalColor != null
                                ? AppColors.white
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Username and progress
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Q$answeredCount/$totalQuestions',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Score
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
