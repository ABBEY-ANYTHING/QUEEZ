import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api_config.dart';
import '../models/flashcard_set.dart';

class FlashcardService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<String> createFlashcardSet({
    required String title,
    required String description,
    required String category,
    required String creatorId,
    required List<Map<String, String>> cards,
    String? coverImagePath,
  }) async {
    try {
      final flashcardSet = FlashcardSet(
        title: title,
        description: description,
        category: category,
        creatorId: creatorId,
        coverImagePath: coverImagePath,
        cards: cards
            .map(
              (card) => Flashcard(front: card['front']!, back: card['back']!),
            )
            .toList(),
      );

      final response = await http
          .post(
            Uri.parse('$baseUrl/flashcards'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(flashcardSet.toJson()),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['detail'] ?? 'Failed to create flashcard set',
        );
      }
    } catch (e) {
      throw Exception('Error creating flashcard set: $e');
    }
  }

  static Future<FlashcardSet> getFlashcardSet(
    String setId,
    String userId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/flashcards/$setId?user_id=$userId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FlashcardSet.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to fetch flashcard set');
      }
    } catch (e) {
      throw Exception('Error fetching flashcard set: $e');
    }
  }

  static Future<void> deleteFlashcardSet(String setId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/flashcards/$setId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['detail'] ?? 'Failed to delete flashcard set',
        );
      }
    } catch (e) {
      throw Exception('Error deleting flashcard set: $e');
    }
  }

  static Future<void> addToLibrary(String setId, String userId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/flashcards/add-to-library'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'flashcard_set_id': setId, 'user_id': userId}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['detail'] ?? 'Failed to add flashcard set to library',
        );
      }
    } catch (e) {
      throw Exception('Error adding flashcard set to library: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchFlashcardSetsByCreator(
    String creatorId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/flashcards/creator/$creatorId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('Failed to fetch flashcard sets');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['detail'] ?? 'Failed to fetch flashcard sets',
        );
      }
    } catch (e) {
      throw Exception('Error fetching flashcard sets: $e');
    }
  }
}
