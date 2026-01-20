import 'package:flutter/material.dart';

/// Design constants for consistent UI across the app
/// Contains spacing, sizing, durations, and other reusable values

/// Spacing constants for consistent margins and padding
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
  static const double massive = 64.0;
}

/// Icon sizes for consistent iconography
class AppIconSizes {
  AppIconSizes._();

  static const double xs = 12.0;
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double huge = 64.0;
}

/// Font sizes for consistent typography
class AppFontSizes {
  AppFontSizes._();

  static const double xs = 10.0;
  static const double sm = 12.0;
  static const double md = 14.0;
  static const double lg = 16.0;
  static const double xl = 18.0;
  static const double xxl = 20.0;
  static const double heading3 = 24.0;
  static const double heading2 = 28.0;
  static const double heading1 = 32.0;
  static const double display = 40.0;
}

/// Border radius constants for consistent rounded corners
class AppBorderRadius {
  AppBorderRadius._();

  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 28.0;
  static const double circular = 999.0;

  /// Common BorderRadius objects
  static final BorderRadius smallAll = BorderRadius.circular(sm);
  static final BorderRadius mediumAll = BorderRadius.circular(md);
  static final BorderRadius largeAll = BorderRadius.circular(lg);
  static final BorderRadius xlAll = BorderRadius.circular(xl);
  static final BorderRadius circularAll = BorderRadius.circular(circular);
}

/// Animation durations for consistent timing
class AppDurations {
  AppDurations._();

  static const Duration instant = Duration.zero;
  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 600);
  static const Duration veryLong = Duration(milliseconds: 800);
  static const Duration extraLong = Duration(milliseconds: 1000);

  /// For specific use cases
  static const Duration snackBar = Duration(seconds: 2);
  static const Duration snackBarLong = Duration(seconds: 3);
  static const Duration tooltip = Duration(seconds: 2);
  static const Duration splashScreen = Duration(seconds: 2);
  static const Duration highlightPulse = Duration(milliseconds: 1500);
  static const Duration loadingTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
}

/// Elevation values for consistent shadows
class AppElevation {
  AppElevation._();

  static const double none = 0.0;
  static const double xs = 1.0;
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double xxl = 16.0;
}

/// Opacity values for consistent transparency
class AppOpacity {
  AppOpacity._();

  static const double transparent = 0.0;
  static const double disabled = 0.38;
  static const double hint = 0.5;
  static const double medium = 0.6;
  static const double high = 0.8;
  static const double almostOpaque = 0.9;
  static const double opaque = 1.0;

  /// Common alpha values for withValues(alpha: x)
  static const double overlay = 0.5;
  static const double scrim = 0.3;
  static const double shadow = 0.15;
  static const double lightShadow = 0.1;
  static const double subtleShadow = 0.05;
}

/// Common sizes for buttons, cards, etc.
class AppSizes {
  AppSizes._();

  // Button heights
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 52.0;

  // Icon button sizes
  static const double iconButtonSmall = 34.0;
  static const double iconButtonMedium = 40.0;
  static const double iconButtonLarge = 48.0;

  // Avatar sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 40.0;
  static const double avatarLarge = 56.0;
  static const double avatarXLarge = 80.0;

  // Thumbnail sizes
  static const double thumbnailWidth = 105.0;
  static const double thumbnailHeight = 140.0;

  // Card sizes
  static const double cardMinHeight = 100.0;
  static const double cardMaxWidth = 400.0;

  // Loader sizes
  static const double loaderSmall = 20.0;
  static const double loaderMedium = 36.0;
  static const double loaderLarge = 48.0;

  // Stroke widths
  static const double strokeThin = 1.0;
  static const double strokeMedium = 2.0;
  static const double strokeThick = 3.0;

  // Progress indicator
  static const double progressIndicatorStroke = 3.0;
}

/// Common EdgeInsets for consistent padding
class AppPadding {
  AppPadding._();

  static const EdgeInsets none = EdgeInsets.zero;
  static const EdgeInsets allXs = EdgeInsets.all(AppSpacing.xs);
  static const EdgeInsets allSm = EdgeInsets.all(AppSpacing.sm);
  static const EdgeInsets allMd = EdgeInsets.all(AppSpacing.md);
  static const EdgeInsets allLg = EdgeInsets.all(AppSpacing.lg);
  static const EdgeInsets allXl = EdgeInsets.all(AppSpacing.xl);
  static const EdgeInsets allXxl = EdgeInsets.all(AppSpacing.xxl);

  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
  );
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
  );
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
  );
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(
    horizontal: AppSpacing.xl,
  );

  static const EdgeInsets verticalSm = EdgeInsets.symmetric(
    vertical: AppSpacing.sm,
  );
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(
    vertical: AppSpacing.md,
  );
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(
    vertical: AppSpacing.lg,
  );

  /// Screen padding (safe area)
  static const EdgeInsets screen = EdgeInsets.all(AppSpacing.lg);
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
  );
}
