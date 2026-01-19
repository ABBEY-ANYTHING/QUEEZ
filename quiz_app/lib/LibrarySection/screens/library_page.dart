import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/models/library_item.dart';
import 'package:quiz_app/LibrarySection/widgets/add_quiz_modal.dart';
import 'package:quiz_app/LibrarySection/widgets/library_body.dart';
import 'package:quiz_app/providers/library_provider.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/globals.dart';
import 'package:quiz_app/utils/translations.dart';
import 'package:quiz_app/widgets/appbar/universal_appbar.dart';

import '../../utils/quiz_design_system.dart';

final GlobalKey<LibraryPageState> libraryPageKey =
    GlobalKey<LibraryPageState>();

class LibraryPage extends ConsumerStatefulWidget {
  LibraryPage({Key? key}) : super(key: libraryPageKey);

  @override
  ConsumerState<LibraryPage> createState() => LibraryPageState();

  /// ✅ Static method to call reload from anywhere
  static void reloadItems() {
    libraryPageKey.currentState?._reloadItems();
  }

  /// 🔍 Static method to set search query
  static void setSearchQuery(String query) {
    libraryPageKey.currentState?._setSearchQuery(query);
  }
}

class LibraryPageState extends ConsumerState<LibraryPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  String _searchQuery = '';
  String? _typeFilter; // null = all, 'quiz', or 'flashcard'
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

  /// 🔍 Set search query (also refreshes data if needed)
  void _setSearchQuery(String query) {
    AppLogger.info('_setSearchQuery called with: "$query"');

    // First invalidate to ensure fresh data is fetched
    AppLogger.info('Invalidating quizLibraryProvider...');
    ref.invalidate(quizLibraryProvider);
    AppLogger.success('quizLibraryProvider invalidated');

    // Then update the search query UI
    AppLogger.info('Updating search query state...');
    setState(() {
      _searchQuery = query;
      _searchController.text = query;
    });
    AppLogger.success('Search query state updated, _searchQuery = "$_searchQuery"');
  }

  void _filterItems(String query) {
    AppLogger.debug('_filterItems called with: "$query"');
    setState(() {
      _searchQuery = query;
    });
  }

  void _setTypeFilter(String? filter) {
    AppLogger.debug('Setting filter to: $filter');
    setState(() {
      _typeFilter = filter;
    });
  }

  /// Handle favorite changes (no longer needs server reload - handled locally)
  void _onFavoriteChanged() {
    AppLogger.debug('Favorite changed (handled locally)');
  }

  List<LibraryItem> _getFilteredItems(List<LibraryItem> allItems) {
    var filtered = allItems;

    AppLogger.debug('Filtering ${allItems.length} items with filter: $_typeFilter');

    // Apply type filter
    if (_typeFilter != null) {
      if (_typeFilter == 'favorites') {
        // Filter for favorites only
        filtered = filtered.where((item) => item.isFavorite).toList();
        AppLogger.debug('After favorites filter: ${filtered.length} items');
      } else {
        // Filter by type
        filtered = filtered.where((item) => item.type == _typeFilter).toList();
        AppLogger.debug('After type filter ($_typeFilter): ${filtered.length} items');
      }
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final beforeSearchCount = filtered.length;
      filtered = filtered.where((item) {
        return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
      AppLogger.debug('After search filter "$_searchQuery": ${filtered.length} items (was $beforeSearchCount)');
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(quizLibraryProvider);
    AppLogger.debug('build() called, watching quizLibraryProvider');

    // Get filtered items and loading/error state from AsyncValue
    bool isLoading = false;
    String? errorMessage;
    List<LibraryItem> filteredItems = [];

    itemsAsync.when(
      data: (items) {
        AppLogger.success('Provider has data: ${items.length} total items');
        filteredItems = _getFilteredItems(items);
        AppLogger.debug('After filtering with query "$_searchQuery": ${filteredItems.length} items');
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
                searchQuery: _searchQuery,
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
                typeFilter: _typeFilter,
                onFilterChanged: _setTypeFilter,
              ),
            ),
            buildLibraryBody(
              context: context,
              isLoading: isLoading,
              errorMessage: errorMessage,
              filteredItems: filteredItems,
              searchQuery: _searchQuery,
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
