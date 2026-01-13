import 'package:flutter/material.dart';

import '../../utils/color.dart';
import '../../utils/quiz_design_system.dart';

/// Custom dialog component that replaces all AlertDialog instances
/// Provides consistent styling with AppColors and QuizAnimations
class AppDialog extends StatelessWidget {
  final String title;
  final dynamic content; // Can be String or Widget
  final String? primaryActionText;
  final VoidCallback? primaryActionCallback;
  final String? secondaryActionText;
  final VoidCallback? secondaryActionCallback;
  final bool dismissible;
  final bool showCloseIcon;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.primaryActionText,
    this.primaryActionCallback,
    this.secondaryActionText,
    this.secondaryActionCallback,
    this.dismissible = true,
    this.showCloseIcon = false,
  });

  /// Show dialog with custom barrier color and animation
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required dynamic content,
    String? primaryActionText,
    VoidCallback? primaryActionCallback,
    String? secondaryActionText,
    VoidCallback? secondaryActionCallback,
    bool dismissible = true,
    bool showCloseIcon = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      barrierColor: AppColors.primary.withValues(alpha: 0.3),
      builder: (context) => AppDialog(
        title: title,
        content: content,
        primaryActionText: primaryActionText,
        primaryActionCallback: primaryActionCallback,
        secondaryActionText: secondaryActionText,
        secondaryActionCallback: secondaryActionCallback,
        dismissible: dismissible,
        showCloseIcon: showCloseIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
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
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (showCloseIcon)
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: QuizSpacing.md),

                // Content
                if (content is String)
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  )
                else if (content is Widget)
                  content,

                const SizedBox(height: QuizSpacing.lg),

                // Actions
                if (primaryActionText != null || secondaryActionText != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Secondary action (if provided)
                      if (secondaryActionText != null) ...[
                        Flexible(
                          child: TextButton(
                            onPressed:
                                secondaryActionCallback ??
                                () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: QuizSpacing.md,
                                vertical: QuizSpacing.md,
                              ),
                            ),
                            child: Text(
                              secondaryActionText!,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: QuizSpacing.sm),
                      ],

                      // Primary action (if provided)
                      if (primaryActionText != null)
                        Flexible(
                          child: ElevatedButton(
                            onPressed:
                                primaryActionCallback ??
                                () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: QuizSpacing.md,
                                vertical: QuizSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  QuizBorderRadius.sm,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              primaryActionText!,
                              overflow: TextOverflow.ellipsis,
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
