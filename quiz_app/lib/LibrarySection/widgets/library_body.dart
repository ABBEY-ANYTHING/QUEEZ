import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/models/library_item.dart';
import 'package:quiz_app/LibrarySection/widgets/item_card.dart';
import 'package:quiz_app/providers/navigation_provider.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';
import 'package:quiz_app/widgets/core/core_widgets.dart';

Widget buildSearchSection({
  required String searchQuery,
  required TextEditingController searchController,
  required ValueChanged<String> onQueryChanged,
  required BuildContext context,
  required VoidCallback onJoinPressed,
}) {
  return Container(
    margin: const EdgeInsets.fromLTRB(
      QuizSpacing.lg,
      QuizSpacing.md,
      QuizSpacing.lg,
      QuizSpacing.sm,
    ),
    child: Container(
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
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Search library...',
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
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: AppColors.iconInactive,
                    ),
                    onPressed: () {
                      searchController.clear();
                      onQueryChanged('');
                    },
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  onPressed: onJoinPressed,
                ),
              ],
            ),
          ),
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
  );
}

/// Build filter chips for library filtering
Widget buildFilterChips({
  required String? typeFilter,
  required ValueChanged<String?> onFilterChanged,
}) {
  final filters = [
    {'label': 'All', 'value': null},
    {'label': 'Favourites', 'value': 'favorites'},
    {'label': 'Quizzes', 'value': 'quiz'},
    {'label': 'Flashcards', 'value': 'flashcard'},
    {'label': 'Notes', 'value': 'note'},
    {'label': 'Courses', 'value': 'course_pack'},
  ];

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: QuizSpacing.lg),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = typeFilter == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: QuizSpacing.sm),
            child: FilterChip(
              label: Text(
                filter['label'] as String,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onFilterChanged(filter['value']),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              checkmarkColor: AppColors.white,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(
                horizontal: QuizSpacing.sm,
                vertical: QuizSpacing.xs,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.iconInactive.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
  required VoidCallback onFavoriteChanged,
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
    sliver: SliverToBoxAdapter(
      child: _AnimatedItemList(
        items: filteredItems,
        onFavoriteChanged: onFavoriteChanged,
      ),
    ),
  );
}

class _AnimatedItemList extends ConsumerStatefulWidget {
  final List<LibraryItem> items;
  final VoidCallback onFavoriteChanged;

  const _AnimatedItemList({
    required this.items,
    required this.onFavoriteChanged,
  });

  @override
  ConsumerState<_AnimatedItemList> createState() => _AnimatedItemListState();
}

class _AnimatedItemListState extends ConsumerState<_AnimatedItemList> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    // Initialize keys for all items
    for (final item in widget.items) {
      _itemKeys[item.id] = GlobalKey();
    }

    // Scroll to highlighted item on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToHighlightedItem();
    });
  }

  @override
  void didUpdateWidget(_AnimatedItemList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update keys for new items
    for (final item in widget.items) {
      _itemKeys.putIfAbsent(item.id, () => GlobalKey());
    }

    // Check if we need to scroll to highlighted item
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToHighlightedItem();
    });
  }

  void _scrollToHighlightedItem() {
    final highlightedId = ref.read(highlightedLibraryItemProvider);
    if (highlightedId == null) return;

    final key = _itemKeys[highlightedId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.3, // Scroll so item is roughly 30% from top
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlightedItemId = ref.watch(highlightedLibraryItemProvider);

    // Clear highlight after it's been shown for a while
    if (highlightedItemId != null) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          ref.read(highlightedLibraryItemProvider.notifier).clearHighlight();
        }
      });
    }

    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final isHighlighted = highlightedItemId == item.id;

        return Padding(
          key: _itemKeys[item.id],
          padding: const EdgeInsets.only(bottom: QuizSpacing.md),
          child: ItemCard(
            key: ValueKey(item.id),
            item: item,
            isHighlighted: isHighlighted,
            onFavoriteChanged: widget.onFavoriteChanged,
            onDelete: () {
              // Delete is handled inside ItemCard, library will be refreshed
            },
          ),
        );
      },
    );
  }
}
