import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/note.dart';
import 'package:quiz_app/CreateSection/models/study_set.dart';
import 'package:quiz_app/CreateSection/screens/flashcard_play_screen_new.dart';
import 'package:quiz_app/CreateSection/screens/note_viewer_page.dart';
import 'package:quiz_app/CreateSection/screens/study_set_viewer.dart';
import 'package:quiz_app/CreateSection/services/flashcard_service.dart';
import 'package:quiz_app/CreateSection/services/note_service.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/CreateSection/services/study_set_service.dart';
import 'package:quiz_app/LibrarySection/PlaySection/screens/quiz_play_screen.dart';
import 'package:quiz_app/LibrarySection/models/library_item.dart';
import 'package:quiz_app/LibrarySection/screens/mode_selection_sheet.dart';
import 'package:quiz_app/LibrarySection/widgets/quiz_library_item.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';
import 'package:quiz_app/widgets/wait_screen.dart';

class ItemCard extends StatelessWidget {
  final LibraryItem item;
  final VoidCallback onDelete;

  const ItemCard({super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final Color softRed = AppColors.error.withValues(alpha: 0.1);

    // Check if this item was shared in a restrictive mode (only for quizzes)
    final isRestrictiveMode =
        item.isQuiz &&
        (item.sharedMode == 'self_paced' ||
            item.sharedMode == 'timed_individual');

    // Show full features if not in restrictive mode
    final showFullFeatures = !isRestrictiveMode;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(softRed),
          _buildCoverImage(),
          _buildTitle(),
          if (item.originalOwnerUsername != null &&
              item.originalOwnerUsername!.isNotEmpty)
            _buildAuthorInfo(),
          _buildDescription(),
          _buildActionButtons(context, showFullFeatures),
        ],
      ),
    );
  }

  void _handleItemTap(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (item.isNote) {
      _navigateToNote(context, user.uid);
    } else if (item.isFlashcard) {
      _navigateToFlashcard(context, user.uid);
    } else {
      _navigateToQuiz(context, user.uid);
    }
  }

  void _navigateToNote(BuildContext context, String userId) {
    Note? loadedNote;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => WaitScreen(
              loadingMessage: 'Loading note',
              onLoadComplete: () async {
                loadedNote = await NoteService.getNote(item.id, userId);
              },
              onNavigate: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => NoteViewerPage(
                          noteId: item.id,
                          userId: userId,
                          preloadedNote: loadedNote,
                        ),
                  ),
                );
              },
            ),
      ),
    );
  }

  void _navigateToFlashcard(BuildContext context, String userId) {
    dynamic loadedFlashcardSet;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => WaitScreen(
              loadingMessage: 'Loading flashcards',
              onLoadComplete: () async {
                loadedFlashcardSet = await FlashcardService.getFlashcardSet(
                  item.id,
                  userId,
                );
              },
              onNavigate: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => FlashcardPlayScreen(
                          flashcardSetId: item.id,
                          preloadedFlashcardSet: loadedFlashcardSet,
                        ),
                  ),
                );
              },
            ),
      ),
    );
  }

  void _navigateToQuiz(BuildContext context, String userId) {
    dynamic loadedQuestions;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => WaitScreen(
              loadingMessage: 'Loading quiz',
              onLoadComplete: () async {
                loadedQuestions = await QuizService.fetchQuestionsByQuizId(
                  item.id,
                  userId,
                );
              },
              onNavigate: () {
                Navigator.pushReplacement(
                  context,
                  customRoute(
                    QuizPlayScreen(
                      quizItem: QuizLibraryItem.fromJson(
                        item.toQuizLibraryItem(),
                      ),
                      preloadedQuestions: loadedQuestions,
                    ),
                    AnimationType.slideUp,
                  ),
                );
              },
            ),
      ),
    );
  }

  void _navigateToStudySet(BuildContext context) {
    StudySet? loadedStudySet;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => WaitScreen(
              loadingMessage: 'Loading study set',
              onLoadComplete: () async {
                loadedStudySet = await StudySetService.fetchStudySetById(
                  item.id,
                );
              },
              onNavigate: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => StudySetViewer(
                          studySetId: item.id,
                          preloadedStudySet: loadedStudySet,
                        ),
                  ),
                );
              },
            ),
      ),
    );
  }

  Widget _buildHeader(Color softRed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTypeLabel(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildItemCountTag(),
              _buildDateAndDeleteButton(softRed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            item.isQuiz
                ? AppColors.primary.withValues(alpha: 0.15)
                : item.isNote
                ? AppColors.warning.withValues(alpha: 0.15)
                : item.isStudySet
                ? AppColors.secondary.withValues(alpha: 0.15)
                : AppColors.accentBright.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        item.isQuiz
            ? 'QUIZ'
            : item.isNote
            ? 'NOTE'
            : item.isStudySet
            ? 'STUDY SET'
            : 'FLASHCARD SET',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color:
              item.isQuiz
                  ? AppColors.primary
                  : item.isNote
                  ? AppColors.warning
                  : item.isStudySet
                  ? AppColors.secondary
                  : AppColors.accentBright,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildItemCountTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            item.isQuiz
                ? Icons.quiz_outlined
                : item.isNote
                ? Icons.description_outlined
                : item.isStudySet
                ? Icons.collections_bookmark_outlined
                : Icons.style_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            item.isNote
                ? 'Note'
                : item.isStudySet
                ? '${item.itemCount} Items'
                : '${item.itemCount} ${item.isQuiz ? 'Questions' : 'Cards'}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndDeleteButton(Color softRed) {
    return Row(
      children: [
        Text(
          item.createdAt ?? 'Unknown',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onDelete,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: softRed,
              border: Border.all(color: Colors.transparent, width: 2),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverImage() {
    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child:
            item.coverImagePath != null
                ? Image.network(
                  item.coverImagePath!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => _buildDefaultIcon(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                )
                : _buildDefaultIcon(),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(
        item.title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildAuthorInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 16,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              item.originalOwnerUsername!,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Text(
        item.description,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool showFullFeatures) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child:
          item.isNote
              ? _buildNoteButton(context)
              : item.isStudySet
              ? _buildStudySetButton(context)
              : item.isFlashcard
              ? _buildFlashcardButton(context)
              : _buildQuizButtons(context, showFullFeatures),
    );
  }

  Widget _buildNoteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            _navigateToNote(context, user.uid);
          }
        },
        icon: const Icon(Icons.visibility, size: 20, color: AppColors.white),
        label: const Text(
          'View',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warning,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildStudySetButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToStudySet(context),
        icon: const Icon(Icons.visibility, size: 20, color: AppColors.white),
        label: const Text(
          'View',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFlashcardButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            _navigateToFlashcard(context, user.uid);
          }
        },
        icon: const Icon(Icons.play_arrow, size: 20, color: AppColors.white),
        label: const Text(
          'Play',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizButtons(BuildContext context, bool showFullFeatures) {
    if (showFullFeatures) {
      return Row(
        children: [
          Expanded(child: _buildShareButton(context)),
          const SizedBox(width: 12),
          Expanded(child: _buildPlayButton(context)),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: _buildPlayButton(context),
      );
    }
  }

  Widget _buildShareButton(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          final hostId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
          showModeSelection(
            context: context,
            quizId: item.id,
            quizTitle: item.title,
            hostId: hostId,
          );
        },
        icon: const Icon(Icons.share, size: 20, color: AppColors.white),
        label: const Text(
          'Share',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            _navigateToQuiz(context, user.uid);
          }
        },
        icon: const Icon(Icons.play_arrow, size: 20, color: AppColors.white),
        label: const Text(
          'Play',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          Icons.quiz_rounded,
          size: 64,
          color: AppColors.iconInactive,
        ),
      ),
    );
  }
}
