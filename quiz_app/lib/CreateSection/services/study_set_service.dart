import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/CreateSection/models/study_set.dart';

import '../../api_config.dart';

/// StudySetService - Now uses /course-pack endpoints
/// The StudySet model is kept for backward compatibility
class StudySetService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Save Study Set (as Course Pack) to MongoDB via Backend API
  static Future<String> saveStudySet(StudySet studySet) async {
    try {
      debugPrint('========================================');
      debugPrint('Creating course pack (from study set)...');
      final jsonData = studySet.toJson();
      debugPrint('Course pack JSON: ${jsonEncode(jsonData)}');
      debugPrint('URL: $baseUrl/course-pack');
      debugPrint('========================================');

      final response = await http
          .post(
            Uri.parse('$baseUrl/course-pack'),
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
            throw Exception('Server response missing course pack ID');
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
            'Failed to create course pack: ${errorBody['detail'] ?? 'Unknown error'}',
          );
        } catch (e) {
          throw Exception(
            'Failed to create course pack: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e) {
      debugPrint('Exception in saveStudySet: $e');
      throw Exception('Failed to save course pack: $e');
    }
  }

  /// Fetch Study Set (Course Pack) by ID
  static Future<StudySet?> fetchStudySetById(String id) async {
    try {
      debugPrint('Fetching course pack with ID: $id');

      final response = await http
          .get(Uri.parse('$baseUrl/course-pack/$id'), headers: _headers)
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
        // Backend returns { "success": true, "coursePack": {...} }
        if (data['coursePack'] != null) {
          debugPrint('Course pack data found, parsing...');
          return StudySet.fromJson(data['coursePack']);
        }
        return null;
      } else if (response.statusCode == 404) {
        debugPrint('Course pack not found (404)');
        return null;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to fetch course pack: ${errorBody['detail'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch course pack: $e');
    }
  }

  /// Fetch all Study Sets (Course Packs) for a user
  static Future<List<StudySet>> fetchStudySetsByUserId(String userId) async {
    try {
      debugPrint('Fetching course packs for user: $userId');

      final response = await http
          .get(
            Uri.parse('$baseUrl/course-pack/user/$userId'),
            headers: _headers,
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coursePacks = data['coursePacks'] ?? [];
        return coursePacks.map((json) => StudySet.fromJson(json)).toList();
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to fetch course packs: ${errorBody['detail'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch course packs: $e');
    }
  }

  /// Delete Study Set (Course Pack)
  static Future<void> deleteStudySet(String id) async {
    try {
      debugPrint('Deleting course pack with ID: $id');

      final response = await http
          .delete(Uri.parse('$baseUrl/course-pack/$id'), headers: _headers)
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
          'Failed to delete course pack: ${errorBody['detail'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete course pack: $e');
    }
  }

  /// Update Study Set (Course Pack)
  static Future<void> updateStudySet(StudySet studySet) async {
    try {
      final updatedStudySet = studySet.copyWith(updatedAt: DateTime.now());

      debugPrint('Updating course pack with ID: ${updatedStudySet.id}');
      debugPrint('Updated data: ${updatedStudySet.toJson()}');

      final response = await http
          .put(
            Uri.parse('$baseUrl/course-pack/${updatedStudySet.id}'),
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
          'Failed to update course pack: ${errorBody['detail'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Failed to update course pack: $e');
    }
  }

  /// Create share code for a Study Set (Course Pack)
  static Future<Map<String, dynamic>> createShareCode(String id) async {
    try {
      debugPrint('Creating share code for course pack: $id');

      final response = await http
          .post(
            Uri.parse('$baseUrl/course-pack/$id/create-share-code'),
            headers: _headers,
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

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to create share code: ${errorBody['detail'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Failed to create share code: $e');
    }
  }

  /// Add Study Set (Course Pack) to library using share code
  static Future<Map<String, dynamic>> addToLibrary(
    String shareCode,
    String userId,
  ) async {
    try {
      debugPrint('Adding course pack with share code: $shareCode');

      final response = await http
          .post(
            Uri.parse('$baseUrl/course-pack/add-to-library'),
            headers: _headers,
            body: jsonEncode({'share_code': shareCode, 'user_id': userId}),
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

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['detail'] ?? 'Failed to add course pack to library',
        );
      }
    } catch (e) {
      throw Exception('Failed to add course pack: $e');
    }
  }
}
