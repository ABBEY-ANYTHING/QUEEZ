// lib/screens/session_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../../api_config.dart';

class SessionService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Create a new quiz session
  static Future<Map<String, dynamic>> createSession({
    required String quizId,
    required String hostId,
    required String mode,
    int? perQuestionTimeLimit,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'quiz_id': quizId,
        'host_id': hostId,
        'mode': mode,
      };

      // Add time settings if provided
      if (perQuestionTimeLimit != null) {
        body['per_question_time_limit'] = perQuestionTimeLimit;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/multiplayer/create-session'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'session_code': data['session_code'],
          'message': data['message'],
        };
      } else {
        throw Exception('Failed to create session: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      throw Exception('Error creating session: $e');
    }
  }

  // Get session information
  static Future<Map<String, dynamic>> getSessionInfo(String sessionCode) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/multiplayer/session/$sessionCode'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Session not found or expired');
      } else if (response.statusCode == 410) {
        throw Exception('Session has expired');
      } else {
        throw Exception('Error getting session info: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }

  // Get participant count
  static Future<Map<String, dynamic>> getParticipants(
    String sessionCode,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/api/multiplayer/session/$sessionCode/participants',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Session not found or expired');
      } else if (response.statusCode == 410) {
        throw Exception('Session has expired');
      } else {
        throw Exception('Error getting participants: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }

  // Join a session
  static Future<Map<String, dynamic>> joinSession({
    required String sessionCode,
    required String userId,
    required String username,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/multiplayer/session/$sessionCode/join'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId, 'username': username}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Session not found or expired');
      } else if (response.statusCode == 410) {
        throw Exception('Session has expired');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Quiz has already started');
      } else {
        throw Exception('Error joining session: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }

  // Start quiz session
  static Future<Map<String, dynamic>> startSession({
    required String sessionCode,
    required String hostId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/multiplayer/session/$sessionCode/start'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'host_id': hostId}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Session not found');
      } else if (response.statusCode == 403) {
        throw Exception('Only the host can start the quiz');
      } else {
        throw Exception('Error starting session: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }

  // Create share code for study set
  static Future<Map<String, dynamic>> createStudySetShareCode({
    required String studySetId,
    required String hostId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/study-sets/$studySetId/create-share-code'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'session_code': data['share_code'], // Backend returns share_code
          'message': data['message'],
          'expires_in': 600, // 10 minutes
        };
      } else {
        throw Exception('Failed to create share code: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      throw Exception('Error creating share code: $e');
    }
  }

  // End quiz session
  static Future<Map<String, dynamic>> endSession({
    required String sessionCode,
    required String hostId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/multiplayer/session/$sessionCode/end'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'host_id': hostId}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Session not found');
      } else if (response.statusCode == 403) {
        throw Exception('Only the host can end the quiz');
      } else {
        throw Exception('Error ending session: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }
}
