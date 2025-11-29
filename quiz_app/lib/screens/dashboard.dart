import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/library_provider.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/globals.dart';
import 'package:quiz_app/widgets/appbar/appbar.dart';
import 'package:quiz_app/widgets/core/app_dialog.dart';
import 'package:quiz_app/widgets/navbar/bottom_navbar.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  @override
  void initState() {
    super.initState();
    // Preload library data in the background when dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizLibraryProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Try to pop from the current nested navigator first
        final navbarState = bottomNavbarKey.currentState;
        if (navbarState != null && navbarState.canPopCurrentNavigator()) {
          navbarState.popCurrentNavigator();
        } else {
          // If no nested route to pop, exit the app
          if (context.mounted) {
            final shouldExit = await AppDialog.show<bool>(
              context: context,
              title: 'Exit App',
              content: 'Do you want to exit the app?',
              primaryActionText: 'Exit',
              primaryActionCallback: () => Navigator.of(context).pop(true),
              secondaryActionText: 'Cancel',
              secondaryActionCallback: () => Navigator.of(context).pop(false),
            );

            if (shouldExit == true && context.mounted) {
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: Appbar(),
        body: BottomNavbarController(key: bottomNavbarKey),
        backgroundColor: AppColors.background,
      ),
    );
  }
}
