import 'package:quiz_app/CreateSection/models/flashcard_set.dart';
import 'package:quiz_app/CreateSection/models/note.dart';
import 'package:quiz_app/CreateSection/models/quiz.dart';
import 'package:quiz_app/CreateSection/models/study_set.dart';
import 'package:quiz_app/CreateSection/models/video_lecture.dart';

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
      videoLectures: [],
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

  /// Add video lecture to study set
  void addVideoLectureToStudySet(VideoLecture videoLecture) {
    if (_currentStudySet != null) {
      final updatedVideoLectures = List<VideoLecture>.from(
        _currentStudySet!.videoLectures,
      )..add(videoLecture);
      _currentStudySet = _currentStudySet!.copyWith(
        videoLectures: updatedVideoLectures,
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

  /// Remove video lecture from study set
  void removeVideoLectureFromStudySet(String videoId) {
    if (_currentStudySet != null) {
      final updatedVideoLectures = _currentStudySet!.videoLectures
          .where((v) => v.id != videoId && v.driveFileId != videoId)
          .toList();
      _currentStudySet = _currentStudySet!.copyWith(
        videoLectures: updatedVideoLectures,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Get video lectures
  List<VideoLecture> getVideoLectures() {
    return _currentStudySet?.videoLectures ?? [];
  }

  /// Set complete study set (for AI-generated content)
  void setStudySet(StudySet studySet) {
    _currentStudySet = studySet;
  }

  /// Set study set from CoursePack (for editing existing course packs)
  void setStudySetFromCoursePack(dynamic coursePack) {
    // Import from course_pack_service.dart CoursePack model
    _currentStudySet = StudySet(
      id: coursePack.id,
      name: coursePack.name,
      description: coursePack.description,
      category: coursePack.category,
      language: coursePack.language,
      coverImagePath: coursePack.coverImagePath,
      ownerId: coursePack.ownerId,
      quizzes: List<Quiz>.from(coursePack.quizzes),
      flashcardSets: List<FlashcardSet>.from(coursePack.flashcardSets),
      notes: List<Note>.from(coursePack.notes),
      videoLectures: List<VideoLecture>.from(coursePack.videoLectures),
      createdAt: coursePack.createdAt,
      updatedAt: coursePack.updatedAt,
    );
  }

  /// Clear cache
  void clearCache() {
    _currentStudySet = null;
  }

  /// Check if cache has data
  bool hasData() => _currentStudySet != null;
}
