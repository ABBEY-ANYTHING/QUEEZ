import 'package:flutter/material.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Beautiful animated leaderboard popup shown after answering a question
class LeaderboardPopup extends StatefulWidget {
  final List<Map<String, dynamic>> rankings;
  final String currentUserId;
  final VoidCallback onComplete;
  final int displayDuration; // seconds

  const LeaderboardPopup({
    super.key,
    required this.rankings,
    required this.currentUserId,
    required this.onComplete,
    this.displayDuration = 3,
  });

  @override
  State<LeaderboardPopup> createState() => _LeaderboardPopupState();
}

class _LeaderboardPopupState extends State<LeaderboardPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    AppLogger.info(
      'Leaderboard popup: ${widget.rankings.length} participants, ${widget.displayDuration}s display',
    );
    _remainingSeconds = widget.displayDuration;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds > 0) {
        _startCountdown();
      } else {
        _controller.reverse().then((_) {
          if (mounted) {
            widget.onComplete();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface,
                  AppColors.surface.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(QuizBorderRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(QuizSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(QuizBorderRadius.xl),
                      topRight: Radius.circular(QuizBorderRadius.xl),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: QuizColors.gold,
                            size: 28,
                          ),
                          SizedBox(width: QuizSpacing.sm),
                          Text(
                            'LEADERBOARD',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: QuizSpacing.md,
                          vertical: QuizSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            QuizBorderRadius.circular,
                          ),
                        ),
                        child: Text(
                          '$_remainingSeconds',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Leaderboard entries
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(QuizSpacing.md),
                    shrinkWrap: true,
                    itemCount: widget.rankings.length > 5
                        ? 5
                        : widget.rankings.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: QuizSpacing.sm),
                    itemBuilder: (context, index) {
                      final entry = widget.rankings[index];
                      final isCurrentUser =
                          entry['user_id'] == widget.currentUserId;
                      final rank = index + 1;

                      Color? medalColor;
                      IconData? medalIcon;

                      if (rank == 1) {
                        medalColor = QuizColors.gold;
                        medalIcon = Icons.emoji_events;
                      } else if (rank == 2) {
                        medalColor = QuizColors.silver;
                        medalIcon = Icons.emoji_events;
                      } else if (rank == 3) {
                        medalColor = QuizColors.bronze;
                        medalIcon = Icons.emoji_events;
                      }

                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(QuizSpacing.md),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : QuizColors.cardBackground,
                            borderRadius: BorderRadius.circular(
                              QuizBorderRadius.md,
                            ),
                            border: Border.all(
                              color: isCurrentUser
                                  ? AppColors.primary
                                  : medalColor?.withValues(alpha: 0.3) ??
                                        Colors.transparent,
                              width: isCurrentUser ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Rank badge - ONLY top 3 get medals
                              Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: rank <= 3 && medalColor != null
                                      ? medalColor.withValues(alpha: 0.2)
                                      : QuizColors.textSecondary.withValues(
                                          alpha: 0.2,
                                        ),
                                  border: Border.all(
                                    color: rank <= 3 && medalColor != null
                                        ? medalColor
                                        : QuizColors.textSecondary,
                                    width: 2,
                                  ),
                                ),
                                child: rank <= 3 && medalIcon != null
                                    ? Icon(
                                        medalIcon,
                                        color: medalColor,
                                        size: 20,
                                      )
                                    : Text(
                                        '$rank',
                                        style: TextStyle(
                                          color: QuizColors.textSecondary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: QuizSpacing.md),

                              // Username
                              Expanded(
                                child: Text(
                                  entry['username'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: QuizColors.textPrimary,
                                    fontWeight: isCurrentUser || rank <= 3
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Score
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: QuizSpacing.md,
                                  vertical: QuizSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      medalColor?.withValues(alpha: 0.3) ??
                                          AppColors.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                      medalColor?.withValues(alpha: 0.1) ??
                                          AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    QuizBorderRadius.circular,
                                  ),
                                  border: Border.all(
                                    color: medalColor ?? AppColors.primary,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${entry['score']}',
                                  style: TextStyle(
                                    color: medalColor ?? AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.all(QuizSpacing.md),
                  child: Text(
                    'Next question in $_remainingSeconds...',
                    style: TextStyle(
                      color: QuizColors.textSecondary,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
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
