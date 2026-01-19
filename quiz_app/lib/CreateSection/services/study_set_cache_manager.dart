import 'package:quiz_app/CreateSection/models/study_set.dart';
import 'package:quiz_app/CreateSection/models/quiz.dart';
import 'package:quiz_app/CreateSection/models/flashcard_set.dart';
import 'package:quiz_app/CreateSection/models/note.dart';

class StudySetCacheManager {
  static final StudySetCacheManager instance = StudySetCacheManager._internal();
  StudySetCacheManager._internal();

  StudySet? _currentStudySet;

  /// Initialize new study set
  void initializeStudySet({
    required String id,
    required String name,
    required String description,
    required String category,
    required String language,
    required String ownerId,
    String? coverImagePath,
  }) {
    _currentStudySet = StudySet(
      id: id,
      name: name,
      description: description,
      category: category,
      language: language,
      coverImagePath: coverImagePath,
      ownerId: ownerId,
      quizzes: [],
      flashcardSets: [],
      notes: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Get current study set
  StudySet? getCurrentStudySet() => _currentStudySet;

  /// Add quiz to study set
  void addQuizToStudySet(Quiz quiz) {
    if (_currentStudySet != null) {
      final updatedQuizzes = List<Quiz>.from(_currentStudySet!.quizzes)
        ..add(quiz);
      _currentStudySet = _currentStudySet!.copyWith(
        quizzes: updatedQuizzes,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Add flashcard set to study set
  void addFlashcardSetToStudySet(FlashcardSet flashcardSet) {
    if (_currentStudySet != null) {
      final updatedFlashcardSets = List<FlashcardSet>.from(
        _currentStudySet!.flashcardSets,
      )..add(flashcardSet);
      _currentStudySet = _currentStudySet!.copyWith(
        flashcardSets: updatedFlashcardSets,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Add note to study set
  void addNoteToStudySet(Note note) {
    if (_currentStudySet != null) {
      final updatedNotes = List<Note>.from(_currentStudySet!.notes)..add(note);
      _currentStudySet = _currentStudySet!.copyWith(
        notes: updatedNotes,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Remove quiz from study set
  void removeQuizFromStudySet(String quizId) {
    if (_currentStudySet != null) {
      final updatedQuizzes = _currentStudySet!.quizzes
          .where((q) => q.id != quizId)
          .toList();
      _currentStudySet = _currentStudySet!.copyWith(
        quizzes: updatedQuizzes,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Remove flashcard set from study set
  void removeFlashcardSetFromStudySet(String flashcardSetId) {
    if (_currentStudySet != null) {
      final updatedFlashcardSets = _currentStudySet!.flashcardSets
          .where((f) => f.id != flashcardSetId)
          .toList();
      _currentStudySet = _currentStudySet!.copyWith(
        flashcardSets: updatedFlashcardSets,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Remove note from study set
  void removeNoteFromStudySet(String noteId) {
    if (_currentStudySet != null) {
      final updatedNotes = _currentStudySet!.notes
          .where((n) => n.id != noteId)
          .toList();
      _currentStudySet = _currentStudySet!.copyWith(
        notes: updatedNotes,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Set complete study set (for AI-generated content)
  void setStudySet(StudySet studySet) {
    _currentStudySet = studySet;
  }

  /// Clear cache
  void clearCache() {
    _currentStudySet = null;
  }

  /// Check if cache has data
  bool hasData() => _currentStudySet != null;
}
