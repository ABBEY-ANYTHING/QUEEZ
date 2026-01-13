import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/LibrarySection/models/library_item.dart';
import 'package:quiz_app/LibrarySection/services/unified_library_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_provider.g.dart';

/// Provider for unified library items (quizzes + flashcards)
@riverpod
class QuizLibrary extends _$QuizLibrary {
  @override
  Future<List<LibraryItem>> build() async {
    debugPrint('🔵 [LIBRARY_PROVIDER] build() called - starting data fetch');

    // Use Firebase Auth directly as the source of truth for user state
    final user = FirebaseAuth.instance.currentUser;

    debugPrint('🔵 [LIBRARY_PROVIDER] Firebase user: ${user?.uid}');

    // Only fetch if the user is logged in (Firebase user exists)
    if (user != null) {
      debugPrint(
        '🔵 [LIBRARY_PROVIDER] Fetching library for user: ${user.uid}',
      );

      try {
        final items = await UnifiedLibraryService.getUnifiedLibrary(user.uid);
        debugPrint(
          '🟢 [LIBRARY_PROVIDER] UnifiedLibraryService returned ${items.length} items',
        );

        // Log item titles for debugging
        for (var i = 0; i < items.length && i < 5; i++) {
          debugPrint(
            '🔵 [LIBRARY_PROVIDER] Item $i: ${items[i].title} (${items[i].type})',
          );
        }
        if (items.length > 5) {
          debugPrint(
            '🔵 [LIBRARY_PROVIDER] ... and ${items.length - 5} more items',
          );
        }

        // Fetch usernames from Firestore for items with originalOwner
        await _fetchUsernames(items);

        debugPrint(
          '🟢 [LIBRARY_PROVIDER] build() completed with ${items.length} items',
        );
        return items;
      } catch (e, stackTrace) {
        debugPrint('🔴 [LIBRARY_PROVIDER] ERROR in build(): $e');
        debugPrint('🔴 [LIBRARY_PROVIDER] Stack trace: $stackTrace');
        rethrow;
      }
    } else {
      // Return an empty list if not logged in.
      debugPrint(
        '🔴 [LIBRARY_PROVIDER] User not logged in, returning empty list',
      );
      return [];
    }
  }

  /// Fetch usernames from Firestore for originalOwner (batched for performance)
  Future<void> _fetchUsernames(List<LibraryItem> items) async {
    final firestore = FirebaseFirestore.instance;

    // Collect unique owner IDs
    final uniqueOwnerIds = items
        .where(
          (item) =>
              item.originalOwner != null && item.originalOwner!.isNotEmpty,
        )
        .map((item) => item.originalOwner!)
        .toSet()
        .toList();

    if (uniqueOwnerIds.isEmpty) return;

    try {
      // Batch query all usernames at once (max 10 at a time due to Firestore limitation)
      final usernameMap = <String, String>{};

      // Process in chunks of 10 (Firestore whereIn limit)
      for (var i = 0; i < uniqueOwnerIds.length; i += 10) {
        final chunk = uniqueOwnerIds.skip(i).take(10).toList();

        final userDocs = await firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (var doc in userDocs.docs) {
          final username = doc.data()['username'] as String?;
          if (username != null) {
            usernameMap[doc.id] = username;
          }
        }
      }

      // Update all items with fetched usernames
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        if (item.originalOwner != null &&
            usernameMap.containsKey(item.originalOwner)) {
          items[i] = LibraryItem(
            id: item.id,
            type: item.type,
            title: item.title,
            description: item.description,
            coverImagePath: item.coverImagePath,
            createdAt: item.createdAt,
            itemCount: item.itemCount,
            language: item.language,
            category: item.category,
            originalOwner: item.originalOwner,
            originalOwnerUsername: usernameMap[item.originalOwner]!,
            sharedMode: item.sharedMode,
          );
        }
      }
    } catch (e) {
      debugPrint('Error batch fetching usernames: $e');
      // Continue without usernames on error
    }
  }

  /// Reload library from server
  Future<void> reload() async {
    debugPrint('🔵 [LIBRARY_PROVIDER] reload() called');
    state = const AsyncValue.loading();
    debugPrint('🔵 [LIBRARY_PROVIDER] State set to loading');
    state = await AsyncValue.guard(() => build());
    debugPrint('🟢 [LIBRARY_PROVIDER] reload() completed, state updated');
  }
}
