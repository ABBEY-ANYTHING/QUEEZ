// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for unified library items (quizzes + flashcards)

@ProviderFor(QuizLibrary)
const quizLibraryProvider = QuizLibraryProvider._();

/// Provider for unified library items (quizzes + flashcards)
final class QuizLibraryProvider
    extends $AsyncNotifierProvider<QuizLibrary, List<LibraryItem>> {
  /// Provider for unified library items (quizzes + flashcards)
  const QuizLibraryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quizLibraryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quizLibraryHash();

  @$internal
  @override
  QuizLibrary create() => QuizLibrary();
}

String _$quizLibraryHash() => r'cdf7e9cbc4583754e7840862bdd56b48b3b5ad33';

/// Provider for unified library items (quizzes + flashcards)

abstract class _$QuizLibrary extends $AsyncNotifier<List<LibraryItem>> {
  FutureOr<List<LibraryItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<LibraryItem>>, List<LibraryItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<LibraryItem>>, List<LibraryItem>>,
              AsyncValue<List<LibraryItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
