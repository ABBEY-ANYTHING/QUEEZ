import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api_config.dart';
import '../models/note.dart';

class NoteService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<String> createNote({
    required String title,
    required String description,
    required String category,
    required String creatorId,
    required String content,
    String? coverImagePath,
  }) async {
    try {
      final note = Note(
        title: title,
        description: description,
        category: category,
        creatorId: creatorId,
        content: content,
        coverImagePath: coverImagePath,
      );

      final response = await http
          .post(
            Uri.parse('$baseUrl/notes'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(note.toJson()),
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
        throw Exception(errorData['detail'] ?? 'Failed to create note');
      }
    } catch (e) {
      throw Exception('Error creating note: $e');
    }
  }

  static Future<Note> getNote(String noteId, String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/notes/$noteId?user_id=$userId'),
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
        return Note.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to fetch note');
      }
    } catch (e) {
      throw Exception('Error fetching note: $e');
    }
  }

  static Future<List<NoteLibraryItem>> getUserNotes(String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/notes/library?user_id=$userId'),
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
        final List<dynamic> notesData = data['data'];
        return notesData.map((note) => NoteLibraryItem.fromJson(note)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to fetch notes');
      }
    } catch (e) {
      throw Exception('Error fetching notes: $e');
    }
  }

  static Future<void> updateNote({
    required String noteId,
    required String title,
    required String description,
    required String category,
    required String creatorId,
    required String content,
    String? coverImagePath,
  }) async {
    try {
      final note = Note(
        id: noteId,
        title: title,
        description: description,
        category: category,
        creatorId: creatorId,
        content: content,
        coverImagePath: coverImagePath,
      );

      final response = await http
          .put(
            Uri.parse('$baseUrl/notes/$noteId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(note.toJson()),
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
        throw Exception(errorData['detail'] ?? 'Failed to update note');
      }
    } catch (e) {
      throw Exception('Error updating note: $e');
    }
  }

  static Future<void> deleteNote(String noteId, String userId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/notes/$noteId?user_id=$userId'),
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
        throw Exception(errorData['detail'] ?? 'Failed to delete note');
      }
    } catch (e) {
      throw Exception('Error deleting note: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchNotesByCreator(
    String creatorId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/notes/creator/$creatorId'),
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
          throw Exception('Failed to fetch notes');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to fetch notes');
      }
    } catch (e) {
      throw Exception('Error fetching notes: $e');
    }
  }
}
