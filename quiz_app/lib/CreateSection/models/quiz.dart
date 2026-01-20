import 'package:quiz_app/CreateSection/models/question.dart';

class Quiz {
  String? id;
  String title;
  String description;
  String language;
  String category;
  String? coverImagePath;
  String creatorId;
  List<Question> questions;
  DateTime createdAt;

  Quiz({
    this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.category,
    this.coverImagePath,
    required this.creatorId,
    List<Question>? questions,
    DateTime? createdAt,
  }) : questions = questions ?? [],
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'language': language,
      'category': category,
      'coverImagePath': coverImagePath,
      'creatorId': creatorId,
      'questions': questions.map((q) => q.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      language: json['language'] ?? '',
      category: json['category'] ?? '',
      coverImagePath: json['coverImagePath'],
      creatorId: json['creatorId'] ?? json['creator_id'] ?? '',
      questions: (json['questions'] as List? ?? [])
          .map((q) => Question.fromJson(q))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  /// Creates a copy of this Quiz with the given fields replaced
  Quiz copyWith({
    String? id,
    String? title,
    String? description,
    String? language,
    String? category,
    String? coverImagePath,
    String? creatorId,
    List<Question>? questions,
    DateTime? createdAt,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      language: language ?? this.language,
      category: category ?? this.category,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      creatorId: creatorId ?? this.creatorId,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
