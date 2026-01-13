import 'package:flutter/material.dart';
import '../../utils/color.dart';
import '../../utils/quiz_design_system.dart';

/// Custom SnackBar component that replaces all basic SnackBar instances
/// Provides consistent styling with AppColors and animations
class AppSnackBar {
  /// Show error snackbar with red background
  static void showError(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
    );
  }

  /// Show success snackbar with green background
  static void showSuccess(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  /// Show warning snackbar with orange background
  static void showWarning(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_outlined,
    );
  }

  /// Show info snackbar with blue background
  static void showInfo(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.info,
      icon: Icons.info_outline,
    );
  }

  /// Show custom snackbar with specified colors
  static void showCustom({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: backgroundColor ?? AppColors.primary,
      textColor: textColor,
      icon: icon,
      duration: duration,
    );
  }

  /// Internal method to show snackbar
  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
  }) {
    // Capture the ScaffoldMessengerState before creating the snackbar
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor ?? AppColors.white, size: 20),
            const SizedBox(width: QuizSpacing.md),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor ?? AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(QuizBorderRadius.sm),
      ),
      margin: const EdgeInsets.all(QuizSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: QuizSpacing.md,
        vertical: QuizSpacing.md,
      ),
      duration: duration ?? const Duration(seconds: 3),
      elevation: 4,
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: textColor ?? AppColors.white,
        onPressed: () {
          // Use the captured scaffoldMessenger instead of looking it up again
          scaffoldMessenger.hideCurrentSnackBar();
        },
      ),
    );

    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
