import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/CreateSection/models/study_set.dart';
import '../../api_config.dart';

class StudySetService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Save Study Set to MongoDB via Backend API
  static Future<String> saveStudySet(StudySet studySet) async {
    try {
      debugPrint('========================================');
      debugPrint('Creating study set...');
      final jsonData = studySet.toJson();
      debugPrint('Study set JSON: ${jsonEncode(jsonData)}');
      debugPrint('URL: $baseUrl/study-sets');
      debugPrint('========================================');

      final response = await http
          .post(
            Uri.parse('$baseUrl/study-sets'),
            headers: _headers,
            body: jsonEncode(jsonData),
          )
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          if (data['id'] == null) {
            throw Exception('Server response missing study set ID');
          }
          return data['id'].toString();
        } catch (e) {
          debugPrint('Error parsing response: $e');
          debugPrint('Response was: ${response.body}');
          rethrow;
        }
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(
            'Failed to create study set: ${errorBody['detail'] ?? 'Unknown error'}',
          );
        } catch (e) {
          throw Exception(
            'Failed to create study set: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e) {
      debugPrint('Exception in saveStudySet: $e');
      throw Exception('Failed to save study set: $e');
    }
  }

  /// Fetch Study Set by ID
  static Future<StudySet?> fetchStudySetById(String id) async {
    try {
      debugPrint('Fetching study set with ID: $id');

      final response = await http
          .get(Uri.parse('$baseUrl/study-sets/$id'), headers: _headers)
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns { "success": true, "studySet": {...} }
        if (data['studySet'] != null) {
          debugPrint('Study set data found, parsing...');
          return StudySet.fromJson(data['studySet']);
        }
        return null;
      } else if (response.statusCode == 404) {
        debugPrint('Study set not found (404)');
        return null;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to fetch study set: ${errorBody['detail'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch study set: $e');
    }
  }

  /// Fetch all Study Sets for a user
  static Future<List<StudySet>> fetchStudySetsByUserId(String userId) async {
    try {
      debugPrint('Fetching study sets for user: $userId');

      final response = await http
          .get(Uri.parse('$baseUrl/study-sets/user/$userId'), headers: _headers)
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      debugPrint('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => StudySet.fromJson(json)).toList();
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to fetch study sets: ${errorBody['detail'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch study sets: $e');
    }
  }

  /// Delete Study Set
  static Future<void> deleteStudySet(String id) async {
    try {
      debugPrint('Deleting study set with ID: $id');

      final response = await http
          .delete(Uri.parse('$baseUrl/study-sets/$id'), headers: _headers)
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      debugPrint('Response status code: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to delete study set: ${errorBody['detail'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete study set: $e');
    }
  }

  /// Update Study Set
  static Future<void> updateStudySet(StudySet studySet) async {
    try {
      final updatedStudySet = studySet.copyWith(updatedAt: DateTime.now());

      debugPrint('Updating study set with ID: ${updatedStudySet.id}');
      debugPrint('Updated data: ${updatedStudySet.toJson()}');

      final response = await http
          .put(
            Uri.parse('$baseUrl/study-sets/${updatedStudySet.id}'),
            headers: _headers,
            body: jsonEncode(updatedStudySet.toJson()),
          )
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      debugPrint('Response status code: ${response.statusCode}');

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to update study set: ${errorBody['detail'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Failed to update study set: $e');
    }
  }
}
