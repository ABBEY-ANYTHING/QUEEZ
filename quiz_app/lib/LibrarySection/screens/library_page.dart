import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/models/library_item.dart';
import 'package:quiz_app/LibrarySection/widgets/add_quiz_modal.dart';
import 'package:quiz_app/LibrarySection/widgets/library_body.dart';
import 'package:quiz_app/providers/library_provider.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/globals.dart';
import 'package:quiz_app/widgets/appbar/universal_appbar.dart';
import 'package:quiz_app/widgets/core/core_widgets.dart';

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
    await ref.read(quizLibraryProvider.notifier).reload();
  }

  /// 🔍 Set search query
  void _setSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _searchController.text = query;
    });
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _showFilterDialog() {
    AppDialog.show(
      context: context,
      title: 'Filter Library',
      content: StatefulBuilder(
        builder: (context, setDialogState) => RadioGroup<String?>(
          groupValue: _typeFilter,
          onChanged: (value) {
            setDialogState(() => _typeFilter = value);
            setState(() => _typeFilter = value);
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String?>(
                title: const Text('All Items'),
                value: null,
              ),
              RadioListTile<String?>(
                title: const Text('Quizzes'),
                value: 'quiz',
              ),
              RadioListTile<String?>(
                title: const Text('Flashcards'),
                value: 'flashcard',
              ),
              RadioListTile<String?>(title: const Text('Notes'), value: 'note'),
              RadioListTile<String?>(
                title: const Text('Study Sets'),
                value: 'study_set',
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<LibraryItem> _getFilteredItems(List<LibraryItem> allItems) {
    var filtered = allItems;

    // Apply type filter
    if (_typeFilter != null) {
      filtered = filtered.where((item) => item.type == _typeFilter).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(quizLibraryProvider);

    // Get filtered items and loading/error state from AsyncValue
    bool isLoading = false;
    String? errorMessage;
    List<LibraryItem> filteredItems = [];

    itemsAsync.when(
      data: (items) {
        filteredItems = _getFilteredItems(items);
      },
      loading: () {
        isLoading = true;
      },
      error: (error, _) {
        errorMessage = error.toString();
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const UniversalAppBar(title: 'Library', showBackButton: false),
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
                onAddQuiz: () {
                  showAddQuizModal(context, _reloadItems);
                },
                onFilter: _showFilterDialog,
                typeFilter: _typeFilter,
              ),
            ),
            buildLibraryBody(
              context: context,
              isLoading: isLoading,
              errorMessage: errorMessage,
              filteredItems: filteredItems,
              searchQuery: _searchQuery,
              onRetry: _reloadItems,
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
