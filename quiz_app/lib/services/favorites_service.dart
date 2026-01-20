import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/app_logger.dart';
import '../utils/exceptions.dart';

/// Service for managing user favourites stored in Firestore users collection
class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user's Firebase UID
  String? get _userId => _auth.currentUser?.uid;

  /// Valid item types for favorites
  static const List<String> validItemTypes = [
    'quiz',
    'flashcard',
    'note',
    'study_set',
    'course_pack',
  ];

  /// Mapping from item type to favourites field
  static const Map<String, String> _typeToField = {
    'quiz': 'quiz_favourite',
    'flashcard': 'flashcard_favourite',
    'note': 'notes_favourite',
    'study_set': 'study_set_favourite',
    'course_pack': 'course_pack_favourite',
  };

  /// Get reference to user's document
  DocumentReference<Map<String, dynamic>> _getUserDoc() {
    return _firestore.collection('users').doc(_userId);
  }

  /// Validate user is authenticated
  void _validateAuth() {
    if (_userId == null) {
      throw const AuthenticationException('User not authenticated');
    }
  }

  /// Validate item type
  String _validateAndGetField(String itemType) {
    final field = _typeToField[itemType];
    if (field == null) {
      throw InvalidItemTypeException(itemType, validTypes: validItemTypes);
    }
    return field;
  }

  /// Add an item to favorites
  Future<void> addToFavorites(String itemId, String itemType) async {
    _validateAuth();
    final field = _validateAndGetField(itemType);

    try {
      await _getUserDoc().set({
        'favourites': {
          field: FieldValue.arrayUnion([itemId]),
        },
      }, SetOptions(merge: true));

      AppLogger.success('Added $itemType item $itemId to favorites');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error adding to favorites',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FavoriteException(
        itemId: itemId,
        operation: 'add',
        message: 'Failed to add item to favorites',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Remove an item from favorites
  Future<void> removeFromFavorites(String itemId, String itemType) async {
    _validateAuth();
    final field = _validateAndGetField(itemType);

    try {
      await _getUserDoc().update({
        'favourites.$field': FieldValue.arrayRemove([itemId]),
      });

      AppLogger.success('Removed item $itemId from favorites');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error removing from favorites',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FavoriteException(
        itemId: itemId,
        operation: 'remove',
        message: 'Failed to remove item from favorites',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String itemId, String itemType) async {
    _validateAuth();

    try {
      final isFavorite = await isFavorited(itemId, itemType);
      if (isFavorite) {
        await removeFromFavorites(itemId, itemType);
        return false;
      } else {
        await addToFavorites(itemId, itemType);
        return true;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error toggling favorite',
        exception: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Check if an item is favorited
  Future<bool> isFavorited(String itemId, String itemType) async {
    if (_userId == null) {
      return false;
    }

    final field = _typeToField[itemType];
    if (field == null) {
      return false;
    }

    try {
      final doc = await _getUserDoc().get();
      if (!doc.exists) return false;

      final data = doc.data();
      final favourites = data?['favourites'] as Map<String, dynamic>?;
      if (favourites == null) return false;

      final typeList = favourites[field] as List<dynamic>?;
      return typeList?.contains(itemId) ?? false;
    } catch (e) {
      AppLogger.error('Error checking favorite status: $e');
      return false;
    }
  }

  /// Get all favorite item IDs as a flat set (for backward compatibility)
  Future<Set<String>> getFavoriteIds() async {
    if (_userId == null) {
      return {};
    }

    try {
      final doc = await _getUserDoc().get();
      if (!doc.exists) return {};

      final data = doc.data();
      final favourites = data?['favourites'] as Map<String, dynamic>?;
      if (favourites == null) return {};

      final Set<String> allIds = {};
      for (final field in _typeToField.values) {
        final typeList = favourites[field] as List<dynamic>?;
        if (typeList != null) {
          allIds.addAll(typeList.cast<String>());
        }
      }

      return allIds;
    } catch (e) {
      AppLogger.error('Error fetching favorite IDs: $e');
      return {};
    }
  }

  /// Get all favorite item IDs grouped by type
  Future<Map<String, Set<String>>> getAllFavorites() async {
    if (_userId == null) {
      return {
        'quiz': {},
        'flashcard': {},
        'note': {},
        'study_set': {},
        'course_pack': {},
      };
    }

    try {
      final doc = await _getUserDoc().get();
      if (!doc.exists) {
        return {
          'quiz': {},
          'flashcard': {},
          'note': {},
          'study_set': {},
          'course_pack': {},
        };
      }

      final data = doc.data();
      final favourites = data?['favourites'] as Map<String, dynamic>?;
      if (favourites == null) {
        return {
          'quiz': {},
          'flashcard': {},
          'note': {},
          'study_set': {},
          'course_pack': {},
        };
      }

      return {
        'quiz': Set<String>.from(
          (favourites['quiz_favourite'] as List<dynamic>?)?.cast<String>() ??
              [],
        ),
        'flashcard': Set<String>.from(
          (favourites['flashcard_favourite'] as List<dynamic>?)
                  ?.cast<String>() ??
              [],
        ),
        'note': Set<String>.from(
          (favourites['notes_favourite'] as List<dynamic>?)?.cast<String>() ??
              [],
        ),
        'study_set': Set<String>.from(
          (favourites['study_set_favourite'] as List<dynamic>?)
                  ?.cast<String>() ??
              [],
        ),
        'course_pack': Set<String>.from(
          (favourites['course_pack_favourite'] as List<dynamic>?)
                  ?.cast<String>() ??
              [],
        ),
      };
    } catch (e) {
      AppLogger.error('Error fetching all favorites: $e');
      return {
        'quiz': {},
        'flashcard': {},
        'note': {},
        'study_set': {},
        'course_pack': {},
      };
    }
  }
}
