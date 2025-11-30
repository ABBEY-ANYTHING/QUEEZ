import 'package:quiz_app/CreateSection/models/quiz.dart';
import 'package:quiz_app/CreateSection/models/flashcard_set.dart';
import 'package:quiz_app/CreateSection/models/note.dart';

class StudySet {
  final String id;
  final String name;
  final String description;
  final String category;
  final String language;
  final String? coverImagePath;
  final String ownerId;
  final List<Quiz> quizzes;
  final List<FlashcardSet> flashcardSets;
  final List<Note> notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudySet({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.language,
    this.coverImagePath,
    required this.ownerId,
    required this.quizzes,
    required this.flashcardSets,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StudySet.fromJson(Map<String, dynamic> json) {
    return StudySet(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      language: json['language'] ?? '',
      coverImagePath: json['coverImagePath'],
      ownerId: json['ownerId'] ?? json['owner_id'] ?? json['creatorId'] ?? '',
      quizzes: (json['quizzes'] as List? ?? [])
          .map((q) => Quiz.fromJson(q))
          .toList(),
      flashcardSets: (json['flashcardSets'] as List? ?? [])
          .map((f) => FlashcardSet.fromJson(f))
          .toList(),
      notes: (json['notes'] as List? ?? [])
          .map((n) => Note.fromJson(n))
          .toList(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is DateTime) return dateValue;

    // Try parsing ISO format first
    try {
      return DateTime.parse(dateValue);
    } catch (e) {
      // If it's a month/year format like "November, 2025", just return current time
      return DateTime.now();
    }
  }

  StudySet copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? language,
    String? coverImagePath,
    String? ownerId,
    List<Quiz>? quizzes,
    List<FlashcardSet>? flashcardSets,
    List<Note>? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudySet(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      language: language ?? this.language,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      ownerId: ownerId ?? this.ownerId,
      quizzes: quizzes ?? this.quizzes,
      flashcardSets: flashcardSets ?? this.flashcardSets,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get totalItems => quizzes.length + flashcardSets.length + notes.length;
}
