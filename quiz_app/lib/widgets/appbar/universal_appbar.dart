import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

/// A universal app bar that provides consistent navigation across the app.
///
/// Features:
/// - Shows a back button on the left when navigation is possible (not on home screen)
/// - Shows the page title in the center
/// - Shows a notification bell icon on the right
///
/// Usage:
/// ```dart
/// Scaffold(
///   appBar: UniversalAppBar(title: 'Create Assessment'),
///   body: ...
/// )
/// ```
class UniversalAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the center of the app bar
  final String title;

  /// Whether to show the back button. If null, automatically determines
  /// based on Navigator.canPop()
  final bool? showBackButton;

  /// Whether to show the notification bell. Defaults to true.
  final bool showNotificationBell;

  /// Custom action widgets to show instead of the notification bell
  final List<Widget>? actions;

  /// Custom leading widget to show instead of the default back button or leaf icon
  final Widget? leading;

  /// Callback when the notification bell is tapped
  final VoidCallback? onNotificationTap;

  /// Callback when the back button is tapped. If null, uses Navigator.pop()
  final VoidCallback? onBackTap;

  const UniversalAppBar({
    super.key,
    required this.title,
    this.showBackButton,
    this.showNotificationBell = true,
    this.actions,
    this.leading,
    this.onNotificationTap,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if we should show back button
    final canPop = Navigator.of(context).canPop();
    final shouldShowBackButton = showBackButton ?? canPop;

    // Build leading widget
    Widget? leadingWidget;
    if (leading != null) {
      leadingWidget = leading;
    } else if (shouldShowBackButton) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        color: AppColors.iconActive,
        onPressed: onBackTap ?? () => Navigator.of(context).pop(),
      );
    } else {
      leadingWidget = Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.eco, color: AppColors.primaryDark, size: 28)],
        ),
      );
    }

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leading: leadingWidget,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      actions:
          actions ??
          [
            if (showNotificationBell)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: AppColors.iconActive,
                    size: 26,
                  ),
                  onPressed:
                      onNotificationTap ??
                      () {
                        // Handle notification tap - can be implemented later
                      },
                ),
              ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
