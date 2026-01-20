import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../utils/app_logger.dart';

/// Model for app version info from Firebase
class AppVersionInfo {
  final String versionNumber;
  final String releaseNotes;

  const AppVersionInfo({
    required this.versionNumber,
    required this.releaseNotes,
  });

  factory AppVersionInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppVersionInfo(
      versionNumber: data['versionNumber'] as String? ?? '1.0.0',
      releaseNotes: data['releaseNotes'] as String? ?? '',
    );
  }
}

/// Service to check app version against Firebase
class AppVersionService {
  final FirebaseFirestore _firestore;

  AppVersionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// GitHub releases URL for downloading latest APK
  static const String githubReleasesUrl =
      'https://github.com/ABBEY-ANYTHING/QUEEZ/releases/latest';

  /// Direct download URL for the arm64 APK
  static const String directDownloadUrl =
      'https://github.com/ABBEY-ANYTHING/QUEEZ/releases/latest/download/Queez-arm64-v8a.apk';

  /// Fetches the latest version info from Firebase
  Future<AppVersionInfo?> getLatestVersionInfo() async {
    try {
      final doc = await _firestore
          .collection('app_version')
          .doc('current')
          .get();

      if (!doc.exists) {
        return null;
      }

      return AppVersionInfo.fromFirestore(doc);
    } catch (e) {
      // Log error but don't crash the app
      AppLogger.error('Error fetching app version: $e');
      return null;
    }
  }

  /// Gets the current installed app version
  Future<String> getCurrentAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// Checks if an update is available
  /// Returns null if no update needed, or AppVersionInfo if update available
  Future<AppVersionInfo?> checkForUpdate() async {
    final latestVersionInfo = await getLatestVersionInfo();
    if (latestVersionInfo == null) {
      return null;
    }

    final currentVersion = await getCurrentAppVersion();

    if (_isNewerVersion(latestVersionInfo.versionNumber, currentVersion)) {
      return latestVersionInfo;
    }

    return null;
  }

  /// Compares version strings to determine if newVersion is newer than currentVersion
  /// Supports semantic versioning (e.g., 1.2.3)
  bool _isNewerVersion(String newVersion, String currentVersion) {
    final newParts = newVersion
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    final currentParts = currentVersion
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    // Pad shorter version with zeros
    while (newParts.length < 3) {
      newParts.add(0);
    }
    while (currentParts.length < 3) {
      currentParts.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (newParts[i] > currentParts[i]) {
        return true;
      } else if (newParts[i] < currentParts[i]) {
        return false;
      }
    }

    return false; // Versions are equal
  }
}
