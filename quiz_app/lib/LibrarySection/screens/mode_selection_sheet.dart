import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/services/course_pack_service.dart';
import 'package:quiz_app/LibrarySection/screens/hosting_page.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Clean, minimalistic mode selection sheet with 2x2 grid layout
class ModeSelectionSheet extends StatelessWidget {
  final String itemId; // Can be quizId or coursePackId
  final String itemTitle;
  final String hostId;
  final bool isCoursePack;
  final bool isCurrentlyPublic; // Whether course pack is already on marketplace

  const ModeSelectionSheet({
    super.key,
    required this.itemId,
    required this.itemTitle,
    required this.hostId,
    this.isCoursePack = false,
    this.isCurrentlyPublic = false,
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
              if (isCoursePack)
                // Course Pack modes: Share and Marketplace
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
                          icon: isCurrentlyPublic
                              ? Icons.remove_shopping_cart_outlined
                              : Icons.storefront_outlined,
                          title: isCurrentlyPublic
                              ? 'Remove from Marketplace'
                              : 'List on Marketplace',
                          mode: 'marketplace',
                          isRemove: isCurrentlyPublic,
                        ),
                      ),
                    ],
                  ),
                )
              else
                // Quiz modes: All 4 modes
                Column(
                  children: [
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
                  ],
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
    bool isRemove = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          // Marketplace mode - publish or unpublish the course pack
          if (mode == 'marketplace') {
            if (isCoursePack) {
              // Get the root navigator and scaffold messenger before popping
              final rootNavigator = Navigator.of(context, rootNavigator: true);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              // Close the bottom sheet first
              Navigator.pop(context);

              // Show loading dialog using root navigator
              showDialog(
                context: rootNavigator.context,
                barrierDismissible: false,
                useRootNavigator: true,
                builder: (ctx) => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );

              try {
                await CoursePackService.publishCoursePack(
                  itemId,
                  isPublic: !isRemove, // Toggle based on current state
                );
                // Close loading dialog
                rootNavigator.pop();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      isRemove
                          ? 'Course pack removed from marketplace!'
                          : 'Course pack listed on marketplace!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                // Close loading dialog
                rootNavigator.pop();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to ${isRemove ? 'remove' : 'list'}: ${e.toString().replaceAll('Exception: ', '')}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Marketplace listing is only available for course packs',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
              Navigator.pop(context);
            }
            return;
          }

          // Close the bottom sheet
          Navigator.pop(context);

          // For share/session modes, navigate to HostingPage
          Navigator.push(
            context,
            customRoute(
              HostingPage(
                itemId: itemId,
                itemTitle: itemTitle,
                mode: mode,
                hostId: hostId,
                isCoursePack: isCoursePack,
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
  required String itemId,
  required String itemTitle,
  required String hostId,
  bool isCoursePack = false,
  bool isCurrentlyPublic = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => ModeSelectionSheet(
      itemId: itemId,
      itemTitle: itemTitle,
      hostId: hostId,
      isCoursePack: isCoursePack,
      isCurrentlyPublic: isCurrentlyPublic,
    ),
  );
}
