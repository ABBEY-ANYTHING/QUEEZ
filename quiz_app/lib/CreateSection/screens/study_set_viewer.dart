import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/flashcard_set.dart';
import 'package:quiz_app/CreateSection/models/note.dart';
import 'package:quiz_app/CreateSection/models/quiz.dart';
import 'package:quiz_app/CreateSection/models/study_set.dart';
import 'package:quiz_app/CreateSection/screens/flashcard_play_screen_new.dart';
import 'package:quiz_app/CreateSection/screens/note_viewer_page.dart';
import 'package:quiz_app/CreateSection/services/study_set_service.dart';
import 'package:quiz_app/LibrarySection/PlaySection/screens/quiz_play_screen.dart';
import 'package:quiz_app/LibrarySection/widgets/quiz_library_item.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:lottie/lottie.dart';

class StudySetViewer extends StatefulWidget {
  final String studySetId;
  final StudySet? preloadedStudySet;

  const StudySetViewer({
    super.key,
    required this.studySetId,
    this.preloadedStudySet,
  });

  @override
  State<StudySetViewer> createState() => _StudySetViewerState();
}

class _StudySetViewerState extends State<StudySetViewer> {
  StudySet? studySet;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStudySet();
  }

  Future<void> _loadStudySet() async {
    // Use preloaded data if available
    if (widget.preloadedStudySet != null) {
      setState(() {
        studySet = widget.preloadedStudySet;
        isLoading = false;
      });
      return;
    }

    // Otherwise fetch from backend
    try {
      debugPrint('Loading study set with ID: ${widget.studySetId}');

      final fetchedStudySet = await StudySetService.fetchStudySetById(
        widget.studySetId,
      );

      debugPrint('Fetched study set: ${fetchedStudySet?.name}');

      if (fetchedStudySet == null) {
        setState(() {
          errorMessage = 'Study set not found';
          isLoading = false;
        });
        return;
      }
      setState(() {
        studySet = fetchedStudySet;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading study set: $e');
      setState(() {
        errorMessage = 'Failed to load study set: $e';
        isLoading = false;
      });
    }
  }

  void _openQuiz(Quiz quiz) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Navigator.push(
      context,
      customRoute(
        QuizPlayScreen(
          quizItem: QuizLibraryItem(
            id: quiz.id ?? '',
            title: quiz.title,
            description: quiz.description,
            coverImagePath: quiz.coverImagePath,
            createdAt: quiz.createdAt.toIso8601String(),
            questionCount: quiz.questions.length,
            language: quiz.language,
            category: quiz.category,
          ),
          preloadedQuestions: quiz.questions,
        ),
        AnimationType.slideUp,
      ),
    );
  }

  void _openFlashcardSet(FlashcardSet set) {
    Navigator.push(
      context,
      customRoute(
        FlashcardPlayScreen(
          flashcardSetId: set.id ?? '',
          preloadedFlashcardSet: set,
        ),
        AnimationType.slideUp,
      ),
    );
  }

  void _openNote(Note note) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Navigator.push(
      context,
      customRoute(
        NoteViewerPage(
          noteId: note.id ?? '',
          userId: user.uid,
          preloadedNote: note,
        ),
        AnimationType.slideUp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final quizzes = studySet!.quizzes;
    final flashcardSets = studySet!.flashcardSets;
    final notes = studySet!.notes;
    final totalItems = quizzes.length + flashcardSets.length + notes.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          studySet!.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            if (studySet!.coverImagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child:
                    studySet!.coverImagePath!.startsWith('http')
                        ? Image.network(
                          studySet!.coverImagePath!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                        : Image.file(
                          File(studySet!.coverImagePath!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
              ),
            if (studySet!.coverImagePath != null) const SizedBox(height: 20),

            // Info Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernInfoRow('Description', studySet!.description),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildModernInfoRow(
                        'Category',
                        studySet!.category,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildModernInfoRow(
                        'Language',
                        studySet!.language,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Items Section
            if (totalItems == 0)
              Center(
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/animations/empty_box.json',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.inventory_2_outlined,
                          size: 100,
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This study set is empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Study Items',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quizzes
                  if (quizzes.isNotEmpty) ...[
                    _buildSectionHeader('Quizzes', quizzes.length),
                    const SizedBox(height: 12),
                    ...quizzes.map((quiz) => _buildQuizCard(quiz)),
                    const SizedBox(height: 24),
                  ],

                  // Flashcard Sets
                  if (flashcardSets.isNotEmpty) ...[
                    _buildSectionHeader('Flashcard Sets', flashcardSets.length),
                    const SizedBox(height: 12),
                    ...flashcardSets.map((set) => _buildFlashcardCard(set)),
                    const SizedBox(height: 24),
                  ],

                  // Notes
                  if (notes.isNotEmpty) ...[
                    _buildSectionHeader('Notes', notes.length),
                    const SizedBox(height: 12),
                    ...notes.map((note) => _buildNoteCard(note)),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _openQuiz(quiz),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.quiz, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${quiz.questions.length} questions',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.play_arrow, color: AppColors.primary, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlashcardCard(FlashcardSet set) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _openFlashcardSet(set),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.style, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        set.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${set.cards.length} cards',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.play_arrow, color: AppColors.primary, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _openNote(note),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.note, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        note.category,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.visibility, color: AppColors.primary, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
