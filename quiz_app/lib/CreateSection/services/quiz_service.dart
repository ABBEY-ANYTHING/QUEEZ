// lib/services/quiz_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:quiz_app/CreateSection/models/question.dart';
import 'package:quiz_app/utils/app_logger.dart';

import '../../api_config.dart';
import '../models/quiz.dart';

class QuizService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<String> createQuiz(Quiz quiz) async {
    try {
      AppLogger.debug('Starting quiz creation...');
      AppLogger.debug('Quiz data: ${quiz.toJson()}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/quizzes'),
            headers: _headers,
            body: jsonEncode(quiz.toJson()),
          )
          .timeout(
            Duration(seconds: 30), // Add timeout to prevent infinite waiting
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      AppLogger.debug('Response status code: ${response.statusCode}');
      AppLogger.debug('Response body: ${response.body}');

      // Check for successful status codes (200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);

          // Ensure the response has an 'id' field
          if (data['id'] == null) {
            throw Exception('Server response missing quiz ID');
          }

          final quizId = data['id'].toString();
          AppLogger.success('Quiz created successfully with ID: $quizId');
          return quizId;
        } catch (e) {
          AppLogger.error('JSON parsing error: $e');
          throw Exception('Invalid response format from server');
        }
      } else {
        AppLogger.error('Failed with status code: ${response.statusCode}');
        throw Exception(
          'Server error (${response.statusCode}): ${response.body}',
        );
      }
    } on SocketException {
      AppLogger.error('Network error');
      throw Exception(
        'Network error. Please check your internet connection and server status.',
      );
    } on FormatException catch (e) {
      AppLogger.error('JSON format error: $e');
      throw Exception('Invalid response format from server');
    } on Exception catch (e) {
      AppLogger.error('Exception: $e');
      rethrow; // Re-throw custom exceptions as-is
    } catch (e) {
      AppLogger.error('Unexpected error: $e');
      throw Exception('Unexpected error occurred: $e');
    }
  }

  /// Update an existing quiz
  static Future<void> updateQuiz(Quiz quiz) async {
    try {
      if (quiz.id == null || quiz.id!.isEmpty) {
        throw Exception('Quiz ID is required for update');
      }

      AppLogger.debug('Updating quiz: ${quiz.id}');
      AppLogger.debug('Quiz data: ${quiz.toJson()}');

      final response = await http
          .put(
            Uri.parse('$baseUrl/quizzes/${quiz.id}'),
            headers: _headers,
            body: jsonEncode(quiz.toJson()),
          )
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      AppLogger.debug('Update response status: ${response.statusCode}');
      AppLogger.debug('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        AppLogger.success('Quiz updated successfully: ${quiz.id}');
      } else {
        AppLogger.error('Failed with status code: ${response.statusCode}');
        throw Exception(
          'Server error (${response.statusCode}): ${response.body}',
        );
      }
    } on SocketException {
      AppLogger.error('Network error');
      throw Exception(
        'Network error. Please check your internet connection and server status.',
      );
    } on FormatException catch (e) {
      AppLogger.error('JSON format error: $e');
      throw Exception('Invalid response format from server');
    } on Exception catch (e) {
      AppLogger.error('Exception: $e');
      rethrow;
    } catch (e) {
      AppLogger.error('Unexpected error: $e');
      throw Exception('Unexpected error occurred: $e');
    }
  }

  static Future<Quiz> getQuiz(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/quizzes/$id'), headers: _headers)
          .timeout(
            Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Quiz.fromJson(data);
      } else {
        throw Exception(
          'Failed to get quiz (${response.statusCode}): ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('Network error: Please check your connection');
    } catch (e) {
      throw Exception('Error getting quiz: $e');
    }
  }

  static Future<List<Question>> fetchQuestionsByQuizId(
    String quizId,
    String userId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/quizzes/$quizId?user_id=$userId'),
            headers: _headers,
          )
          .timeout(
            Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final questionsJson = data['questions'] as List<dynamic>;
        return questionsJson.map((q) => Question.fromJson(q)).toList();
      } else {
        throw Exception(
          'Failed to fetch quiz (${response.statusCode}): ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('Network error: Please check your connection');
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchQuizzesByCreator(
    String userId,
  ) async {
    try {
      AppLogger.debug('Fetching quizzes for user: $userId');
      final response = await http
          .get(Uri.parse('$baseUrl/quizzes/library/$userId'), headers: _headers)
          .timeout(
            Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      AppLogger.debug('Library response status: ${response.statusCode}');
      AppLogger.debug('Library response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(responseData['data'] ?? []);
      } else {
        throw Exception(
          'Failed to fetch quizzes (${response.statusCode}): ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('Network error: Please check your connection');
    } catch (e) {
      AppLogger.error('Error fetching quizzes: $e');
      throw Exception('Error fetching quizzes: $e');
    }
  }

  static Future<bool> deleteQuiz(String quizId) async {
    try {
      AppLogger.debug('Deleting quiz: $quizId');
      final response = await http
          .delete(Uri.parse('$baseUrl/quizzes/$quizId'), headers: _headers)
          .timeout(
            Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      AppLogger.debug('Delete response status: ${response.statusCode}');
      AppLogger.debug('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Quiz not found');
      } else {
        throw Exception(
          'Failed to delete quiz (${response.statusCode}): ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('Network error: Please check your connection');
    } catch (e) {
      AppLogger.error('Error deleting quiz: $e');
      throw Exception('Error deleting quiz: $e');
    }
  }

  static Future<Map<String, dynamic>> addQuizToLibrary(
    String userId,
    String quizCode,
  ) async {
    try {
      AppLogger.debug(
        'Adding quiz to library for user: $userId with code: $quizCode',
      );
      final response = await http
          .post(
            Uri.parse('$baseUrl/quizzes/add-to-library'),
            headers: _headers,
            body: jsonEncode({'user_id': userId, 'quiz_code': quizCode}),
          )
          .timeout(
            Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      AppLogger.debug('Add to library response status: ${response.statusCode}');
      AppLogger.debug('Add to library response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Quiz code not found or session expired');
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw Exception(data['detail'] ?? 'Invalid quiz code');
      } else {
        throw Exception(
          'Failed to add quiz (${response.statusCode}): ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('Network error: Please check your connection');
    } catch (e) {
      AppLogger.error('Error adding quiz to library: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Error adding quiz to library: $e');
    }
  }
}
