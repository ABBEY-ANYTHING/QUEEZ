import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:quiz_app/CreateSection/providers/ai_study_set_provider.dart';
import 'package:quiz_app/CreateSection/services/study_set_service.dart';
import 'package:quiz_app/CreateSection/widgets/quiz_saved_dialog.dart';
import 'package:quiz_app/providers/library_provider.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/globals.dart';

class AIGenerationProgress extends ConsumerStatefulWidget {
  const AIGenerationProgress({super.key});

  @override
  ConsumerState<AIGenerationProgress> createState() =>
      _AIGenerationProgressState();
}

class _AIGenerationProgressState extends ConsumerState<AIGenerationProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _displayProgress = 0.0;
  double _targetProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animationController.addListener(_animateProgress);

    _startFakeProgressAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGeneration();
    });
  }

  void _startFakeProgressAnimation() async {
    while (mounted && _displayProgress < 100) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;

      final state = ref.read(aiStudySetProvider);
      _targetProgress = state.progress;

      if (_displayProgress < _targetProgress) {
        setState(() {
          _displayProgress += (_targetProgress - _displayProgress) * 0.3;
          if (_displayProgress > _targetProgress - 0.5) {
            _displayProgress = _targetProgress;
          }
        });
      } else if (_displayProgress < 95 && state.isGenerating) {
        setState(() {
          _displayProgress += 0.1 + (0.2 * (1 - _displayProgress / 100));
          if (_displayProgress > 95) _displayProgress = 95;
        });
      }
    }
  }

  void _animateProgress() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startGeneration() async {
    final notifier = ref.read(aiStudySetProvider.notifier);

    try {
      final studySet = await notifier.generateStudySet();

      if (!mounted) return;

      try {
        await StudySetService.saveStudySet(studySet);
      } catch (saveError) {
        if (!mounted) return;
        _showErrorDialog(
          'Save Error',
          'Study set generated but failed to save: $saveError',
        );
        return;
      }

      if (!mounted) return;

      await QuizSavedDialog.show(
        context,
        title: 'Study Set Generated!',
        message: 'Your AI-powered study set is ready.',
        onDismiss: () async {
          if (mounted) {
            await ref.read(quizLibraryProvider.notifier).reload();
            if (!mounted) return;
            Navigator.of(context).popUntil((route) => route.isFirst);
            bottomNavbarKey.currentState?.setIndex(1);
          }
        },
      );

      notifier.reset();
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(
        'Generation Failed',
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Go Back',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startGeneration();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiStudySetProvider);

    return PopScope(
      canPop: !state.isGenerating,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !state.isGenerating) return;

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Cancel Generation?'),
            content: const Text(
              'Are you sure you want to cancel? Your progress will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Continue'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );

        if (shouldExit == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                _buildLottieAnimation(),
                const SizedBox(height: 48),
                _buildProgressBar(),
                const SizedBox(height: 24),
                _buildStatusText(state),
                const Spacer(),
                _buildTipBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLottieAnimation() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Lottie.asset(
        'assets/animations/loading.json',
        width: 220,
        height: 220,
        repeat: true,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.auto_awesome,
            size: 100,
            color: AppColors.primary.withValues(alpha: 0.5),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _displayProgress / 100),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 12,
                backgroundColor: AppColors.surface,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _displayProgress),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Text(
              '${value.toInt()}%',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusText(AIStudySetState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        state.currentStep.isEmpty ? 'Initializing...' : state.currentStep,
        key: ValueKey(state.currentStep),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildTipBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: Colors.amber.shade700, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tip: AI analyzes your documents to create the most relevant study materials.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
