import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/models/library_item.dart';
import 'package:quiz_app/LibrarySection/widgets/add_quiz_modal.dart';
import 'package:quiz_app/LibrarySection/widgets/library_body.dart';
import 'package:quiz_app/providers/library_provider.dart';
import 'package:quiz_app/providers/library_search_provider.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/globals.dart';
import 'package:quiz_app/utils/translations.dart';
import 'package:quiz_app/widgets/appbar/universal_appbar.dart';

import '../../utils/quiz_design_system.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => LibraryPageState();
}

class LibraryPageState extends ConsumerState<LibraryPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: QuizAnimations.feedback,
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// 🔁 Reload items from server
  Future<void> _reloadItems() async {
    AppLogger.info('_reloadItems called');
    await ref.read(quizLibraryProvider.notifier).reload();
    AppLogger.success('_reloadItems completed');
  }

  void _filterItems(String query) {
    AppLogger.debug('_filterItems called with: "$query"');
    ref.read(librarySearchQueryProvider.notifier).setQuery(query);
  }

  void _setTypeFilter(String? filter) {
    AppLogger.debug('Setting filter to: $filter');
    ref.read(libraryTypeFilterProvider.notifier).setFilter(filter);
  }

  /// Handle favorite changes (no longer needs server reload - handled locally)
  void _onFavoriteChanged() {
    AppLogger.debug('Favorite changed (handled locally)');
  }

  List<LibraryItem> _getFilteredItems(
    List<LibraryItem> allItems,
    String searchQuery,
    String? typeFilter,
  ) {
    var filtered = allItems;

    AppLogger.debug(
      'Filtering ${allItems.length} items with filter: $typeFilter',
    );

    // Apply type filter
    if (typeFilter != null) {
      if (typeFilter == 'favorites') {
        // Filter for favorites only
        filtered = filtered.where((item) => item.isFavorite).toList();
        AppLogger.debug('After favorites filter: ${filtered.length} items');
      } else {
        // Filter by type
        filtered = filtered.where((item) => item.type == typeFilter).toList();
        AppLogger.debug(
          'After type filter ($typeFilter): ${filtered.length} items',
        );
      }
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final beforeSearchCount = filtered.length;
      filtered = filtered.where((item) {
        return item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            item.description.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
      AppLogger.debug(
        'After search filter "$searchQuery": ${filtered.length} items (was $beforeSearchCount)',
      );
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(quizLibraryProvider);
    final searchQuery = ref.watch(librarySearchQueryProvider);
    final typeFilter = ref.watch(libraryTypeFilterProvider);

    AppLogger.debug('build() called, watching quizLibraryProvider');

    // Sync the text controller with the provider state
    if (_searchController.text != searchQuery) {
      _searchController.text = searchQuery;
    }

    // Get filtered items and loading/error state from AsyncValue
    bool isLoading = false;
    String? errorMessage;
    List<LibraryItem> filteredItems = [];

    itemsAsync.when(
      data: (items) {
        AppLogger.success('Provider has data: ${items.length} total items');
        filteredItems = _getFilteredItems(items, searchQuery, typeFilter);
        AppLogger.debug(
          'After filtering with query "$searchQuery": ${filteredItems.length} items',
        );
        for (var i = 0; i < filteredItems.length && i < 5; i++) {
          AppLogger.debug('Filtered item $i: ${filteredItems[i].title}');
        }
      },
      loading: () {
        AppLogger.info('Provider is loading...');
        isLoading = true;
      },
      error: (error, _) {
        AppLogger.error('Provider has error', exception: error);
        errorMessage = error.toString();
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UniversalAppBar(title: 'library'.tr(ref), showBackButton: false),
      body: RefreshIndicator(
        onRefresh: _reloadItems,
        color: AppColors.primary,
        backgroundColor: AppColors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: buildSearchSection(
                searchQuery: searchQuery,
                searchController: _searchController,
                onQueryChanged: _filterItems,
                context: context,
                onJoinPressed: () {
                  showAddQuizModal(context, _reloadItems);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: buildFilterChips(
                typeFilter: typeFilter,
                onFilterChanged: _setTypeFilter,
              ),
            ),
            buildLibraryBody(
              context: context,
              isLoading: isLoading,
              errorMessage: errorMessage,
              filteredItems: filteredItems,
              searchQuery: searchQuery,
              onRetry: _reloadItems,
              onFavoriteChanged: _onFavoriteChanged,
            ),
            const SliverPadding(
              padding: EdgeInsets.only(bottom: kBottomNavbarHeight),
            ),
          ],
        ),
      ),
    );
  }
}
