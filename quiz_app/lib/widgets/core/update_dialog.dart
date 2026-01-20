import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/app_version_service.dart';
import '../../utils/color.dart';
import '../../utils/quiz_design_system.dart';

/// A clean update dialog inspired by AppDialog
/// Shows version number and release notes from Firebase
class UpdateDialog extends StatelessWidget {
  final String newVersion;
  final String currentVersion;
  final String releaseNotes;

  const UpdateDialog({
    super.key,
    required this.newVersion,
    required this.currentVersion,
    required this.releaseNotes,
  });

  /// Show the update dialog
  static Future<void> show({
    required BuildContext context,
    required AppVersionInfo versionInfo,
    required String currentVersion,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.primary.withValues(alpha: 0.3),
      builder: (context) => UpdateDialog(
        newVersion: versionInfo.versionNumber,
        currentVersion: currentVersion,
        releaseNotes: versionInfo.releaseNotes,
      ),
    );
  }

  Future<void> _launchUpdate() async {
    // Launch the releases page
    final releasesUri = Uri.parse(AppVersionService.githubReleasesUrl);
    if (await canLaunchUrl(releasesUri)) {
      await launchUrl(releasesUri, mode: LaunchMode.externalApplication);
    }

    // Also trigger the direct download
    final downloadUri = Uri.parse(AppVersionService.directDownloadUrl);
    if (await canLaunchUrl(downloadUri)) {
      await launchUrl(downloadUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: TweenAnimationBuilder<double>(
        duration: QuizAnimations.normal,
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
          ),
          elevation: 8,
          shadowColor: AppColors.primary.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(QuizSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Update icon and title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(QuizSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLighter,
                        borderRadius: BorderRadius.circular(
                          QuizBorderRadius.sm,
                        ),
                      ),
                      child: const Icon(
                        Icons.system_update_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: QuizSpacing.md),
                    const Expanded(
                      child: Text(
                        'Update Available',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: QuizSpacing.lg),

                // Version info
                Container(
                  padding: const EdgeInsets.all(QuizSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(QuizBorderRadius.sm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Version',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'v$currentVersion',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'New Version',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'v$newVersion',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: QuizSpacing.md),

                // Release notes section
                const Text(
                  "What's New",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: QuizSpacing.sm),
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  width: double.infinity,
                  padding: const EdgeInsets.all(QuizSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(QuizBorderRadius.sm),
                    border: Border.all(
                      color: AppColors.primaryLighter,
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      releaseNotes.isEmpty
                          ? 'Bug fixes and performance improvements.'
                          : releaseNotes,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: QuizSpacing.lg),

                // Actions
                Row(
                  children: [
                    // Later button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(
                            vertical: QuizSpacing.md,
                          ),
                        ),
                        child: const Text(
                          'Later',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: QuizSpacing.md),
                    // Update button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _launchUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: QuizSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              QuizBorderRadius.sm,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download_rounded, size: 20),
                            SizedBox(width: QuizSpacing.sm),
                            Text(
                              'Update',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
