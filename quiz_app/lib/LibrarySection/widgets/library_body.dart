import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/services/flashcard_service.dart';
import 'package:quiz_app/CreateSection/services/note_service.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/CreateSection/services/study_set_service.dart';
import 'package:quiz_app/LibrarySection/models/library_item.dart';
import 'package:quiz_app/LibrarySection/widgets/item_card.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';
import 'package:quiz_app/widgets/core/core_widgets.dart';

Widget buildSearchSection({
  required String searchQuery,
  required TextEditingController searchController,
  required ValueChanged<String> onQueryChanged,
  required BuildContext context,
  required VoidCallback onAddQuiz,
  required VoidCallback onFilter,
  required String? typeFilter,
}) {
  return Container(
    margin: const EdgeInsets.all(QuizSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Library',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            Row(
              children: [
                Stack(
                  children: [
                    IconButton(
                      onPressed: onFilter,
                      icon: const Icon(Icons.filter_list, size: 24),
                      tooltip: 'Filter library',
                    ),
                    if (typeFilter != null)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: onAddQuiz,
                  icon: const Icon(Icons.add, size: 24),
                  tooltip: 'Add a quiz',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: QuizSpacing.lg),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Search quizzes and flashcards...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.search_rounded,
                  color: AppColors.iconInactive,
                  size: 24,
                ),
              ),
              suffixIcon:
                  searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.iconInactive,
                        ),
                        onPressed: () {
                          searchController.clear();
                          onQueryChanged('');
                        },
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildLibraryBody({
  required BuildContext context,
  required bool isLoading,
  required String? errorMessage,
  required List<LibraryItem> filteredItems,
  required String searchQuery,
  required VoidCallback onRetry,
}) {
  if (isLoading) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading your library...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait a moment',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  if (errorMessage != null) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 60, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: QuizSpacing.md),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: QuizSpacing.lg),
            AppButton.primary(text: 'Try Again', onPressed: onRetry),
          ],
        ),
      ),
    );
  }

  if (filteredItems.isEmpty) {
    return SliverFillRemaining(
      child: Center(
        child: Text(
          searchQuery.isNotEmpty ? 'No matches found' : 'No items in library',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  return SliverPadding(
    padding: const EdgeInsets.all(QuizSpacing.lg),
    sliver: SliverToBoxAdapter(child: _AnimatedItemList(items: filteredItems)),
  );
}

class _AnimatedItemList extends StatefulWidget {
  final List<LibraryItem> items;

  const _AnimatedItemList({required this.items});

  @override
  State<_AnimatedItemList> createState() => _AnimatedItemListState();
}

class _AnimatedItemListState extends State<_AnimatedItemList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<LibraryItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  void didUpdateWidget(_AnimatedItemList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != _items.length) {
      _items = List.from(widget.items);
    }
  }

  Future<void> _removeItem(int index) async {
    final removedItem = _items[index];
    _items.removeAt(index);

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildItemCard(removedItem, animation, index),
      duration: QuizAnimations.slow,
    );
  }

  Widget _buildItemCard(
    LibraryItem item,
    Animation<double> animation,
    int index,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: Container(
            margin: const EdgeInsets.only(bottom: QuizSpacing.md),
            child: ItemCard(
              item: item,
              onDelete: () async {
                // Capture context before any async operations
                final dialogContext = context;
                
                // Check if context is still valid
                if (!dialogContext.mounted) return;
                
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text(
                          'Delete ${item.isQuiz
                              ? 'Quiz'
                              : item.isNote
                              ? 'Note'
                              : item.isStudySet
                              ? 'Study Set'
                              : 'Flashcard Set'}',
                        ),
                        content: Text(
                          'Are you sure you want to delete "${item.title}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                );

                if (confirmed == true) {
                  try {
                    // Delete from backend based on type
                    if (item.isQuiz) {
                      await QuizService.deleteQuiz(item.id);
                    } else if (item.isFlashcard) {
                      await FlashcardService.deleteFlashcardSet(item.id);
                    } else if (item.isNote) {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await NoteService.deleteNote(item.id, user.uid);
                      }
                    } else if (item.isStudySet) {
                      await StudySetService.deleteStudySet(item.id);
                    }

                    // Remove item with animation
                    await _removeItem(index);

                    // Show success message
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${item.isQuiz
                              ? 'Quiz'
                              : item.isNote
                              ? 'Note'
                              : item.isStudySet
                              ? 'Study Set'
                              : 'Flashcard set'} deleted successfully',
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    // Show error message
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete: $e'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        if (index >= _items.length) return const SizedBox.shrink();
        return _buildItemCard(_items[index], animation, index);
      },
    );
  }
}
