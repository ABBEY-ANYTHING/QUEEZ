import 'package:flutter/material.dart';
import 'package:quiz_app/ProfileSetup/screens/completion_screen.dart';
import 'package:quiz_app/ProfileSetup/screens/profile_setup_screen.dart';

/// Map of routes for the profile setup flow
Map<String, Widget Function(BuildContext)> profileSetupRoutes = {
  '/profile_welcome': (context) => const ProfileSetupScreen(),
  '/profile_complete': (context) => const CompletionScreen(),
};
