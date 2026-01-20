import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/CreateSection/models/note.dart';
import 'package:quiz_app/CreateSection/screens/flashcard_play_screen_new.dart';
import 'package:quiz_app/CreateSection/screens/note_viewer_page.dart';
import 'package:quiz_app/CreateSection/screens/study_set_viewer.dart';
import 'package:quiz_app/CreateSection/services/course_pack_service.dart';
import 'package:quiz_app/CreateSection/services/flashcard_service.dart';
import 'package:quiz_app/CreateSection/services/note_service.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/LibrarySection/PlaySection/screens/quiz_play_screen.dart';
import 'package:quiz_app/LibrarySection/models/library_item.dart';
import 'package:quiz_app/LibrarySection/screens/mode_selection_sheet.dart';
import 'package:quiz_app/LibrarySection/widgets/quiz_library_item.dart';
import 'package:quiz_app/providers/library_provider.dart';
import 'package:quiz_app/services/favorites_service.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/widgets/wait_screen.dart';

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
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _highlightController;
  late Animation<double> _highlightAnimation;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.item.isFavorite;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Highlight animation controller
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _highlightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeInOut),
    );

    // Start highlight animation if this item is highlighted
    if (widget.isHighlighted) {
      _startHighlightAnimation();
    }
  }

  void _startHighlightAnimation() {
    // Animate 3 times then stop
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
                // Main card container
                Container(
                  decoration: BoxDecoration(
                    color: _getCardBackgroundColor(),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(28),
                      topRight: const Radius.circular(16),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getCardBackgroundColor().withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    // Highlight border when item is highlighted
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
                          clipper: _AccentShapeClipper(),
                          child: Container(
                            width: 150,
                            height: 120,
                            color: _getAccentColor().withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      // Main content
                      Row(
                        children: [
                          // Thumbnail with unique shape
                          _buildThumbnail(),
                          // Content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(4, 18, 50, 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Type Badge Row with marketplace tag
                                  _buildTypeBadgeRow(),
                                  const SizedBox(height: 12),
                                  // Title
                                  Text(
                                    widget.item.title,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: _getTextColor(),
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.item.description.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.item.description,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _getTextColor().withValues(
                                          alpha: 0.7,
                                        ),
                                        fontWeight: FontWeight.w400,
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 14),
                                  // Stats Row
                                  _buildStatsRow(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Action buttons (share + more)
                      Positioned(
                        top: 14,
                        right: 14,
                        child: _buildActionButtons(context),
                      ),
                      // Options bubbles
                      if (_showOptions) _buildOptionsBubbles(),
                      // Delete loading overlay
                      if (_isDeleting)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(28),
                                topRight: const Radius.circular(16),
                                bottomLeft: const Radius.circular(16),
                                bottomRight: const Radius.circular(28),
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Highlight glow effect
                if (widget.isHighlighted && highlightValue > 0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(28),
                            topRight: const Radius.circular(16),
                            bottomLeft: const Radius.circular(16),
                            bottomRight: const Radius.circular(28),
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
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build type badge row with optional marketplace tag
  Widget _buildTypeBadgeRow() {
    return Row(
      children: [
        _buildTypeBadge(),
        // Marketplace listing tag for course packs that are public
        if (widget.item.isCoursePack && widget.item.isPublic) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentBright.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.accentBright.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storefront_rounded,
                  size: 12,
                  color: AppColors.accentBright,
                ),
                const SizedBox(width: 4),
                Text(
                  'Listed',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentBright,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Favorite button
        GestureDetector(
          onTap: _toggleFavorite,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: _isFavorite ? Colors.red : _getAccentColor(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Share button
        GestureDetector(
          onTap: () => _handleShare(context),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.share_outlined,
              size: 18,
              color: _getAccentColor(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // More button
        GestureDetector(
          onTap: _toggleOptions,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.more_horiz, size: 20, color: _getTextColor()),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleFavorite() async {
    // Optimistic UI update - toggle locally first for instant feedback
    final newFavoriteStatus = !_isFavorite;
    setState(() {
      _isFavorite = newFavoriteStatus;
    });

    // Update provider state locally (no server reload)
    ref
        .read(quizLibraryProvider.notifier)
        .toggleFavoriteLocally(widget.item.id, newFavoriteStatus);

    try {
      // Persist to Firestore in background
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
    } catch (e) {
      AppLogger.error('Error persisting favorite', exception: e);
      // Revert on error
      setState(() {
        _isFavorite = !newFavoriteStatus;
      });
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
      // For other types, show a simple share message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Share ${_getTypeLabel()} coming soon!'),
          backgroundColor: _getAccentColor(),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildOptionsBubbles() {
    return Positioned(
      top: 52,
      right: 12,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.topRight,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildOptionItem(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      color: AppColors.primary,
                      onTap: () {
                        _hideOptions();
                        // TODO: Implement edit functionality
                      },
                    ),
                    // Remove from marketplace option (only for public course packs)
                    if (widget.item.isCoursePack && widget.item.isPublic) ...[
                      Container(height: 1, color: AppColors.surface),
                      _buildOptionItem(
                        icon: Icons.remove_shopping_cart_outlined,
                        label: 'Remove from Marketplace',
                        color: AppColors.accentBright,
                        onTap: () {
                          _hideOptions();
                          _showRemoveFromMarketplaceDialog();
                        },
                      ),
                    ],
                    Container(height: 1, color: AppColors.surface),
                    _buildOptionItem(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      color: AppColors.error,
                      onTap: () {
                        _hideOptions();
                        _showDeleteConfirmationDialog();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Show confirmation dialog for removing from marketplace
  Future<void> _showRemoveFromMarketplaceDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentBright.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.remove_shopping_cart_outlined,
                color: AppColors.accentBright,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Remove from Marketplace',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          'This will remove "${widget.item.title}" from the public marketplace. Users will no longer be able to claim it.\n\nYou can list it again later.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBright,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Remove',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _removeFromMarketplace();
    }
  }

  /// Remove course pack from marketplace
  Future<void> _removeFromMarketplace() async {
    setState(() => _isDeleting = true);

    try {
      AppLogger.info(
        'Removing course pack from marketplace: ${widget.item.id}',
      );

      await CoursePackService.publishCoursePack(
        widget.item.id,
        isPublic: false,
      );

      AppLogger.success('Course pack removed from marketplace');

      if (!mounted) return;

      setState(() => _isDeleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Expanded(child: Text('Removed from marketplace')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      // Reload library to update the isPublic status
      ref.invalidate(quizLibraryProvider);
    } catch (e) {
      AppLogger.error('Failed to remove from marketplace', exception: e);

      if (!mounted) return;

      setState(() => _isDeleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to remove from marketplace: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show confirmation dialog before deleting
  Future<void> _showDeleteConfirmationDialog() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Safety check: ensure user is logged in
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to delete items'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Safety check: prevent deletion if this is the original course pack and user is not the owner
    // (A claimed copy will have originalCoursePackId set)
    if (widget.item.isCoursePack && !widget.item.isClaimed) {
      // This is an original course pack - only the owner can delete it
      if (widget.item.ownerId != userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.lock_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('You can only delete your own course packs'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        AppLogger.warning(
          'User $userId attempted to delete course pack ${widget.item.id} owned by ${widget.item.ownerId}',
        );
        return;
      }
    }

    // For all items: verify ownership before showing delete dialog
    if (widget.item.ownerId != null && widget.item.ownerId != userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Expanded(child: Text('You can only delete items you own')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      AppLogger.warning(
        'User $userId attempted to delete ${widget.item.type} ${widget.item.id} owned by ${widget.item.ownerId}',
      );
      return;
    }

    // Prepare deletion details message
    String deletionMessage;
    if (widget.item.isCoursePack && widget.item.isClaimed) {
      final authorName = widget.item.originalOwnerUsername ?? 'the author';
      deletionMessage =
          'Are you sure you want to delete your copy of "${widget.item.title}"?\n\n'
          '📌 The original course pack by $authorName will remain available.\n\n'
          'This action cannot be undone.';
    } else {
      deletionMessage =
          'Are you sure you want to delete "${widget.item.title}"?\n\nThis action cannot be undone.';
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Delete Item',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          deletionMessage,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performDelete();
    }
  }

  /// Perform the actual delete operation with ownership verification
  Future<void> _performDelete() async {
    setState(() => _isDeleting = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // SECURITY CHECK 1: Verify ownership
      if (widget.item.ownerId != null && widget.item.ownerId != userId) {
        throw Exception('You do not have permission to delete this item');
      }

      // SECURITY CHECK 2: Prevent deletion of original course packs if not the owner
      if (widget.item.isCoursePack &&
          !widget.item.isClaimed &&
          widget.item.ownerId != userId) {
        throw Exception('You cannot delete course packs you do not own');
      }

      AppLogger.info(
        'Deleting ${widget.item.type}: ${widget.item.id} (owned by: ${widget.item.ownerId}, isClaimed: ${widget.item.isClaimed})',
      );

      // Delete based on item type
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
        // Determine if this is a claimed copy or original
        if (widget.item.isClaimed) {
          AppLogger.info(
            'Deleting claimed course pack copy (original: ${widget.item.originalCoursePackId})',
          );
        }

        // Delete course pack
        try {
          await CoursePackService.deleteCoursePack(widget.item.id);
          if (widget.item.isCoursePack && widget.item.isClaimed) {
            AppLogger.success(
              'Claimed course pack copy deleted successfully - original remains intact',
            );
          } else {
            AppLogger.success(
              'Study set deleted successfully (ID: ${widget.item.id})',
            );
          }
        } catch (e) {
          // If study set delete fails, try course pack delete
          await CoursePackService.deleteCoursePack(widget.item.id);
          AppLogger.success(
            'Course pack deleted successfully (ID: ${widget.item.id})',
          );
        }
      }

      if (!mounted) return;

      setState(() => _isDeleting = false);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('${_getTypeLabel()} deleted successfully')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      // Reload library to reflect the deletion
      ref.invalidate(quizLibraryProvider);

      // Also call the parent's onDelete callback
      widget.onDelete();
    } catch (e) {
      AppLogger.error('Failed to delete ${widget.item.type}', exception: e);

      if (!mounted) return;

      setState(() => _isDeleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 105,
      height: 140,
      margin: const EdgeInsets.all(16),
      child: ClipPath(
        clipper: _ThumbnailShapeClipper(),
        child: Container(
          decoration: BoxDecoration(color: _getAccentColor()),
          child: widget.item.coverImagePath != null
              ? Image.network(
                  widget.item.coverImagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildDefaultThumbnailIcon(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildDefaultThumbnailIcon();
                  },
                )
              : _buildDefaultThumbnailIcon(),
        ),
      ),
    );
  }

  Widget _buildDefaultThumbnailIcon() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getTypeIcon(),
            size: 42,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 6),
          Text(
            _getTypeLabel(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getAccentColor(),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(12),
          bottomLeft: const Radius.circular(12),
          bottomRight: const Radius.circular(4),
        ),
      ),
      child: Text(
        _getTypeLabel().toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        // Item count
        _buildStatChip(icon: _getTypeIcon(), text: _getItemCountText()),
        // Author (if available)
        if (widget.item.originalOwnerUsername != null &&
            widget.item.originalOwnerUsername!.isNotEmpty)
          _buildStatChip(
            icon: Icons.person_outline_rounded,
            text: widget.item.originalOwnerUsername!,
          ),
        // Date (if available)
        if (widget.item.createdAt != null)
          _buildStatChip(
            icon: Icons.access_time_rounded,
            text: _formatDateShort(widget.item.createdAt!),
          ),
      ],
    );
  }

  Widget _buildStatChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getAccentColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _getTextColor()),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Earth tone background colors
  Color _getCardBackgroundColor() {
    if (widget.item.isQuiz) return const Color(0xFFF5F0E8); // Warm cream
    if (widget.item.isNote) return const Color(0xFFFDF6E3); // Soft sand
    if (widget.item.isStudySet) return const Color(0xFFE8F0E8); // Sage mist
    if (widget.item.isCoursePack) return const Color(0xFFE8EBF0); // Cool slate
    return const Color(0xFFF0EDE8); // Warm stone - Flashcard
  }

  // Accent colors (darker earth tones)
  Color _getAccentColor() {
    if (widget.item.isQuiz) return const Color(0xFF5E8C61); // Forest green
    if (widget.item.isNote) return const Color(0xFFB8860B); // Dark goldenrod
    if (widget.item.isStudySet) return const Color(0xFF6B8E7B); // Eucalyptus
    if (widget.item.isCoursePack) return const Color(0xFF5B6B8C); // Slate blue
    return const Color(0xFF8B7355); // Warm brown - Flashcard
  }

  // Text colors
  Color _getTextColor() {
    if (widget.item.isQuiz) return const Color(0xFF3D5940); // Deep forest
    if (widget.item.isNote) return const Color(0xFF6B4423); // Saddle brown
    if (widget.item.isStudySet) return const Color(0xFF4A6B5A); // Deep sage
    if (widget.item.isCoursePack) return const Color(0xFF3A4A5C); // Deep slate
    return const Color(0xFF5C4A3A); // Dark brown - Flashcard
  }

  IconData _getTypeIcon() {
    if (widget.item.isQuiz) return Icons.quiz_outlined;
    if (widget.item.isNote) return Icons.description_outlined;
    if (widget.item.isStudySet) return Icons.collections_bookmark_outlined;
    if (widget.item.isCoursePack) return Icons.school_outlined;
    return Icons.style_outlined; // Flashcard
  }

  String _getTypeLabel() {
    if (widget.item.isQuiz) return 'Quiz';
    if (widget.item.isNote) return 'Note';
    if (widget.item.isStudySet) return 'Course Pack';
    return 'Flashcards';
  }

  String _getItemCountText() {
    if (widget.item.isNote) return 'Note';
    if (widget.item.isStudySet) return '${widget.item.itemCount} Items';
    if (widget.item.isQuiz) return '${widget.item.itemCount} Questions';
    if (widget.item.isCoursePack) return '${widget.item.itemCount} Items';
    return '${widget.item.itemCount} Cards';
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

// Custom clipper for the thumbnail with organic shape
class _ThumbnailShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Create an organic blob-like shape
    path.moveTo(w * 0.1, h * 0.05);
    path.quadraticBezierTo(w * 0.5, 0, w * 0.9, h * 0.08);
    path.quadraticBezierTo(w, h * 0.15, w * 0.95, h * 0.4);
    path.quadraticBezierTo(w, h * 0.6, w * 0.92, h * 0.85);
    path.quadraticBezierTo(w * 0.85, h, w * 0.5, h * 0.95);
    path.quadraticBezierTo(w * 0.15, h, w * 0.08, h * 0.85);
    path.quadraticBezierTo(0, h * 0.7, 0, h * 0.5);
    path.quadraticBezierTo(0, h * 0.2, w * 0.1, h * 0.05);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Format date with shortened month (e.g., "January 20, 2025" -> "Jan 20, 2025")
String _formatDateShort(String dateString) {
  try {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final shortMonths = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    for (int i = 0; i < months.length; i++) {
      if (dateString.contains(months[i])) {
        return dateString
            .replaceFirst(months[i], shortMonths[i])
            .replaceAll(', ', ' '); // Remove comma and extra space
      }
    }
    return dateString;
  } catch (e) {
    return dateString;
  }
}

// Custom clipper for the decorative accent shape
class _AccentShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Create a flowing wave shape
    path.moveTo(w * 0.3, 0);
    path.lineTo(w, 0);
    path.lineTo(w, h * 0.6);
    path.quadraticBezierTo(w * 0.7, h * 0.8, w * 0.4, h * 0.5);
    path.quadraticBezierTo(w * 0.1, h * 0.2, w * 0.3, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
