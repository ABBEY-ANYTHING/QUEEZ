import 'package:flutter/material.dart';
import 'package:quiz_app/LibrarySection/screens/hosting_page.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Clean, minimalistic mode selection sheet with 2x2 grid layout
class ModeSelectionSheet extends StatelessWidget {
  final String quizId;
  final String quizTitle;
  final String hostId;

  const ModeSelectionSheet({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.hostId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(QuizSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(QuizBorderRadius.xl),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(QuizBorderRadius.sm),
                  ),
                ),
              ),
              const SizedBox(height: QuizSpacing.xl),

              // Title - left aligned
              Text(
                'Select Quiz Mode',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: QuizSpacing.xs),
              // Subtitle
              Text(
                'Choose how participants will take this quiz',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: QuizSpacing.xl),

              // 2x2 Grid of mode cards
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildModeCard(
                        context: context,
                        icon: Icons.share_outlined,
                        title: 'Share',
                        mode: 'share',
                      ),
                    ),
                    const SizedBox(width: QuizSpacing.md),
                    Expanded(
                      child: _buildModeCard(
                        context: context,
                        icon: Icons.groups_outlined,
                        title: 'Live Multiplayer',
                        mode: 'live_multiplayer',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: QuizSpacing.md),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildModeCard(
                        context: context,
                        icon: Icons.person_outline,
                        title: 'Self-Paced',
                        mode: 'self_paced',
                      ),
                    ),
                    const SizedBox(width: QuizSpacing.md),
                    Expanded(
                      child: _buildModeCard(
                        context: context,
                        icon: Icons.schedule_outlined,
                        title: 'Timed Individual',
                        mode: 'timed_individual',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: QuizSpacing.xl),

              // Cancel button
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: QuizSpacing.xl,
                      vertical: QuizSpacing.sm,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: QuizSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String mode,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            customRoute(
              HostingPage(
                quizId: quizId,
                quizTitle: quizTitle,
                mode: mode,
                hostId: hostId,
              ),
              AnimationType.slideUp,
            ),
          );
        },
        borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(QuizSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with subtle background
              Container(
                padding: const EdgeInsets.all(QuizSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                ),
                child: Icon(icon, color: AppColors.textPrimary, size: 26),
              ),
              const SizedBox(height: QuizSpacing.md),
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example function to show the mode selection sheet
/// Call this from your quiz detail page or library
void showModeSelection({
  required BuildContext context,
  required String quizId,
  required String quizTitle,
  required String hostId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => ModeSelectionSheet(
      quizId: quizId,
      quizTitle: quizTitle,
      hostId: hostId,
    ),
  );
}
