import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_app/CreateSection/models/study_set.dart';
import 'package:quiz_app/utils/app_logger.dart';
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
      AppLogger.debug('Saving study set: ${studySet.name}');
      final jsonData = studySet.toJson();

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          if (data['id'] == null) {
            throw Exception('Server response missing study set ID');
          }
          AppLogger.success('Study set created: ${data['id']}');
          return data['id'].toString();
        } catch (e) {
          AppLogger.error('Failed to parse response: $e');
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
      AppLogger.error('Study set save failed: $e');
      throw Exception('Failed to save study set: $e');
    }
  }

  /// Fetch Study Set by ID (checks both study_sets and course_pack collections)
  static Future<StudySet?> fetchStudySetById(String id) async {
    try {
      AppLogger.debug('Fetching study set with ID: $id');

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns { "success": true, "studySet": {...} }
        if (data['studySet'] != null) {
          AppLogger.debug('Study set loaded: $id');
          return StudySet.fromJson(data['studySet']);
        }
        return null;
      } else if (response.statusCode == 404) {
        AppLogger.debug(
          'Study set not in main endpoint, trying course_pack...',
        );

        // Fallback: try fetching from course_pack endpoint
        try {
          final coursePackResponse = await http
              .get(Uri.parse('$baseUrl/course-packs/$id'), headers: _headers)
              .timeout(
                Duration(seconds: 30),
                onTimeout: () {
                  throw Exception(
                    'Request timed out. Please check your internet connection.',
                  );
                },
              );

          if (coursePackResponse.statusCode == 200) {
            final data = jsonDecode(coursePackResponse.body);
            if (data['coursePack'] != null) {
              AppLogger.debug('Course pack loaded: $id');
              // Convert course pack to StudySet format
              return StudySet.fromJson(data['coursePack']);
            }
          }
        } catch (e) {
          AppLogger.warning('Course pack fetch failed: $e');
        }

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
      AppLogger.debug('Fetching study sets for user: $userId');

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        AppLogger.success('Loaded ${data.length} study sets');
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
      AppLogger.debug('Deleting study set with ID: $id');

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

      AppLogger.debug('Response status code: ${response.statusCode}');

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

      AppLogger.debug('Updating study set with ID: ${updatedStudySet.id}');
      AppLogger.debug('Updated data: ${updatedStudySet.toJson()}');

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

      AppLogger.debug('Response status code: ${response.statusCode}');

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
