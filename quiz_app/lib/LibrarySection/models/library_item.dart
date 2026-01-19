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
    // Infer type or handle loose typing
    String type = json['type'] ?? '';
    // If type is missing, try to infer from content
    if (type.isEmpty) {
      if (json.containsKey('quizzes') || 
          json.containsKey('flashcardSets') || 
          json.containsKey('notes')) {
        type = 'course_pack';
      } else if (json.containsKey('questions') || json.containsKey('questionCount')) {
        type = 'quiz';
      } else if (json.containsKey('cards') || json.containsKey('cardCount')) {
        type = 'flashcard';
      }
    }

    // Handle title mapping (course packs use 'name')
    final title = json['title'] ?? json['name'] ?? 'Untitled';

    return LibraryItem(
      id: json['id'] ?? json['_id'] ?? '',
      type: type,
      title: title,
      description: json['description'] ?? '',
      coverImagePath: json['coverImagePath'],
      createdAt: json['createdAt'],
      itemCount: json['itemCount'] ?? json['qsCount'] ?? 0, // Fallbacks for counts
      category: json['category'] ?? '',
      language: json['language'] ?? '',
      originalOwner: json['originalOwner'] ?? json['ownerId'],
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
  bool get isStudySet => type == 'study_set' || type == 'course_pack';
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
