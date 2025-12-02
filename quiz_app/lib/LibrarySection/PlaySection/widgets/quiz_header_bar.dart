import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quiz_app/utils/color.dart';

/// Clean compact quiz header bar with:
/// - Left: Question counter (e.g., "Q 2/4")
/// - Right: Streak (🔥 Lottie) + Timer pill
class QuizHeaderBar extends StatefulWidget {
  final int currentIndex;
  final int totalQuestions;
  final int currentStreak;
  final int timeRemaining;
  final int timeLimit;
  final bool hasAnswered;
  final int? streakChange;

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
  late AnimationController _pulseController;
  int _previousStreak = 0;
  bool _streakGained = false;
  bool _streakLost = false;

  @override
  void initState() {
    super.initState();
    _previousStreak = widget.currentStreak;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(QuizHeaderBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect streak change
    if (widget.currentStreak > _previousStreak) {
      // Streak gained!
      _triggerStreakGain();
    } else if (widget.currentStreak < _previousStreak && _previousStreak >= 1) {
      // Streak lost (from any positive streak to lower)!
      _triggerStreakLoss();
    }
    _previousStreak = widget.currentStreak;
  }

  void _triggerStreakGain() {
    setState(() => _streakGained = true);
    _pulseController.forward(from: 0).then((_) {
      if (mounted) setState(() => _streakGained = false);
    });
  }

  void _triggerStreakLoss() {
    setState(() => _streakLost = true);
    _pulseController.forward(from: 0).then((_) {
      if (mounted) setState(() => _streakLost = false);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Question counter
          Text(
            'Q ${widget.currentIndex + 1}/${widget.totalQuestions}',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // Streak indicator
          _buildStreakIndicator(),

          const SizedBox(width: 12),

          // Timer badge
          _buildTimerBadge(),
        ],
      ),
    );
  }

  Widget _buildStreakIndicator() {
    final hasActiveStreak = widget.currentStreak >= 2;

    // Determine glow color based on state (orange for gain, red for loss)
    Color? glowColor;
    if (_streakGained) {
      glowColor = AppColors.warning; // Orange glow for streak gain
    } else if (_streakLost) {
      glowColor = AppColors.error;
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey(
        'streak_${widget.currentStreak}_${_streakGained}_$_streakLost',
      ),
      duration: const Duration(milliseconds: 400),
      tween: Tween(
        begin: _streakGained ? 1.4 : (_streakLost ? 0.8 : 1.0),
        end: 1.0,
      ),
      curve: _streakGained ? Curves.elasticOut : Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (glowColor ?? Colors.transparent).withValues(
                    alpha: glowColor != null ? 0.6 : 0.0,
                  ),
                  blurRadius: glowColor != null ? 12 : 0,
                  spreadRadius: glowColor != null ? 2 : 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Always show Lottie fire animation
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Lottie.asset(
                    'assets/animations/fire_streak.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Text(
                    '${widget.currentStreak}',
                    key: ValueKey(widget.currentStreak),
                    style: TextStyle(
                      color: _streakLost
                          ? AppColors.error
                          : (hasActiveStreak
                                ? AppColors.warning
                                : AppColors.textSecondary),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerBadge() {
    final progress = widget.timeLimit > 0
        ? widget.timeRemaining / widget.timeLimit
        : 0.0;
    final isLowTime = widget.timeRemaining <= 5;
    final isCriticalTime = widget.timeRemaining <= 3;

    Color timerColor;
    if (widget.hasAnswered) {
      timerColor = AppColors.primary;
    } else if (isLowTime) {
      timerColor = AppColors.error;
    } else if (progress > 0.6) {
      timerColor = AppColors.success;
    } else if (progress > 0.3) {
      timerColor = AppColors.warning;
    } else {
      timerColor = AppColors.error;
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey('timer_${widget.timeRemaining}'),
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: isCriticalTime ? 1.1 : 1.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: isCriticalTime && !widget.hasAnswered ? scale : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: timerColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isCriticalTime && !widget.hasAnswered
                  ? [
                      BoxShadow(
                        color: timerColor.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded, color: AppColors.white, size: 14),
                const SizedBox(width: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    '${widget.timeRemaining}s',
                    key: ValueKey(widget.timeRemaining),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
