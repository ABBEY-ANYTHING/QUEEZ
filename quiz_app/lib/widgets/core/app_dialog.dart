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

  /// Show dialog with custom barrier color and animation.
  ///
  /// For dialogs that need to return a value, use [showInput] instead.
  /// This method automatically closes the dialog after button actions.
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
      builder: (dialogContext) => _AppDialogInternal(
        title: title,
        content: content,
        primaryActionText: primaryActionText,
        primaryActionCallback: primaryActionCallback != null
            ? () {
                primaryActionCallback();
                Navigator.of(dialogContext).pop();
              }
            : null,
        secondaryActionText: secondaryActionText,
        secondaryActionCallback: secondaryActionCallback != null
            ? () {
                secondaryActionCallback();
                Navigator.of(dialogContext).pop();
              }
            : null,
        dismissible: dismissible,
        showCloseIcon: showCloseIcon,
        dialogContext: dialogContext,
      ),
    );
  }

  /// Show an input dialog that can return a value.
  ///
  /// The [onSubmit] callback should return the value to be returned by the dialog.
  /// The [onCancel] callback is optional and returns null by default.
  static Future<T?> showInput<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    required String submitText,
    required T? Function() onSubmit,
    String cancelText = 'Cancel',
    bool dismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      barrierColor: AppColors.primary.withValues(alpha: 0.3),
      builder: (dialogContext) => _AppDialogInput<T>(
        title: title,
        content: content,
        submitText: submitText,
        onSubmit: onSubmit,
        cancelText: cancelText,
        dismissible: dismissible,
        dialogContext: dialogContext,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildDialogContent(context);
  }

  Widget _buildDialogContent(BuildContext context) {
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
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
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

/// Internal dialog widget that receives the dialog context
class _AppDialogInternal extends StatelessWidget {
  final String title;
  final dynamic content;
  final String? primaryActionText;
  final VoidCallback? primaryActionCallback;
  final String? secondaryActionText;
  final VoidCallback? secondaryActionCallback;
  final bool dismissible;
  final bool showCloseIcon;
  final BuildContext dialogContext;

  const _AppDialogInternal({
    required this.title,
    required this.content,
    this.primaryActionText,
    this.primaryActionCallback,
    this.secondaryActionText,
    this.secondaryActionCallback,
    this.dismissible = true,
    this.showCloseIcon = false,
    required this.dialogContext,
  });

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
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (showCloseIcon)
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
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
                      // Secondary action
                      if (secondaryActionText != null) ...[
                        Flexible(
                          child: TextButton(
                            onPressed:
                                secondaryActionCallback ??
                                () => Navigator.of(dialogContext).pop(),
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

                      // Primary action
                      if (primaryActionText != null)
                        Flexible(
                          child: ElevatedButton(
                            onPressed:
                                primaryActionCallback ??
                                () => Navigator.of(dialogContext).pop(),
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

/// Input dialog that can return a value
class _AppDialogInput<T> extends StatelessWidget {
  final String title;
  final Widget content;
  final String submitText;
  final T? Function() onSubmit;
  final String cancelText;
  final bool dismissible;
  final BuildContext dialogContext;

  const _AppDialogInput({
    required this.title,
    required this.content,
    required this.submitText,
    required this.onSubmit,
    this.cancelText = 'Cancel',
    this.dismissible = true,
    required this.dialogContext,
  });

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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: QuizSpacing.md),

                // Content
                content,

                const SizedBox(height: QuizSpacing.lg),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel button
                    Flexible(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: QuizSpacing.md,
                            vertical: QuizSpacing.md,
                          ),
                        ),
                        child: Text(cancelText),
                      ),
                    ),
                    const SizedBox(width: QuizSpacing.sm),

                    // Submit button
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () {
                          final result = onSubmit();
                          Navigator.of(dialogContext).pop(result);
                        },
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
                        child: Text(submitText),
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
