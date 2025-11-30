import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Compact quiz header bar with:
/// - Left: Question progress (e.g., "2/4")
/// - Right: Streak multiplier (🔥 x2) + Circular timer
/// Always visible at top while scrolling.
class QuizHeaderBar extends StatefulWidget {
  final int currentIndex;
  final int totalQuestions;
  final int currentStreak;
  final int timeRemaining;
  final int timeLimit;
  final bool hasAnswered;
  final int?
  streakChange; // +1 = gained, -n = lost n streak, null = no change yet

  const QuizHeaderBar({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.currentStreak,
    required this.timeRemaining,
    required this.timeLimit,
    required this.hasAnswered,
    this.streakChange,
  });

  @override
  State<QuizHeaderBar> createState() => _QuizHeaderBarState();
}

class _QuizHeaderBarState extends State<QuizHeaderBar>
    with TickerProviderStateMixin {
  late AnimationController _streakAnimController;
  late AnimationController _pulseController;
  late AnimationController _fireAnimController;
  late Animation<double> _pulseAnimation;
  bool _showStreakAnimation = false;

  @override
  void initState() {
    super.initState();
    _streakAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fireAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(QuizHeaderBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger streak animation when streak changes
    if (widget.streakChange != null &&
        widget.streakChange != 0 &&
        oldWidget.streakChange != widget.streakChange) {
      _triggerStreakAnimation(widget.streakChange! > 0);
    }

    // Pulse animation for low time
    if (widget.timeRemaining <= 5 && !widget.hasAnswered) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }

    // Fire animation for active streak
    if (widget.currentStreak >= 2 && !_fireAnimController.isAnimating) {
      _fireAnimController.repeat();
    } else if (widget.currentStreak < 2) {
      _fireAnimController.stop();
      _fireAnimController.reset();
    }
  }

  void _triggerStreakAnimation(bool isGain) {
    // Only show animation for streak gain, not loss
    if (!isGain) return;

    setState(() {
      _showStreakAnimation = true;
    });

    _streakAnimController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _showStreakAnimation = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _streakAnimController.dispose();
    _pulseController.dispose();
    _fireAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: QuizSpacing.md,
        vertical: QuizSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Question Progress
          _buildQuestionProgress(),

          // Right: Streak + Timer
          Row(
            children: [
              _buildStreakIndicator(),
              const SizedBox(width: QuizSpacing.sm),
              _buildCircularTimer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionProgress() {
    final progress = (widget.currentIndex + 1) / widget.totalQuestions;

    return Row(
      children: [
        // Circular progress indicator
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                backgroundColor: AppColors.primaryLighter,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
              Text(
                '${widget.currentIndex + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: QuizSpacing.xs),
        Text(
          '/${widget.totalQuestions}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakIndicator() {
    final hasStreak = widget.currentStreak >= 2;
    final multiplierText = _getMultiplierText();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: QuizAnimations.normal,
          padding: const EdgeInsets.symmetric(
            horizontal: QuizSpacing.sm,
            vertical: QuizSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: hasStreak
                ? const Color(0xFFFFF3E0) // Warm orange background
                : AppColors.background,
            borderRadius: BorderRadius.circular(QuizBorderRadius.circular),
            border: Border.all(
              color: hasStreak
                  ? const Color(0xFFFF9800)
                  : AppColors.primaryLighter,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fire icon/lottie
              _buildFireIcon(hasStreak),
              const SizedBox(width: 2),
              AnimatedDefaultTextStyle(
                duration: QuizAnimations.normal,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: hasStreak
                      ? const Color(0xFFE65100)
                      : AppColors.textSecondary,
                ),
                child: Text(multiplierText),
              ),
            ],
          ),
        ),

        // Streak animation overlay (floating up notification)
        if (_showStreakAnimation)
          Positioned(
            top: -35,
            left: -15,
            right: -15,
            child: _buildStreakAnimationOverlay(),
          ),
      ],
    );
  }

  Widget _buildFireIcon(bool hasStreak) {
    if (hasStreak) {
      // Try to use Lottie fire animation, fallback to emoji
      return SizedBox(
        width: 24,
        height: 24,
        child: Lottie.asset(
          'assets/animations/fire_streak.json',
          controller: _fireAnimController,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to animated emoji
            return AnimatedBuilder(
              animation: _fireAnimController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + 0.1 * _fireAnimController.value,
                  child: const Text('🔥', style: TextStyle(fontSize: 16)),
                );
              },
            );
          },
        ),
      );
    } else {
      return const Text('💫', style: TextStyle(fontSize: 16));
    }
  }

  Widget _buildStreakAnimationOverlay() {
    return AnimatedBuilder(
      animation: _streakAnimController,
      builder: (context, child) {
        final opacity = (1.0 - _streakAnimController.value).clamp(0.0, 1.0);
        final translateY = -25 * _streakAnimController.value;
        final scale = 1.0 + 0.2 * (1.0 - _streakAnimController.value);

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                    ),
                    borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Use Lottie for streak gain if available
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Lottie.asset(
                          'assets/animations/streak_gain.json',
                          repeat: false,
                          errorBuilder: (_, __, ___) =>
                              const Text('🔥', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '+1 Streak!',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getMultiplierText() {
    if (widget.currentStreak >= 5) return 'x3';
    if (widget.currentStreak >= 3) return 'x2';
    if (widget.currentStreak >= 2) return 'x1.5';
    return 'x1';
  }

  Widget _buildCircularTimer() {
    final progress = widget.timeLimit > 0
        ? widget.timeRemaining / widget.timeLimit
        : 0.0;
    final isLowTime = widget.timeRemaining <= 5;
    final isCriticalTime = widget.timeRemaining <= 3;

    Color timerColor;
    if (widget.hasAnswered) {
      timerColor = AppColors.primary;
    } else if (isCriticalTime) {
      timerColor = QuizColors.incorrect;
    } else if (isLowTime) {
      timerColor = QuizColors.warning;
    } else if (progress > 0.5) {
      timerColor = QuizColors.correct;
    } else {
      timerColor = QuizColors.warning;
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = (isCriticalTime && !widget.hasAnswered)
            ? _pulseAnimation.value
            : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: timerColor.withValues(alpha: 0.1),
              border: Border.all(
                color: timerColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3.5,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                  ),
                ),
                // Timer text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 10, color: timerColor),
                    Text(
                      '${widget.timeRemaining}',
                      style: TextStyle(
                        fontSize: isCriticalTime ? 14 : 13,
                        fontWeight: FontWeight.bold,
                        color: timerColor,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
