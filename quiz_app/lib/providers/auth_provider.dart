import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_provider.g.dart';

/// App State model for authentication and navigation
class AppState {
  final bool isLoading;
  final bool loggedIn;
  final bool profileSetupCompleted;
  final String lastRoute;

  AppState({
    required this.isLoading,
    required this.loggedIn,
    required this.profileSetupCompleted,
    required this.lastRoute,
  });

  AppState copyWith({
    bool? isLoading,
    bool? loggedIn,
    bool? profileSetupCompleted,
    String? lastRoute,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      loggedIn: loggedIn ?? this.loggedIn,
      profileSetupCompleted:
          profileSetupCompleted ?? this.profileSetupCompleted,
      lastRoute: lastRoute ?? this.lastRoute,
    );
  }

  factory AppState.initial() {
    return AppState(
      isLoading: true,
      loggedIn: false,
      profileSetupCompleted: false,
      lastRoute: '/login',
    );
  }
}

/// Provider for SharedPreferences instance
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(ref) async {
  return await SharedPreferences.getInstance();
}

/// Provider for app authentication state
@Riverpod(keepAlive: true)
class AppAuth extends _$AppAuth {
  @override
  Future<AppState> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);

    // Check Firebase Auth state first
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // If Firebase user is null, user is definitely logged out
    if (firebaseUser == null) {
      // Clear any stale SharedPreferences
      await prefs.setBool('loggedIn', false);
      await prefs.setString('lastRoute', '/login');

      return AppState(
        isLoading: false,
        loggedIn: false,
        profileSetupCompleted: false,
        lastRoute: '/login',
      );
    }

    // Firebase user exists, check profile setup status
    final profileSetupCompleted =
        prefs.getBool('profileSetupCompleted') ?? false;

    // If profile setup status is not in SharedPreferences, check Firestore
    if (!profileSetupCompleted) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        // Check if profile is properly setup with essential fields
        bool hasCompleteProfile = false;
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data()!;
          final hasName =
              data.containsKey('name') &&
              data['name'] != null &&
              data['name'].toString().isNotEmpty;
          final hasRole =
              data.containsKey('role') &&
              data['role'] != null &&
              data['role'].toString().isNotEmpty;

          hasCompleteProfile = hasName && hasRole;
        }

        if (hasCompleteProfile) {
          // Profile exists in Firestore with essential fields, mark as completed
          await prefs.setBool('profileSetupCompleted', true);
          await prefs.setBool('loggedIn', true);
          await prefs.setString('lastRoute', '/dashboard');

          return AppState(
            isLoading: false,
            loggedIn: true,
            profileSetupCompleted: true,
            lastRoute: '/dashboard',
          );
        } else {
          // Profile doesn't exist or incomplete, needs setup
          await prefs.setBool('loggedIn', true);
          await prefs.setBool('profileSetupCompleted', false);
          await prefs.setString('lastRoute', '/profile_welcome');

          return AppState(
            isLoading: false,
            loggedIn: true,
            profileSetupCompleted: false,
            lastRoute: '/profile_welcome',
          );
        }
      } catch (e) {
        AppLogger.error('Error checking profile: $e');
        // On error, assume profile not setup
        return AppState(
          isLoading: false,
          loggedIn: true,
          profileSetupCompleted: false,
          lastRoute: '/profile_welcome',
        );
      }
    }

    // User is logged in and profile is setup
    final lastRoute = prefs.getString('lastRoute') ?? '/dashboard';
    await prefs.setBool('loggedIn', true);

    return AppState(
      isLoading: false,
      loggedIn: true,
      profileSetupCompleted: true,
      lastRoute: lastRoute,
    );
  }

  /// Login user
  Future<void> login({bool? profileCompleted, String? lastRoute}) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool('loggedIn', true);

    if (profileCompleted != null) {
      await prefs.setBool('profileSetupCompleted', profileCompleted);
    }

    if (lastRoute != null) {
      await prefs.setString('lastRoute', lastRoute);
    } else {
      await prefs.setString('lastRoute', '/dashboard');
    }

    ref.invalidateSelf();
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool('loggedIn', false);
    await prefs.setString('lastRoute', '/login');
    ref.invalidateSelf();
  }

  /// Mark profile setup as completed
  Future<void> completeProfileSetup() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool('profileSetupCompleted', true);
    ref.invalidateSelf();
  }

  /// Update last route
  Future<void> updateLastRoute(String route) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString('lastRoute', route);
    ref.invalidateSelf();
  }
}
