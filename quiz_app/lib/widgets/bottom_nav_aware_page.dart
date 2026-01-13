import 'package:flutter/material.dart';
import 'package:quiz_app/utils/globals.dart';

/// A wrapper widget that adds bottom padding to account for the fixed bottom navigation bar.
///
/// Use this widget to wrap page content that may be cut off by the bottom navbar.
/// This ensures buttons and other UI elements at the bottom of pages remain accessible.
///
/// Example usage:
/// ```dart
/// BottomNavAwarePage(
///   child: Column(
///     children: [...],
///   ),
/// )
/// ```
class BottomNavAwarePage extends StatelessWidget {
  /// The child widget to wrap with bottom padding.
  final Widget child;

  /// Whether to add bottom padding for the navbar. Defaults to true.
  final bool addBottomPadding;

  /// Additional bottom padding to add on top of the navbar height.
  final double extraBottomPadding;

  const BottomNavAwarePage({
    super.key,
    required this.child,
    this.addBottomPadding = true,
    this.extraBottomPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (!addBottomPadding) return child;

    return Padding(
      padding: EdgeInsets.only(
        bottom: kBottomNavbarHeight + extraBottomPadding,
      ),
      child: child,
    );
  }
}

/// A scrollable wrapper that automatically adds bottom padding for the navbar.
///
/// This is a convenience widget that combines SingleChildScrollView with
/// navbar-aware bottom padding. Use this for pages that need scrolling and
/// are displayed within the bottom navbar scaffold.
///
/// Example usage:
/// ```dart
/// NavbarAwareScrollView(
///   padding: EdgeInsets.all(20),
///   child: Column(
///     children: [...],
///   ),
/// )
/// ```
class NavbarAwareScrollView extends StatelessWidget {
  /// The child widget to scroll.
  final Widget child;

  /// Padding to apply to the scrollable content (navbar padding is added automatically).
  final EdgeInsets padding;

  /// Additional bottom padding on top of the navbar height.
  final double extraBottomPadding;

  /// Physics for the scroll view.
  final ScrollPhysics? physics;

  /// Scroll controller for the scroll view.
  final ScrollController? controller;

  const NavbarAwareScrollView({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.extraBottomPadding = 0,
    this.physics,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      physics: physics,
      padding: padding.copyWith(
        bottom: padding.bottom + kBottomNavbarHeight + extraBottomPadding,
      ),
      child: child,
    );
  }
}

/// Extension to easily add navbar-aware padding to EdgeInsets.
extension NavbarAwarePadding on EdgeInsets {
  /// Returns a copy of this EdgeInsets with navbar height added to the bottom.
  EdgeInsets get withNavbar => copyWith(bottom: bottom + kBottomNavbarHeight);
}
