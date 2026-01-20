// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for bottom navbar selected index

@ProviderFor(BottomNavIndex)
const bottomNavIndexProvider = BottomNavIndexProvider._();

/// Provider for bottom navbar selected index
final class BottomNavIndexProvider
    extends $NotifierProvider<BottomNavIndex, int> {
  /// Provider for bottom navbar selected index
  const BottomNavIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bottomNavIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bottomNavIndexHash();

  @$internal
  @override
  BottomNavIndex create() => BottomNavIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$bottomNavIndexHash() => r'0b05161dbc35d80a1fcb8889b37f8963ef23441e';

/// Provider for bottom navbar selected index

abstract class _$BottomNavIndex extends $Notifier<int> {
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

/// Provider for tracking previous navigation index

@ProviderFor(PreviousNavIndex)
const previousNavIndexProvider = PreviousNavIndexProvider._();

/// Provider for tracking previous navigation index
final class PreviousNavIndexProvider
    extends $NotifierProvider<PreviousNavIndex, int> {
  /// Provider for tracking previous navigation index
  const PreviousNavIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'previousNavIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$previousNavIndexHash();

  @$internal
  @override
  PreviousNavIndex create() => PreviousNavIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$previousNavIndexHash() => r'3e8ad52d4c43b3d4d6879b991d1ed44f0d4a9acb';

/// Provider for tracking previous navigation index

abstract class _$PreviousNavIndex extends $Notifier<int> {
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

/// Provider for tracking keyboard visibility

@ProviderFor(KeyboardVisible)
const keyboardVisibleProvider = KeyboardVisibleProvider._();

/// Provider for tracking keyboard visibility
final class KeyboardVisibleProvider
    extends $NotifierProvider<KeyboardVisible, bool> {
  /// Provider for tracking keyboard visibility
  const KeyboardVisibleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keyboardVisibleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keyboardVisibleHash();

  @$internal
  @override
  KeyboardVisible create() => KeyboardVisible();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$keyboardVisibleHash() => r'ada559cf16080ff3d0d2e485bc3371e2ab191245';

/// Provider for tracking keyboard visibility

abstract class _$KeyboardVisible extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for highlighting a newly claimed item in the library
/// Stores the ID of the item to highlight, null when no highlight needed

@ProviderFor(HighlightedLibraryItem)
const highlightedLibraryItemProvider = HighlightedLibraryItemProvider._();

/// Provider for highlighting a newly claimed item in the library
/// Stores the ID of the item to highlight, null when no highlight needed
final class HighlightedLibraryItemProvider
    extends $NotifierProvider<HighlightedLibraryItem, String?> {
  /// Provider for highlighting a newly claimed item in the library
  /// Stores the ID of the item to highlight, null when no highlight needed
  const HighlightedLibraryItemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'highlightedLibraryItemProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$highlightedLibraryItemHash();

  @$internal
  @override
  HighlightedLibraryItem create() => HighlightedLibraryItem();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$highlightedLibraryItemHash() =>
    r'74c2efa49523587eff33c38966ce89f7aea07aff';

/// Provider for highlighting a newly claimed item in the library
/// Stores the ID of the item to highlight, null when no highlight needed

abstract class _$HighlightedLibraryItem extends $Notifier<String?> {
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
