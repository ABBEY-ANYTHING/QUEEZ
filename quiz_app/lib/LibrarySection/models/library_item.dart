class LibraryItem {
  final String id;
  final String
  type; // "quiz", "flashcard", "note", "study_set", or "course_pack"
  final String title;
  final String description;
  final String? coverImagePath;
  final String? createdAt;
  final int itemCount; // questionCount for quizzes, cardCount for flashcards
  final String category;
  final String language; // Only for quizzes and course_packs
  final String? originalOwner;
  final String? originalOwnerUsername;
  final String? sharedMode; // Only for quizzes
  // Course pack specific fields
  final bool isPublic;
  final double rating;
  final int enrolledCount;
  final double estimatedHours;
  final int videoCount;

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
    this.isPublic = false,
    this.rating = 0.0,
    this.enrolledCount = 0,
    this.estimatedHours = 0.0,
    this.videoCount = 0,
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
      isPublic: json['isPublic'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      enrolledCount: json['enrolledCount'] ?? 0,
      estimatedHours: (json['estimatedHours'] ?? 0).toDouble(),
      videoCount: json['videoCount'] ?? 0,
    );
  }

  bool get isQuiz => type == 'quiz';
  bool get isFlashcard => type == 'flashcard';
  bool get isNote => type == 'note';
  bool get isStudySet =>
      type == 'course_pack'; // Alias for backward compatibility
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
}
