import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/app_version_service.dart';
import '../../utils/color.dart';
import '../../utils/quiz_design_system.dart';

/// A modern, clean update dialog that shows version transition and release notes.
class AppUpdateDialog extends StatelessWidget {
  final String newVersion;
  final String currentVersion;
  final String releaseNotes;

  const AppUpdateDialog({
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
      builder: (context) => AppUpdateDialog(
        newVersion: versionInfo.versionNumber,
        currentVersion: currentVersion,
        releaseNotes: versionInfo.releaseNotes,
      ),
    );
  }

  Future<void> _launchUpdate(BuildContext context) async {
    // Direct download URL for the APK
    final downloadUri = Uri.parse(AppVersionService.getDownloadUrl(newVersion));

    try {
      // Launch the APK download directly
      // No need to use canLaunchUrl as it may incorrectly return false for APK downloads
      final launched = await launchUrl(
        downloadUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        // If direct download fails, show error with option to visit releases page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not start download automatically.'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Open Releases',
              textColor: Colors.white,
              onPressed: () {
                launchUrl(
                  Uri.parse(AppVersionService.githubReleasesUrl),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error launching update: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to launch update. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            scale: 0.9 + (0.1 * value), // Subtle scale effect
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
            padding: const EdgeInsets.all(
              QuizSpacing.xl,
            ), // Increased padding for cleaner look
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(QuizSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded, // More exciting icon
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: QuizSpacing.md),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update Available',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'A new version of Queez is ready!',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: QuizSpacing.xl),

                // Version Transition Visualization
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: QuizSpacing.md,
                    horizontal: QuizSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Current Version
                      Expanded(
                        child: _buildVersionBadge(
                          label: 'Current',
                          version: currentVersion,
                          isCurrent: true,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: QuizSpacing.sm,
                        ),
                        child: Icon(
                          Icons.arrow_right_alt_rounded,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                          size: 20,
                        ),
                      ),

                      // New Version
                      Expanded(
                        child: _buildVersionBadge(
                          label: 'New',
                          version: newVersion,
                          isNew: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: QuizSpacing.xl),

                // Release Notes
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
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: SingleChildScrollView(
                    child: _buildReleaseNotesList(releaseNotes),
                  ),
                ),

                const SizedBox(height: QuizSpacing.xl),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: QuizSpacing.md,
                          vertical: QuizSpacing.sm,
                        ),
                      ),
                      child: const Text('Later'),
                    ),
                    const SizedBox(width: QuizSpacing.sm),
                    ElevatedButton.icon(
                      onPressed: () => _launchUpdate(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: QuizSpacing.md,
                          vertical: QuizSpacing.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            QuizBorderRadius.sm,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text(
                        'Update',
                        style: TextStyle(fontWeight: FontWeight.w600),
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

  Widget _buildVersionBadge({
    required String label,
    required String version,
    bool isCurrent = false,
    bool isNew = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: isNew ? AppColors.primary : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: QuizSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isNew
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(QuizBorderRadius.sm),
            ),
            child: Text(
              'v$version',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isNew ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReleaseNotesList(String notes) {
    if (notes.isEmpty) {
      return const Text(
        '• Bug fixes and performance improvements',
        style: TextStyle(color: AppColors.textSecondary, height: 1.5),
      );
    }

    final lines = notes.split('\n').where((l) => l.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        String cleanLine = line.trim();
        // Remove existing bullets if present
        if (cleanLine.startsWith('- ') ||
            cleanLine.startsWith('* ') ||
            cleanLine.startsWith('• ')) {
          cleanLine = cleanLine.substring(2);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.circle, size: 4, color: AppColors.primary),
              ),
              const SizedBox(width: QuizSpacing.md),
              Expanded(
                child: Text(
                  cleanLine,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
