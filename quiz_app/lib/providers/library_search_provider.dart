import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_search_provider.g.dart';

/// Provider for library search query state
/// Replaces GlobalKey pattern for controlling library page search
@riverpod
class LibrarySearchQuery extends _$LibrarySearchQuery {
  @override
  String build() {
    return '';
  }

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// Provider for library type filter state
@riverpod
class LibraryTypeFilter extends _$LibraryTypeFilter {
  @override
  String? build() {
    return null; // null = all types
  }

  void setFilter(String? filter) {
    state = filter;
  }

  void clearFilter() {
    state = null;
  }
}

/// Provider to signal library reload
/// Increment to trigger a reload
@riverpod
class LibraryReloadTrigger extends _$LibraryReloadTrigger {
  @override
  int build() {
    return 0;
  }

  void triggerReload() {
    state++;
  }
}
