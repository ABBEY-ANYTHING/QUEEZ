import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/CreateSection/models/flashcard_set.dart';
import 'package:quiz_app/CreateSection/models/note.dart';
import 'package:quiz_app/CreateSection/screens/flashcard_edit_page.dart';
import 'package:quiz_app/CreateSection/screens/flashcard_play_screen_new.dart';
import 'package:quiz_app/CreateSection/screens/note_edit_page.dart';
import 'package:quiz_app/CreateSection/screens/note_viewer_page.dart';
import 'package:quiz_app/CreateSection/screens/quiz_details.dart';
import 'package:quiz_app/CreateSection/screens/study_set_dashboard.dart';
import 'package:quiz_app/CreateSection/screens/study_set_viewer.dart';
import 'package:quiz_app/CreateSection/services/course_pack_service.dart';
import 'package:quiz_app/CreateSection/services/flashcard_service.dart';
import 'package:quiz_app/CreateSection/services/note_service.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/CreateSection/services/study_set_cache_manager.dart';
import 'package:quiz_app/LibrarySection/PlaySection/screens/quiz_play_screen.dart';
import 'package:quiz_app/LibrarySection/models/library_item.dart';
import 'package:quiz_app/LibrarySection/screens/mode_selection_sheet.dart';
import 'package:quiz_app/LibrarySection/widgets/item_card_actions.dart';
import 'package:quiz_app/LibrarySection/widgets/item_card_clippers.dart';
import 'package:quiz_app/LibrarySection/widgets/item_card_components.dart';
import 'package:quiz_app/LibrarySection/widgets/item_card_dialogs.dart';
import 'package:quiz_app/LibrarySection/widgets/item_card_helpers.dart';
import 'package:quiz_app/LibrarySection/widgets/item_card_options_menu.dart';
import 'package:quiz_app/LibrarySection/widgets/quiz_library_item.dart';
import 'package:quiz_app/providers/library_provider.dart';
import 'package:quiz_app/services/favorites_service.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/constants.dart';
import 'package:quiz_app/utils/exceptions.dart';
import 'package:quiz_app/widgets/wait_screen.dart';

/// Library item card widget displaying quiz, flashcard, note, or study set
class ItemCard extends ConsumerStatefulWidget {
  final LibraryItem item;
  final VoidCallback onDelete;
  final VoidCallback? onFavoriteChanged;
  final bool isHighlighted;

  const ItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    this.onFavoriteChanged,
    this.isHighlighted = false,
  });

  @override
  ConsumerState<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends ConsumerState<ItemCard>
    with TickerProviderStateMixin {
  bool _showOptions = false;
  bool _isDeleting = false;
  late bool _isFavorite;
  final FavoritesService _favoritesService = FavoritesService();

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _highlightController;
  late Animation<double> _highlightAnimation;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.item.isFavorite;
    _initAnimations();
    if (widget.isHighlighted) {
      _startHighlightAnimation();
    }
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _highlightController = AnimationController(
      duration: AppDurations.highlightPulse,
      vsync: this,
    );
    _highlightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeInOut),
    );
  }

  void _startHighlightAnimation() {
    _highlightController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _highlightController.stop();
        _highlightController.animateTo(0);
      }
    });
  }

  @override
  void didUpdateWidget(ItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _startHighlightAnimation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _highlightController.dispose();
    super.dispose();
  }

  void _toggleOptions() {
    setState(() {
      _showOptions = !_showOptions;
      if (_showOptions) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _hideOptions() {
    if (_showOptions) {
      setState(() {
        _showOptions = false;
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ItemCardColors.getBackgroundColor(widget.item);
    final accentColor = ItemCardColors.getAccentColor(widget.item);
    final textColor = ItemCardColors.getTextColor(widget.item);

    return AnimatedBuilder(
      animation: _highlightAnimation,
      builder: (context, child) {
        final highlightValue = _highlightAnimation.value;
        return TapRegion(
          onTapOutside: (_) => _hideOptions(),
          child: GestureDetector(
            onTap: () {
              if (_showOptions) {
                _hideOptions();
              } else {
                _handleTap(context);
              }
            },
            child: Stack(
              children: [
                _buildMainCard(
                  backgroundColor,
                  accentColor,
                  textColor,
                  highlightValue,
                ),
                _buildHighlightGlow(highlightValue),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainCard(
    Color backgroundColor,
    Color accentColor,
    Color textColor,
    double highlightValue,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: widget.isHighlighted && highlightValue > 0
            ? Border.all(
                color: AppColors.primary.withValues(
                  alpha: highlightValue * 0.8,
                ),
                width: 3,
              )
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative accent shape
          Positioned(
            top: 0,
            right: 0,
            child: ClipPath(
              clipper: AccentShapeClipper(),
              child: Container(
                width: 150,
                height: 120,
                color: accentColor.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Main content
          Row(
            children: [
              ItemCardThumbnail(item: widget.item),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 18, 50, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ItemTypeBadgeRow(item: widget.item),
                      const SizedBox(height: 12),
                      _buildTitle(textColor),
                      if (widget.item.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDescription(textColor),
                      ],
                      const SizedBox(height: 14),
                      ItemStatsRow(item: widget.item),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Action buttons
          Positioned(
            top: 14,
            right: 14,
            child: ItemCardActionButtons(
              isFavorite: _isFavorite,
              onFavoriteTap: _toggleFavorite,
              onShareTap: () => _handleShare(context),
              onMoreTap: _toggleOptions,
              accentColor: accentColor,
              textColor: textColor,
            ),
          ),
          // Options menu
          if (_showOptions)
            Positioned(
              top: 52,
              right: 12,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return ItemCardOptionsMenu(
                    scaleAnimation: _scaleAnimation,
                    fadeAnimation: _fadeAnimation,
                    onEdit: () {
                      _hideOptions();
                      _handleEdit();
                    },
                    onDelete: () {
                      _hideOptions();
                      _showDeleteConfirmationDialog();
                    },
                    showMarketplaceOption: false,
                  );
                },
              ),
            ),
          // Delete loading overlay
          if (_isDeleting) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildTitle(Color textColor) {
    return Text(
      widget.item.title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription(Color textColor) {
    return Text(
      widget.item.description,
      style: TextStyle(
        fontSize: 13,
        color: textColor.withValues(alpha: 0.7),
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: AppOpacity.overlay),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            strokeWidth: AppSizes.progressIndicatorStroke,
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightGlow(double highlightValue) {
    if (!widget.isHighlighted || highlightValue <= 0) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: highlightValue * 0.4,
                ),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    final newFavoriteStatus = !_isFavorite;
    setState(() => _isFavorite = newFavoriteStatus);

    ref
        .read(quizLibraryProvider.notifier)
        .toggleFavoriteLocally(widget.item.id, newFavoriteStatus);

    try {
      if (newFavoriteStatus) {
        await _favoritesService.addToFavorites(
          widget.item.id,
          widget.item.type,
        );
      } else {
        await _favoritesService.removeFromFavorites(
          widget.item.id,
          widget.item.type,
        );
      }
      AppLogger.success(
        'Favorite persisted: ${widget.item.id} -> $newFavoriteStatus',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error persisting favorite',
        exception: e,
        stackTrace: stackTrace,
      );
      setState(() => _isFavorite = !newFavoriteStatus);
      ref
          .read(quizLibraryProvider.notifier)
          .toggleFavoriteLocally(widget.item.id, !newFavoriteStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleShare(BuildContext context) {
    final hostId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

    if (widget.item.isQuiz) {
      showModeSelection(
        context: context,
        itemId: widget.item.id,
        itemTitle: widget.item.title,
        hostId: hostId,
        isCoursePack: false,
      );
    } else if (widget.item.isStudySet) {
      showModeSelection(
        context: context,
        itemId: widget.item.id,
        itemTitle: widget.item.title,
        hostId: hostId,
        isCoursePack: true,
        isCurrentlyPublic: widget.item.isPublic,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Share ${ItemTypeHelper.getLabel(widget.item)} coming soon!',
          ),
          backgroundColor: ItemCardColors.getAccentColor(widget.item),
          duration: AppDurations.snackBar,
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      _showErrorSnackBar('You must be logged in to delete items');
      return;
    }

    // Ownership checks
    if (!_canDeleteItem(userId)) return;

    final deletionMessage = _getDeleteMessage();

    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      message: deletionMessage,
    );

    if (confirmed == true) {
      await _performDelete();
    }
  }

  bool _canDeleteItem(String userId) {
    // Original course pack check
    if (widget.item.isCoursePack && !widget.item.isClaimed) {
      if (widget.item.ownerId != userId) {
        _showErrorSnackBar('You can only delete your own course packs');
        AppLogger.warning(
          'User $userId attempted to delete course pack ${widget.item.id} owned by ${widget.item.ownerId}',
        );
        return false;
      }
    }

    // General ownership check
    if (widget.item.ownerId != null && widget.item.ownerId != userId) {
      _showErrorSnackBar('You can only delete items you own');
      AppLogger.warning(
        'User $userId attempted to delete ${widget.item.type} ${widget.item.id} owned by ${widget.item.ownerId}',
      );
      return false;
    }

    return true;
  }

  String _getDeleteMessage() {
    if (widget.item.isCoursePack && widget.item.isClaimed) {
      final authorName = widget.item.originalOwnerUsername ?? 'the author';
      return 'Are you sure you want to delete your copy of "${widget.item.title}"?\n\n'
          '📌 The original course pack by $authorName will remain available.\n\n'
          'This action cannot be undone.';
    }
    return 'Are you sure you want to delete "${widget.item.title}"?\n\nThis action cannot be undone.';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: AppDurations.snackBarLong,
      ),
    );
  }

  Future<void> _performDelete() async {
    setState(() => _isDeleting = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw const AuthenticationException('User not logged in');
      }

      // Security checks
      if (widget.item.ownerId != null && widget.item.ownerId != userId) {
        throw const PermissionException(
          'You do not have permission to delete this item',
        );
      }

      if (widget.item.isCoursePack &&
          !widget.item.isClaimed &&
          widget.item.ownerId != userId) {
        throw const PermissionException(
          'You cannot delete course packs you do not own',
        );
      }

      AppLogger.info(
        'Deleting ${widget.item.type}: ${widget.item.id} (owned by: ${widget.item.ownerId}, isClaimed: ${widget.item.isClaimed})',
      );

      await _deleteByType(userId);

      if (!mounted) return;
      setState(() => _isDeleting = false);

      _showSuccessSnackBar(
        '${ItemTypeHelper.getLabel(widget.item)} deleted successfully',
      );

      ref.invalidate(quizLibraryProvider);
      widget.onDelete();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete ${widget.item.type}',
        exception: e,
        stackTrace: stackTrace,
      );

      if (!mounted) return;
      setState(() => _isDeleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
          duration: AppDurations.snackBarLong,
        ),
      );
    }
  }

  Future<void> _deleteByType(String userId) async {
    if (widget.item.isQuiz) {
      await QuizService.deleteQuiz(widget.item.id);
      AppLogger.success('Quiz deleted successfully (ID: ${widget.item.id})');
    } else if (widget.item.isFlashcard) {
      await FlashcardService.deleteFlashcardSet(widget.item.id);
      AppLogger.success(
        'Flashcard set deleted successfully (ID: ${widget.item.id})',
      );
    } else if (widget.item.isNote) {
      await NoteService.deleteNote(widget.item.id, userId);
      AppLogger.success('Note deleted successfully (ID: ${widget.item.id})');
    } else if (widget.item.isStudySet || widget.item.isCoursePack) {
      if (widget.item.isClaimed) {
        AppLogger.info(
          'Deleting claimed course pack copy (original: ${widget.item.originalCoursePackId})',
        );
      }

      try {
        await CoursePackService.deleteCoursePack(widget.item.id);
        AppLogger.success(
          widget.item.isClaimed
              ? 'Claimed course pack copy deleted successfully - original remains intact'
              : 'Study set deleted successfully (ID: ${widget.item.id})',
        );
      } catch (e) {
        await CoursePackService.deleteCoursePack(widget.item.id);
        AppLogger.success(
          'Course pack deleted successfully (ID: ${widget.item.id})',
        );
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: AppDurations.snackBar,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.sm + 2),
        ),
        margin: AppPadding.allLg,
      ),
    );
  }

  void _handleTap(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (widget.item.isNote) {
      _navigateToNote(context, user.uid);
    } else if (widget.item.isStudySet) {
      _navigateToStudySet(context);
    } else if (widget.item.isFlashcard) {
      _navigateToFlashcard(context, user.uid);
    } else if (widget.item.isQuiz) {
      _navigateToQuiz(context, user.uid);
    }
  }

  void _handleEdit() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar('Please sign in to edit items');
      return;
    }

    // Check ownership before editing
    if (widget.item.ownerId != null && widget.item.ownerId != user.uid) {
      _showErrorSnackBar('You can only edit items you own');
      AppLogger.warning(
        'User ${user.uid} attempted to edit ${widget.item.type} ${widget.item.id} owned by ${widget.item.ownerId}',
      );
      return;
    }

    // Check if it's a claimed course pack (cannot edit claimed content)
    if (widget.item.isCoursePack && widget.item.isClaimed) {
      _showErrorSnackBar('Claimed course packs cannot be edited');
      return;
    }

    if (widget.item.isQuiz) {
      _navigateToEditQuiz(context, user.uid);
    } else if (widget.item.isFlashcard) {
      _navigateToEditFlashcard(context, user.uid);
    } else if (widget.item.isNote) {
      _navigateToEditNote(context, user.uid);
    } else if (widget.item.isStudySet || widget.item.isCoursePack) {
      _navigateToEditStudySet(context);
    }
  }

  void _navigateToEditQuiz(BuildContext context, String userId) {
    AppLogger.info('Navigating to edit quiz: ${widget.item.id}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaitScreen(
          loadingMessage: 'Loading quiz for editing',
          onLoadComplete: () async {
            // Pre-fetch questions for the quiz
            await QuizService.fetchQuestionsByQuizId(widget.item.id, userId);
          },
          onNavigate: () {
            Navigator.pushReplacement(
              context,
              customRoute(
                QuizDetails(
                  quizItem: QuizLibraryItem.fromJson(
                    widget.item.toQuizLibraryItem(),
                  ),
                  isEditMode: true,
                ),
                AnimationType.slideUp,
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToEditFlashcard(BuildContext context, String userId) {
    AppLogger.info('Navigating to edit flashcard set: ${widget.item.id}');
    FlashcardSet? loadedFlashcardSet;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaitScreen(
          loadingMessage: 'Loading flashcard set for editing',
          onLoadComplete: () async {
            loadedFlashcardSet = await FlashcardService.getFlashcardSet(
              widget.item.id,
              userId,
            );
          },
          onNavigate: () {
            if (loadedFlashcardSet != null) {
              Navigator.pushReplacement(
                context,
                customRoute(
                  FlashcardEditPage(
                    flashcardSet: loadedFlashcardSet!,
                    onSaved: () {
                      // Refresh library after save
                      ref.invalidate(quizLibraryProvider);
                    },
                  ),
                  AnimationType.slideUp,
                ),
              );
            } else {
              Navigator.pop(context);
              _showErrorSnackBar('Failed to load flashcard set');
            }
          },
        ),
      ),
    );
  }

  void _navigateToEditNote(BuildContext context, String userId) {
    AppLogger.info('Navigating to edit note: ${widget.item.id}');
    Note? loadedNote;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaitScreen(
          loadingMessage: 'Loading note for editing',
          onLoadComplete: () async {
            loadedNote = await NoteService.getNote(widget.item.id, userId);
          },
          onNavigate: () {
            if (loadedNote != null) {
              Navigator.pushReplacement(
                context,
                customRoute(
                  NoteEditPage(
                    note: loadedNote!,
                    onSaved: () {
                      // Refresh library after save
                      ref.invalidate(quizLibraryProvider);
                    },
                  ),
                  AnimationType.slideUp,
                ),
              );
            } else {
              Navigator.pop(context);
              _showErrorSnackBar('Failed to load note');
            }
          },
        ),
      ),
    );
  }

  void _navigateToEditStudySet(BuildContext context) {
    AppLogger.info('Navigating to edit study set: ${widget.item.id}');
    CoursePack? loadedStudySet;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaitScreen(
          loadingMessage: 'Loading course pack for editing',
          onLoadComplete: () async {
            loadedStudySet = await CoursePackService.fetchCoursePackById(
              widget.item.id,
            );
          },
          onNavigate: () {
            if (loadedStudySet != null) {
              // Load the study set into cache for editing
              StudySetCacheManager.instance.setStudySetFromCoursePack(
                loadedStudySet!,
              );
              Navigator.pushReplacement(
                context,
                customRoute(
                  StudySetDashboard(
                    studySetId: loadedStudySet!.id,
                    title: loadedStudySet!.name,
                    description: loadedStudySet!.description,
                    language: loadedStudySet!.language,
                    category: loadedStudySet!.category,
                    coverImagePath: loadedStudySet!.coverImagePath,
                    isEditing: true,
                  ),
                  AnimationType.slideUp,
                ),
              );
            } else {
              Navigator.pop(context);
              _showErrorSnackBar('Failed to load course pack');
            }
          },
        ),
      ),
    );
  }

  void _navigateToNote(BuildContext context, String userId) {
    Note? loadedNote;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaitScreen(
          loadingMessage: 'Loading note',
          onLoadComplete: () async {
            loadedNote = await NoteService.getNote(widget.item.id, userId);
          },
          onNavigate: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NoteViewerPage(
                  noteId: widget.item.id,
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
        builder: (context) => WaitScreen(
          loadingMessage: 'Loading flashcards',
          onLoadComplete: () async {
            loadedFlashcardSet = await FlashcardService.getFlashcardSet(
              widget.item.id,
              userId,
            );
          },
          onNavigate: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FlashcardPlayScreen(
                  flashcardSetId: widget.item.id,
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
        builder: (context) => WaitScreen(
          loadingMessage: 'Loading quiz',
          onLoadComplete: () async {
            loadedQuestions = await QuizService.fetchQuestionsByQuizId(
              widget.item.id,
              userId,
            );
          },
          onNavigate: () {
            Navigator.pushReplacement(
              context,
              customRoute(
                QuizPlayScreen(
                  quizItem: QuizLibraryItem.fromJson(
                    widget.item.toQuizLibraryItem(),
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
    CoursePack? loadedStudySet;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaitScreen(
          loadingMessage: 'Loading course pack',
          onLoadComplete: () async {
            loadedStudySet = await CoursePackService.fetchCoursePackById(
              widget.item.id,
            );
          },
          onNavigate: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudySetViewer(
                  studySetId: widget.item.id,
                  preloadedStudySet: loadedStudySet,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
