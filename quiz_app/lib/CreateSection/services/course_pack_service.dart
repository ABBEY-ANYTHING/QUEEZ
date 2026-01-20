import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quiz_app/CreateSection/models/flashcard_set.dart';
import 'package:quiz_app/CreateSection/models/note.dart';
import 'package:quiz_app/CreateSection/models/quiz.dart';
import 'package:quiz_app/CreateSection/models/study_set.dart';
import 'package:quiz_app/api_config.dart';
import 'package:quiz_app/utils/app_logger.dart';

// TODO: Allow other users to claim, make a copy, and edit quizzes, flashcards, or course packs
// TODO: Fix editing of individual quizzes, flashcards and course packs

/// Model for video lecture
class VideoLecture {
  final String? id;
  final String title;
  final String driveFileId;
  final String shareableLink;
  final double duration; // Duration in minutes
  final String? uploadedAt;

  VideoLecture({
    this.id,
    required this.title,
    required this.driveFileId,
    required this.shareableLink,
    this.duration = 0.0,
    this.uploadedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'driveFileId': driveFileId,
    'shareableLink': shareableLink,
    'duration': duration,
    'uploadedAt': uploadedAt,
  };

  factory VideoLecture.fromJson(Map<String, dynamic> json) => VideoLecture(
    id: json['id'],
    title: json['title'] ?? '',
    driveFileId: json['driveFileId'] ?? '',
    shareableLink: json['shareableLink'] ?? '',
    duration: (json['duration'] ?? 0).toDouble(),
    uploadedAt: json['uploadedAt'],
  );
}

/// Model for Course Pack (replaces Study Set for marketplace)
class CoursePack {
  final String id;
  final String name;
  final String description;
  final String category;
  final String language;
  final String? coverImagePath;
  final String ownerId;
  final String? originalOwner; // Original owner if this is a claimed course
  final String? originalCoursePackId; // Original course pack ID if claimed
  final List<Quiz> quizzes;
  final List<FlashcardSet> flashcardSets;
  final List<Note> notes;
  final List<VideoLecture> videoLectures;
  final bool isPublic;
  final double rating;
  final int ratingCount;
  final int enrolledCount;
  final double estimatedHours;
  final DateTime createdAt;
  final DateTime updatedAt;

  CoursePack({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.language,
    this.coverImagePath,
    required this.ownerId,
    this.originalOwner,
    this.originalCoursePackId,
    required this.quizzes,
    required this.flashcardSets,
    required this.notes,
    required this.videoLectures,
    this.isPublic = false,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.enrolledCount = 0,
    this.estimatedHours = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns true if this course was claimed from another user
  bool get isClaimed => originalOwner != null && originalCoursePackId != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'language': language,
    'coverImagePath': coverImagePath,
    'ownerId': ownerId,
    'quizzes': quizzes.map((q) => q.toJson()).toList(),
    'flashcardSets': flashcardSets.map((f) => f.toJson()).toList(),
    'notes': notes.map((n) => n.toJson()).toList(),
    'videoLectures': videoLectures.map((v) => v.toJson()).toList(),
    'isPublic': isPublic,
    'estimatedHours': estimatedHours,
  };

  factory CoursePack.fromJson(Map<String, dynamic> json) => CoursePack(
    id: json['id'] ?? json['_id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    category: json['category'] ?? '',
    language: json['language'] ?? '',
    coverImagePath: json['coverImagePath'],
    ownerId: json['ownerId'] ?? json['owner_id'] ?? '',
    originalOwner: json['originalOwner'],
    originalCoursePackId: json['originalCoursePackId'],
    quizzes: (json['quizzes'] as List? ?? [])
        .map((q) => Quiz.fromJson(q as Map<String, dynamic>))
        .toList(),
    flashcardSets: (json['flashcardSets'] as List? ?? [])
        .map((f) => FlashcardSet.fromJson(f as Map<String, dynamic>))
        .toList(),
    notes: (json['notes'] as List? ?? [])
        .map((n) => Note.fromJson(n as Map<String, dynamic>))
        .toList(),
    videoLectures: (json['videoLectures'] as List? ?? [])
        .map((v) => VideoLecture.fromJson(v))
        .toList(),
    isPublic: json['isPublic'] ?? false,
    rating: (json['rating'] ?? 0).toDouble(),
    ratingCount: json['ratingCount'] ?? 0,
    enrolledCount: json['enrolledCount'] ?? 0,
    estimatedHours: (json['estimatedHours'] ?? 0).toDouble(),
    createdAt: _parseDate(json['createdAt']),
    updatedAt: _parseDate(json['updatedAt']),
  );

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is DateTime) return dateValue;
    try {
      return DateTime.parse(dateValue);
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Convert from StudySet to CoursePack
  factory CoursePack.fromStudySet(StudySet studySet) => CoursePack(
    id: studySet.id,
    name: studySet.name,
    description: studySet.description,
    category: studySet.category,
    language: studySet.language,
    coverImagePath: studySet.coverImagePath,
    ownerId: studySet.ownerId,
    quizzes: studySet.quizzes,
    flashcardSets: studySet.flashcardSets,
    notes: studySet.notes,
    videoLectures: studySet.videoLectures
        .map(
          (v) => VideoLecture(
            id: v.id,
            title: v.title,
            driveFileId: v.driveFileId,
            shareableLink: v.shareableLink,
            duration: v.duration,
            uploadedAt: v.uploadedAt,
          ),
        )
        .toList(),
    isPublic: studySet.isPublic,
    rating: studySet.rating,
    ratingCount: studySet.ratingCount,
    enrolledCount: studySet.enrolledCount,
    estimatedHours: studySet.estimatedHours,
    createdAt: studySet.createdAt,
    updatedAt: studySet.updatedAt,
  );

  int get totalItems =>
      quizzes.length +
      flashcardSets.length +
      notes.length +
      videoLectures.length;
}

/// Service for Course Pack API operations
// TODO: Allow other users to claim, make a copy, and edit quizzes, flashcards, or course packs
class CoursePackService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Save Course Pack to MongoDB via Backend API (create new)
  static Future<String> saveCoursePack(CoursePack coursePack) async {
    try {
      AppLogger.debug('Creating course pack...');
      final jsonData = coursePack.toJson();

      final response = await http
          .post(
            Uri.parse('$baseUrl/course-pack'),
            headers: _headers,
            body: jsonEncode(jsonData),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.success('Course pack created: ${data['id']}');
        return data['id'];
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? 'Failed to create course pack');
      }
    } catch (e) {
      throw Exception('Failed to save course pack: $e');
    }
  }

  /// Update existing Course Pack in MongoDB via Backend API
  static Future<void> updateCoursePack(CoursePack coursePack) async {
    try {
      AppLogger.debug('Updating course pack: ${coursePack.id}');
      final jsonData = coursePack.toJson();

      final response = await http
          .put(
            Uri.parse('$baseUrl/course-pack/${coursePack.id}'),
            headers: _headers,
            body: jsonEncode(jsonData),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        AppLogger.success('Course pack updated: ${coursePack.id}');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? 'Failed to update course pack');
      }
    } catch (e) {
      throw Exception('Failed to update course pack: $e');
    }
  }

  /// Fetch public course packs for marketplace
  static Future<List<CoursePack>> fetchPublicCoursePacks({
    String? category,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var url = '$baseUrl/course-pack/public?limit=$limit&offset=$offset';
      if (category != null && category != 'All') {
        url += '&category=$category';
      }

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coursePacks = data['coursePacks'] ?? [];
        return coursePacks.map((cp) => CoursePack.fromJson(cp)).toList();
      } else {
        throw Exception('Failed to fetch public course packs');
      }
    } catch (e) {
      throw Exception('Failed to fetch public course packs: $e');
    }
  }

  /// Fetch featured course packs (highest rated)
  static Future<List<CoursePack>> fetchFeaturedCoursePacks({
    int limit = 5,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/course-pack/featured?limit=$limit'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coursePacks = data['coursePacks'] ?? [];
        return coursePacks.map((cp) => CoursePack.fromJson(cp)).toList();
      } else {
        throw Exception('Failed to fetch featured course packs');
      }
    } catch (e) {
      throw Exception('Failed to fetch featured course packs: $e');
    }
  }

  /// Fetch course pack by ID
  static Future<CoursePack> fetchCoursePackById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/course-pack/$id'), headers: _headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CoursePack.fromJson(data['coursePack']);
      } else {
        throw Exception('Course pack not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch course pack: $e');
    }
  }

  /// Fetch user's course packs
  static Future<List<CoursePack>> fetchUserCoursePacks(String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/course-pack/user/$userId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coursePacks = data['coursePacks'] ?? [];
        return coursePacks.map((cp) => CoursePack.fromJson(cp)).toList();
      } else {
        throw Exception('Failed to fetch user course packs');
      }
    } catch (e) {
      throw Exception('Failed to fetch user course packs: $e');
    }
  }

  /// Publish/unpublish course pack to marketplace
  static Future<void> publishCoursePack(
    String id, {
    bool isPublic = true,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/course-pack/$id/publish'),
            headers: _headers,
            body: jsonEncode({'isPublic': isPublic}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to publish course pack');
      }
    } catch (e) {
      throw Exception('Failed to publish course pack: $e');
    }
  }

  /// Enroll in a course pack
  static Future<void> enrollInCoursePack(String id, String userId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/course-pack/$id/enroll?user_id=$userId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to enroll');
      }
    } catch (e) {
      throw Exception('Failed to enroll: $e');
    }
  }

  /// Rate a course pack
  static Future<double> rateCoursePack(String id, double rating) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/course-pack/$id/rate?rating=$rating'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['newRating'] ?? rating).toDouble();
      } else {
        throw Exception('Failed to rate course pack');
      }
    } catch (e) {
      throw Exception('Failed to rate: $e');
    }
  }

  /// Add video lecture to course pack
  static Future<String> addVideoLecture(
    String coursePackId,
    VideoLecture video,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/course-pack/$coursePackId/video'),
            headers: _headers,
            body: jsonEncode(video.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['videoId'];
      } else {
        throw Exception('Failed to add video lecture');
      }
    } catch (e) {
      throw Exception('Failed to add video: $e');
    }
  }

  /// Remove video lecture from course pack
  static Future<void> removeVideoLecture(
    String coursePackId,
    String videoId,
  ) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/course-pack/$coursePackId/video/$videoId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to remove video lecture');
      }
    } catch (e) {
      throw Exception('Failed to remove video: $e');
    }
  }

  /// Delete course pack
  static Future<void> deleteCoursePack(String id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/course-pack/$id'), headers: _headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete course pack');
      }
    } catch (e) {
      throw Exception('Failed to delete course pack: $e');
    }
  }

  /// Claim/copy a public course pack to user's library
  static Future<String> claimCoursePack(String id, String userId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/course-pack/$id/claim'),
            headers: _headers,
            body: jsonEncode({'user_id': userId}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['course_pack_id'] ?? '';
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? 'Failed to claim course pack');
      }
    } catch (e) {
      throw Exception('Failed to claim course pack: $e');
    }
  }

  /// Check if user has already claimed a course pack
  static Future<bool> hasUserClaimedCourse(
    String coursePackId,
    String userId,
  ) async {
    try {
      AppLogger.debug(
        'Checking claimed status via API: coursePackId=$coursePackId, userId=$userId',
      );

      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/course-pack/user/$userId/claimed/$coursePackId',
            ),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      AppLogger.debug('Claimed check response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final claimed = data['claimed'] ?? false;
        AppLogger.debug('API returned claimed status: $claimed');
        return claimed;
      }

      AppLogger.warning(
        'API returned non-200 status: ${response.statusCode}, falling back to local check',
      );
      return false;
    } catch (e) {
      AppLogger.warning('API check failed: $e, falling back to local check');

      // If endpoint doesn't exist, check locally by fetching user's courses
      try {
        final userCourses = await fetchUserCoursePacks(userId);
        AppLogger.debug(
          'Fetched ${userCourses.length} user courses for local claimed check',
        );

        final hasClaimed = userCourses.any((course) {
          final matches = course.originalCoursePackId == coursePackId;
          if (matches) {
            AppLogger.debug(
              'Found claimed copy: ${course.id} (original: ${course.originalCoursePackId})',
            );
          }
          return matches;
        });

        AppLogger.debug('Local check result: hasClaimed=$hasClaimed');
        return hasClaimed;
      } catch (e2) {
        AppLogger.warning('Error in local claimed check: $e2');
        return false;
      }
    }
  }
}
