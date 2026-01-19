import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_version_service.dart';

/// Provider for the AppVersionService
final appVersionServiceProvider = Provider<AppVersionService>((ref) {
  return AppVersionService();
});

/// Provider that checks for app updates
/// Returns AppVersionInfo if update available, null otherwise
final appUpdateCheckProvider = FutureProvider<AppVersionInfo?>((ref) async {
  final versionService = ref.read(appVersionServiceProvider);
  return versionService.checkForUpdate();
});
