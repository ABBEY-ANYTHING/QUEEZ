// lib/services/active_session_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api_config.dart';
import '../utils/app_logger.dart';

/// Service to manage active session persistence and recovery
/// This enables users to rejoin a quiz after closing/reopening the app
class ActiveSessionService {
  static const String _sessionCodeKey = 'active_session_code';
  static const String _userIdKey = 'active_session_user_id';
  static const String _usernameKey = 'active_session_username';
  static const String _isHostKey = 'active_session_is_host';
  static const String _joinedAtKey = 'active_session_joined_at';
  static const String _quizIdKey = 'active_session_quiz_id';
  static const String _quizTitleKey = 'active_session_quiz_title';
  static const String _modeKey = 'active_session_mode';

  /// Save active session info to local storage
  static Future<void> saveActiveSession({
    required String sessionCode,
    required String userId,
    required String username,
    required bool isHost,
    String? quizId,
    String? quizTitle,
    String? mode,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionCodeKey, sessionCode);
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_usernameKey, username);
      await prefs.setBool(_isHostKey, isHost);
      await prefs.setString(_joinedAtKey, DateTime.now().toIso8601String());
      if (quizId != null) await prefs.setString(_quizIdKey, quizId);
      if (quizTitle != null) await prefs.setString(_quizTitleKey, quizTitle);
      if (mode != null) await prefs.setString(_modeKey, mode);
      AppLogger.success('Saved active session: $sessionCode (host: $isHost)');
    } catch (e) {
      AppLogger.error('Failed to save active session: $e');
    }
  }

  /// Get locally stored active session info
  static Future<Map<String, dynamic>?> getLocalActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCode = prefs.getString(_sessionCodeKey);
      final userId = prefs.getString(_userIdKey);
      final username = prefs.getString(_usernameKey);
      final isHost = prefs.getBool(_isHostKey);
      final joinedAt = prefs.getString(_joinedAtKey);
      final quizId = prefs.getString(_quizIdKey);
      final quizTitle = prefs.getString(_quizTitleKey);
      final mode = prefs.getString(_modeKey);

      if (sessionCode == null || userId == null) {
        return null;
      }

      // Check if session is too old (more than 4 hours)
      if (joinedAt != null) {
        final joinedTime = DateTime.tryParse(joinedAt);
        if (joinedTime != null) {
          final hoursSinceJoin = DateTime.now().difference(joinedTime).inHours;
          if (hoursSinceJoin > 4) {
            AppLogger.info('Active session too old ($hoursSinceJoin hours), clearing');
            await clearActiveSession();
            return null;
          }
        }
      }

      return {
        'session_code': sessionCode,
        'user_id': userId,
        'username': username ?? 'Anonymous',
        'is_host': isHost ?? false,
        'joined_at': joinedAt,
        'quiz_id': quizId,
        'quiz_title': quizTitle,
        'mode': mode,
      };
    } catch (e) {
      AppLogger.error('Failed to get local active session: $e');
      return null;
    }
  }

  /// Clear active session from local storage
  static Future<void> clearActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionCodeKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_usernameKey);
      await prefs.remove(_isHostKey);
      await prefs.remove(_joinedAtKey);
      await prefs.remove(_quizIdKey);
      await prefs.remove(_quizTitleKey);
      await prefs.remove(_modeKey);
      AppLogger.success('Cleared active session from local storage');
    } catch (e) {
      AppLogger.error('Failed to clear active session: $e');
    }
  }

  /// Check with backend if user has an active session
  static Future<Map<String, dynamic>?> checkActiveSessionWithBackend(
    String userId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/api/multiplayer/user/$userId/active-session',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['has_active_session'] == true) {
          AppLogger.success('Backend confirms active session: ${data['session_code']}');
          return data;
        } else {
          // No active session on backend, clear local storage
          await clearActiveSession();
          return null;
        }
      } else {
        AppLogger.warning('Backend returned ${response.statusCode}');
        return null;
      }
    } on SocketException {
      AppLogger.network('Network error checking active session');
      // Return local data as fallback
      return await getLocalActiveSession();
    } catch (e) {
      AppLogger.error('Error checking active session with backend: $e');
      return null;
    }
  }

  /// Clear active session on backend
  static Future<void> clearActiveSessionOnBackend(String userId) async {
    try {
      await http
          .delete(
            Uri.parse(
              '${ApiConfig.baseUrl}/api/multiplayer/user/$userId/active-session',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      AppLogger.success('Cleared active session on backend');
    } catch (e) {
      AppLogger.warning('Failed to clear active session on backend: $e');
    }
  }

  /// Full cleanup - clears both local and backend
  static Future<void> fullCleanup(String userId) async {
    await clearActiveSession();
    await clearActiveSessionOnBackend(userId);
  }
}
