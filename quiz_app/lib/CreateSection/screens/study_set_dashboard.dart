import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quiz_app/CreateSection/models/flashcard_set.dart';
import 'package:quiz_app/CreateSection/models/note.dart';
import 'package:quiz_app/CreateSection/models/quiz.dart';
import 'package:quiz_app/CreateSection/screens/flashcard_details_page.dart';
import 'package:quiz_app/CreateSection/screens/note_details_page.dart';
import 'package:quiz_app/CreateSection/screens/quiz_details.dart';
import 'package:quiz_app/CreateSection/services/flashcard_service.dart';
import 'package:quiz_app/CreateSection/services/note_service.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/CreateSection/services/study_set_cache_manager.dart';
import 'package:quiz_app/CreateSection/services/study_set_service.dart';
import 'package:quiz_app/CreateSection/widgets/quiz_saved_dialog.dart';
import 'package:quiz_app/LibrarySection/screens/library_page.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/globals.dart';
import 'package:quiz_app/widgets/appbar/universal_appbar.dart';
import 'package:quiz_app/widgets/core/app_dialog.dart';

class StudySetDashboard extends StatefulWidget {
  final String studySetId;
  final String title;
  final String description;
  final String language;
  final String category;
  final String? coverImagePath;

  const StudySetDashboard({
    super.key,
    required this.studySetId,
    required this.title,
    required this.description,
    required this.language,
    required this.category,
    this.coverImagePath,
  });

  @override
  State<StudySetDashboard> createState() => _StudySetDashboardState();
}

class _StudySetDashboardState extends State<StudySetDashboard> {
  List<Quiz> quizzes = [];
  List<FlashcardSet> flashcardSets = [];
  List<Note> notes = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCachedItems();
  }

  void _loadCachedItems() {
    final cachedStudySet = StudySetCacheManager.instance.getCurrentStudySet();
    if (cachedStudySet != null) {
      setState(() {
        quizzes = cachedStudySet.quizzes;
        flashcardSets = cachedStudySet.flashcardSets;
        notes = cachedStudySet.notes;
      });
    }
  }

  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Add Item to Study Set',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),

                // Quiz Section
                _buildItemTypeHeader('Quiz'),
                const SizedBox(height: 12),
                _buildAddItemOption(
                  icon: Icons.add_circle_outline,
                  title: 'Create New Quiz',
                  description: 'Create multiple choice questions',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToQuizCreation();
                  },
                ),
                const SizedBox(height: 8),
                _buildAddItemOption(
                  icon: Icons.library_add_outlined,
                  title: 'Select Existing Quiz',
                  description: 'Choose from your saved quizzes',
                  onTap: () {
                    Navigator.pop(context);
                    _showSelectQuizDialog();
                  },
                ),
                const SizedBox(height: 24),

                // Flashcard Section
                _buildItemTypeHeader('Flashcard'),
                const SizedBox(height: 12),
                _buildAddItemOption(
                  icon: Icons.add_circle_outline,
                  title: 'Create New Flashcard Set',
                  description: 'Create flashcard sets for memorization',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToFlashcardCreation();
                  },
                ),
                const SizedBox(height: 8),
                _buildAddItemOption(
                  icon: Icons.library_add_outlined,
                  title: 'Select Existing Flashcard Set',
                  description: 'Choose from your saved flashcard sets',
                  onTap: () {
                    Navigator.pop(context);
                    _showSelectFlashcardDialog();
                  },
                ),
                const SizedBox(height: 24),

                // Note Section
                _buildItemTypeHeader('Note'),
                const SizedBox(height: 12),
                _buildAddItemOption(
                  icon: Icons.add_circle_outline,
                  title: 'Create New Note',
                  description: 'Write detailed notes and explanations',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToNoteCreation();
                  },
                ),
                const SizedBox(height: 8),
                _buildAddItemOption(
                  icon: Icons.library_add_outlined,
                  title: 'Select Existing Note',
                  description: 'Choose from your saved notes',
                  onTap: () {
                    Navigator.pop(context);
                    _showSelectNoteDialog();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemTypeHeader(String title) {
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAddItemOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToQuizCreation() {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return PageTransition(
                animation: animation,
                animationType: AnimationType.slideLeft,
                child: QuizDetails(
                  isStudySetMode: true,
                  onSaveForStudySet: (Quiz quiz) {
                    StudySetCacheManager.instance.addQuizToStudySet(quiz);
                    setState(() {
                      _loadCachedItems();
                    });
                  },
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        )
        .then((_) {
          // Reload items when returning to dashboard
          setState(() {
            _loadCachedItems();
          });
        });
  }

  void _navigateToFlashcardCreation() {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return PageTransition(
                animation: animation,
                animationType: AnimationType.slideLeft,
                child: FlashcardDetailsPage(
                  isStudySetMode: true,
                  onSaveForStudySet: (FlashcardSet flashcardSet) {
                    StudySetCacheManager.instance.addFlashcardSetToStudySet(
                      flashcardSet,
                    );
                    setState(() {
                      _loadCachedItems();
                    });
                  },
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        )
        .then((_) {
          // Reload items when returning to dashboard
          setState(() {
            _loadCachedItems();
          });
        });
  }

  void _navigateToNoteCreation() {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return PageTransition(
                animation: animation,
                animationType: AnimationType.slideLeft,
                child: NoteDetailsPage(
                  isStudySetMode: true,
                  onSaveForStudySet: (Note note) {
                    StudySetCacheManager.instance.addNoteToStudySet(note);
                    setState(() {
                      _loadCachedItems();
                    });
                  },
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        )
        .then((_) {
          // Reload items when returning to dashboard
          setState(() {
            _loadCachedItems();
          });
        });
  }

  // Methods to select existing items
  void _showSelectQuizDialog() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final quizzes = await QuizService.fetchQuizzesByCreator(userId);

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog

      if (quizzes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No quizzes found. Create one first!')),
        );
        return;
      }

      if (!mounted) return;

      AppDialog.show(
        context: context,
        title: 'Select Quiz',
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              // Handle both possible field names from API
              final questionCount =
                  quiz['questionCount'] ?? quiz['questions_count'] ?? 0;

              return ListTile(
                leading: const Icon(Icons.quiz_outlined),
                title: Text(quiz['title'] ?? 'Untitled'),
                subtitle: Text('$questionCount questions'),
                onTap: () {
                  // Convert the map to Quiz object and add to study set
                  final quizObj = Quiz(
                    id: quiz['id'] ?? quiz['_id'], // Important: include the ID
                    title: quiz['title'] ?? '',
                    description: quiz['description'] ?? '',
                    language: quiz['language'] ?? 'English',
                    category: quiz['category'] ?? 'Other',
                    creatorId: userId,
                    coverImagePath: quiz['coverImagePath'],
                    questions: [], // Questions will be loaded when needed
                  );
                  StudySetCacheManager.instance.addQuizToStudySet(quizObj);

                  Navigator.of(context).pop(); // Close dialog

                  if (mounted) {
                    setState(() {
                      _loadCachedItems();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quiz added to study set')),
                    );
                  }
                },
              );
            },
          ),
        ),
        secondaryActionText: 'Cancel',
        secondaryActionCallback: () => Navigator.of(context).pop(),
      );
    } catch (e) {
      if (!mounted) return;
      // Try to close loading dialog if it's still open
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {
        // Dialog already closed
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading quizzes: $e')));
    }
  }

  void _showSelectFlashcardDialog() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final flashcardSets = await FlashcardService.fetchFlashcardSetsByCreator(
        userId,
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog

      if (flashcardSets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No flashcard sets found. Create one first!'),
          ),
        );
        return;
      }

      if (!mounted) return;

      AppDialog.show(
        context: context,
        title: 'Select Flashcard Set',
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: flashcardSets.length,
            itemBuilder: (context, index) {
              final flashcardSet = flashcardSets[index];
              final cardCount =
                  flashcardSet['cardCount'] ?? flashcardSet['cards_count'] ?? 0;

              return ListTile(
                leading: const Icon(Icons.style_outlined),
                title: Text(flashcardSet['title'] ?? 'Untitled'),
                subtitle: Text('$cardCount cards'),
                onTap: () {
                  // Convert the map to FlashcardSet object and add to study set
                  final flashcardSetObj = FlashcardSet(
                    id: flashcardSet['id'] ?? flashcardSet['_id'],
                    title: flashcardSet['title'] ?? '',
                    description: flashcardSet['description'] ?? '',
                    category: flashcardSet['category'] ?? 'Other',
                    creatorId: userId,
                    coverImagePath: flashcardSet['coverImagePath'],
                    cards: [], // Cards will be loaded when needed
                  );
                  StudySetCacheManager.instance.addFlashcardSetToStudySet(
                    flashcardSetObj,
                  );

                  Navigator.of(context).pop(); // Close dialog

                  if (mounted) {
                    setState(() {
                      _loadCachedItems();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Flashcard set added to study set'),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        secondaryActionText: 'Cancel',
        secondaryActionCallback: () => Navigator.of(context).pop(),
      );
    } catch (e) {
      if (!mounted) return;
      // Try to close loading dialog if it's still open
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {
        // Dialog already closed
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading flashcard sets: $e')),
      );
    }
  }

  void _showSelectNoteDialog() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final notes = await NoteService.fetchNotesByCreator(userId);

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog

      if (notes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No notes found. Create one first!')),
        );
        return;
      }

      if (!mounted) return;

      AppDialog.show(
        context: context,
        title: 'Select Note',
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];

              return ListTile(
                leading: const Icon(Icons.note_outlined),
                title: Text(note['title'] ?? 'Untitled'),
                subtitle: Text(note['category'] ?? 'Uncategorized'),
                onTap: () {
                  // Convert the map to Note object and add to study set
                  final noteObj = Note(
                    id: note['id'] ?? note['_id'],
                    title: note['title'] ?? '',
                    description: note['description'] ?? '',
                    category: note['category'] ?? 'Other',
                    creatorId: userId,
                    content: note['content'] ?? '',
                    coverImagePath: note['coverImagePath'],
                  );
                  StudySetCacheManager.instance.addNoteToStudySet(noteObj);

                  Navigator.of(context).pop(); // Close dialog

                  if (mounted) {
                    setState(() {
                      _loadCachedItems();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note added to study set')),
                    );
                  }
                },
              );
            },
          ),
        ),
        secondaryActionText: 'Cancel',
        secondaryActionCallback: () => Navigator.of(context).pop(),
      );
    } catch (e) {
      if (!mounted) return;
      // Try to close loading dialog if it's still open
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {
        // Dialog already closed
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading notes: $e')));
    }
  }

  Future<void> _saveStudySet() async {
    if (_isSaving) return;

    final totalItems = quizzes.length + flashcardSets.length + notes.length;
    if (totalItems == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item to the study set'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final cachedStudySet = StudySetCacheManager.instance.getCurrentStudySet();
      if (cachedStudySet == null) {
        throw Exception('Study set not found in cache');
      }

      // Save to MongoDB via backend API
      await StudySetService.saveStudySet(cachedStudySet);
      StudySetCacheManager.instance.clearCache();

      if (!mounted) return;

      // Show success dialog and navigate to library
      await QuizSavedDialog.show(
        context,
        title: 'Success!',
        message: 'Your study set has been saved successfully.',
        onDismiss: () async {
          if (mounted) {
            // Pop back to dashboard
            Navigator.of(context).popUntil((route) => route.isFirst);

            // Switch to library tab (index 1) and trigger GET request
            bottomNavbarKey.currentState?.setIndex(1);

            // Trigger library reload to fetch the new study set
            LibraryPage.reloadItems();
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving study set: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UniversalAppBar(
        title: widget.title,
        showNotificationBell: false,
        actions: [
          if (quizzes.isNotEmpty ||
              flashcardSets.isNotEmpty ||
              notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: _isSaving ? null : _saveStudySet,
                icon: _isSaving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(Icons.save, color: AppColors.primary),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 120.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image (if available)
              if (widget.coverImagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(widget.coverImagePath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              if (widget.coverImagePath != null) const SizedBox(height: 20),

              // Modern Info Section (No Background Box)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModernInfoRow('Description', widget.description),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernInfoRow('Category', widget.category),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildModernInfoRow('Language', widget.language),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Add Button (No background box)
              Center(
                child: InkWell(
                  onTap: _showAddItemSheet,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: AppColors.primary, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Add Item',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Display Added Items or Empty State
              if (quizzes.isEmpty && flashcardSets.isEmpty && notes.isEmpty)
                // Empty State with Lottie Animation
                Center(
                  child: Column(
                    children: [
                      Lottie.asset(
                        'assets/animations/empty_box.json',
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 100,
                              color: AppColors.primaryLight,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No items in this study set',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap the + button to add items',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                // Display Added Items
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (quizzes.isNotEmpty) ...[
                      _buildSectionHeader('Quizzes', quizzes.length),
                      const SizedBox(height: 12),
                      ...quizzes.map((quiz) => _buildQuizCard(quiz)),
                      const SizedBox(height: 24),
                    ],
                    if (flashcardSets.isNotEmpty) ...[
                      _buildSectionHeader('Flashcards', flashcardSets.length),
                      const SizedBox(height: 12),
                      ...flashcardSets.map((set) => _buildFlashcardCard(set)),
                      const SizedBox(height: 24),
                    ],
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
      ),
    );
  }

  Widget _buildModernInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.2),
        ),
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
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            onPressed: () => _removeQuiz(quiz.id ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardCard(FlashcardSet set) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.2),
        ),
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
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            onPressed: () => _removeFlashcardSet(set.id ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.2),
        ),
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
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            onPressed: () => _removeNote(note.id ?? ''),
          ),
        ],
      ),
    );
  }

  void _removeQuiz(String quizId) {
    setState(() {
      quizzes.removeWhere((q) => q.id == quizId);
      StudySetCacheManager.instance.removeQuizFromStudySet(quizId);
    });
  }

  void _removeFlashcardSet(String setId) {
    setState(() {
      flashcardSets.removeWhere((s) => s.id == setId);
      StudySetCacheManager.instance.removeFlashcardSetFromStudySet(setId);
    });
  }

  void _removeNote(String noteId) {
    setState(() {
      notes.removeWhere((n) => n.id == noteId);
      StudySetCacheManager.instance.removeNoteFromStudySet(noteId);
    });
  }
}
