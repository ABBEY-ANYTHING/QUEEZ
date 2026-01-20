// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for library search query state
/// Replaces GlobalKey pattern for controlling library page search

@ProviderFor(LibrarySearchQuery)
const librarySearchQueryProvider = LibrarySearchQueryProvider._();

/// Provider for library search query state
/// Replaces GlobalKey pattern for controlling library page search
final class LibrarySearchQueryProvider
    extends $NotifierProvider<LibrarySearchQuery, String> {
  /// Provider for library search query state
  /// Replaces GlobalKey pattern for controlling library page search
  const LibrarySearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'librarySearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$librarySearchQueryHash();

  @$internal
  @override
  LibrarySearchQuery create() => LibrarySearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$librarySearchQueryHash() =>
    r'216fe5a134dbe873a14ceb3fdbd37bc244ec1925';

/// Provider for library search query state
/// Replaces GlobalKey pattern for controlling library page search

abstract class _$LibrarySearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for library type filter state

@ProviderFor(LibraryTypeFilter)
const libraryTypeFilterProvider = LibraryTypeFilterProvider._();

/// Provider for library type filter state
final class LibraryTypeFilterProvider
    extends $NotifierProvider<LibraryTypeFilter, String?> {
  /// Provider for library type filter state
  const LibraryTypeFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryTypeFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryTypeFilterHash();

  @$internal
  @override
  LibraryTypeFilter create() => LibraryTypeFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$libraryTypeFilterHash() => r'91a648d39c687ea38291e79fd9710a73677ecffc';

/// Provider for library type filter state

abstract class _$LibraryTypeFilter extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider to signal library reload
/// Increment to trigger a reload

@ProviderFor(LibraryReloadTrigger)
const libraryReloadTriggerProvider = LibraryReloadTriggerProvider._();

/// Provider to signal library reload
/// Increment to trigger a reload
final class LibraryReloadTriggerProvider
    extends $NotifierProvider<LibraryReloadTrigger, int> {
  /// Provider to signal library reload
  /// Increment to trigger a reload
  const LibraryReloadTriggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryReloadTriggerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryReloadTriggerHash();

  @$internal
  @override
  LibraryReloadTrigger create() => LibraryReloadTrigger();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$libraryReloadTriggerHash() =>
    r'e6ca365586d87d96d406417367f13d03ee515475';

/// Provider to signal library reload
/// Increment to trigger a reload

abstract class _$LibraryReloadTrigger extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
