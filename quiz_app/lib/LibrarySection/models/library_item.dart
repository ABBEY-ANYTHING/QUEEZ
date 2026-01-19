class LibraryItem {
  final String id;
  final String type; // "quiz" or "flashcard"
  final String title;
  final String description;
  final String? coverImagePath;
  final String? createdAt;
  final int itemCount; // questionCount for quizzes, cardCount for flashcards
  final String category;
  final String language; // Only for quizzes
  final String? originalOwner;
  final String? originalOwnerUsername;
  final String? sharedMode; // Only for quizzes
  final bool isFavorite; // Whether this item is favorited by the current user

  LibraryItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.coverImagePath,
    this.createdAt,
    required this.itemCount,
    required this.category,
    this.language = '',
    this.originalOwner,
    this.originalOwnerUsername,
    this.sharedMode,
    this.isFavorite = false,
  });

  factory LibraryItem.fromJson(Map<String, dynamic> json) {
    return LibraryItem(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      description: json['description'] ?? '',
      coverImagePath: json['coverImagePath'],
      createdAt: json['createdAt'],
      itemCount: json['itemCount'] ?? 0,
      category: json['category'] ?? '',
      language: json['language'] ?? '',
      originalOwner: json['originalOwner'],
      originalOwnerUsername: json['originalOwnerUsername'],
      sharedMode: json['sharedMode'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  bool get isQuiz => type == 'quiz';
  bool get isFlashcard => type == 'flashcard';
  bool get isNote => type == 'note';
  bool get isStudySet => type == 'study_set';
  bool get isCoursePack => type == 'course_pack';

  // Convert to QuizLibraryItem (for quizzes only)
  dynamic toQuizLibraryItem() {
    // Import QuizLibraryItem at the call site
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverImagePath': coverImagePath,
      'createdAt': createdAt,
      'questionCount': itemCount,
      'language': language,
      'category': category,
      'originalOwner': originalOwner,
      'originalOwnerUsername': originalOwnerUsername,
      'sharedMode': sharedMode,
    };
  }

  // Create a copy with updated fields
  LibraryItem copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    String? coverImagePath,
    String? createdAt,
    int? itemCount,
    String? category,
    String? language,
    String? originalOwner,
    String? originalOwnerUsername,
    String? sharedMode,
    bool? isFavorite,
  }) {
    return LibraryItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      createdAt: createdAt ?? this.createdAt,
      itemCount: itemCount ?? this.itemCount,
      category: category ?? this.category,
      language: language ?? this.language,
      originalOwner: originalOwner ?? this.originalOwner,
      originalOwnerUsername:
          originalOwnerUsername ?? this.originalOwnerUsername,
      sharedMode: sharedMode ?? this.sharedMode,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
