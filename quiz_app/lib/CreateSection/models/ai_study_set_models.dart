class UploadedFile {
  final String fileName;
  final String fileUri;
  final int fileSize;
  final String mimeType;

  UploadedFile({
    required this.fileName,
    required this.fileUri,
    required this.fileSize,
    required this.mimeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileUri': fileUri,
      'fileSize': fileSize,
      'mimeType': mimeType,
    };
  }
}

class StudySetConfig {
  String name;
  String description;
  String category;
  String language;
  String? coverImagePath;

  StudySetConfig({
    this.name = '',
    this.description = '',
    this.category = '',
    this.language = '',
    this.coverImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'language': language,
      'coverImagePath': coverImagePath,
    };
  }
}

class GenerationSettings {
  int quizCount;
  int flashcardSetCount;
  int noteCount;
  String difficulty;
  int questionsPerQuiz;
  int cardsPerSet;

  GenerationSettings({
    this.quizCount = 2,
    this.flashcardSetCount = 2,
    this.noteCount = 1,
    this.difficulty = 'Mixed',
    this.questionsPerQuiz = 10,
    this.cardsPerSet = 20,
  });

  Map<String, dynamic> toJson() {
    return {
      'quizCount': quizCount,
      'flashcardSetCount': flashcardSetCount,
      'noteCount': noteCount,
      'difficulty': difficulty,
      'questionsPerQuiz': questionsPerQuiz,
      'cardsPerSet': cardsPerSet,
    };
  }
}
