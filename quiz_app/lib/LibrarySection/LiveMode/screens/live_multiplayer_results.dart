import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/reconnection_overlay.dart';
import 'package:quiz_app/providers/game_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/utils/color.dart';

class LiveMultiplayerResults extends ConsumerWidget {
  const LiveMultiplayerResults({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final currentUserId = ref.watch(currentUserProvider);

    // Get rankings from game state
    final rankings = gameState.rankings ?? [];

    if (rankings.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // Get top 3 for podium
    final topThree = rankings.take(3).toList();

    // Find current user's rank
    final currentUserRank =
        rankings.indexWhere((r) => r['user_id'] == currentUserId) + 1;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: ReconnectionOverlay(
        child: SafeArea(
          child: ListView(
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

              // Subtitle with rank
              if (currentUserRank > 0)
                Text(
                  'You finished #$currentUserRank',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              const SizedBox(height: 32),

              // Podium Section
              _buildPodium(topThree, currentUserId),

              // Leaderboard List (Ranks 4+)
              if (rankings.length > 3) ...[
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
                ...rankings.skip(3).map((user) {
                            final rank = rankings.indexOf(user) + 1;
                  final isCurrentUser = user['user_id'] == currentUserId;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          isCurrentUser
                              ? Border.all(
                                color: AppColors.primary,
                                width: 2,
                              )
                              : null,
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
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    isCurrentUser
                                        ? FontWeight.bold
                                        : FontWeight.w500,
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

              const SizedBox(height: 24),

              // Return Home Button
              ElevatedButton(
                onPressed: () {
                  AppLogger.debug('🏠 RESULTS - Navigating back to home');
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'RETURN TO HOME',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(
    List<Map<String, dynamic>> topThree,
    String? currentUserId,
  ) {
    if (topThree.isEmpty) return const SizedBox.shrink();

    // Prepare podium data: [2nd, 1st, 3rd]
    final List<Map<String, dynamic>?> podiumData = [
      topThree.length > 1 ? topThree[1] : null, // 2nd place
      topThree[0], // 1st place (always exists if topThree is not empty)
      topThree.length > 2 ? topThree[2] : null, // 3rd place
    ];

    final heights = [80.0, 112.0, 64.0]; // Heights for 2nd, 1st, 3rd
    final colors = [
      AppColors.secondary, // #98A88C (sage green for 2nd)
      AppColors.primary, // #5E8C61 (forest green for 1st)
      AppColors.accentBright, // #6FCF97 (bright green for 3rd)
    ];
    final ranks = [2, 1, 3];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (index) {
        final data = podiumData[index];
        if (data == null) {
          return const SizedBox(width: 80);
        }

        final isCurrentUser = data['user_id'] == currentUserId;
        final height = heights[index];
        final color = colors[index];
        final rank = ranks[index];
        final width = index == 1 ? 80.0 : 64.0; // 1st place wider

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Podium Bar
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child:
                      rank == 1
                          ? const Icon(
                            Icons.emoji_events,
                            color: AppColors.white,
                            size: 32,
                          )
                          : Text(
                            '$rank',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 8),

              // Name
              SizedBox(
                width: width,
                child: Text(
                  data['username'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: rank == 1 ? 13 : 11,
                    fontWeight:
                        isCurrentUser ? FontWeight.bold : FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),

              // Points
              Text(
                '${data['score']}',
                style: TextStyle(
                  fontSize: rank == 1 ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
