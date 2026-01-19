import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Service for managing user favourites stored in Firestore users collection
class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user's Firebase UID
  String? get _userId => _auth.currentUser?.uid;

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

  /// Add an item to favorites
  Future<void> addToFavorites(String itemId, String itemType) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    final field = _typeToField[itemType];
    if (field == null) {
      throw Exception('Invalid item type: $itemType');
    }

    try {
      await _getUserDoc().set({
        'favourites': {
          field: FieldValue.arrayUnion([itemId]),
        },
      }, SetOptions(merge: true));

      debugPrint('✅ Added $itemType item $itemId to favorites');
    } catch (e) {
      debugPrint('❌ Error adding to favorites: $e');
      rethrow;
    }
  }

  /// Remove an item from favorites
  Future<void> removeFromFavorites(String itemId, String itemType) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    final field = _typeToField[itemType];
    if (field == null) {
      throw Exception('Invalid item type: $itemType');
    }

    try {
      await _getUserDoc().update({
        'favourites.$field': FieldValue.arrayRemove([itemId]),
      });

      debugPrint('✅ Removed item $itemId from favorites');
    } catch (e) {
      debugPrint('❌ Error removing from favorites: $e');
      rethrow;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String itemId, String itemType) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final isFavorite = await isFavorited(itemId, itemType);
      if (isFavorite) {
        await removeFromFavorites(itemId, itemType);
        return false;
      } else {
        await addToFavorites(itemId, itemType);
        return true;
      }
    } catch (e) {
      debugPrint('❌ Error toggling favorite: $e');
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
      debugPrint('❌ Error checking favorite status: $e');
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
      debugPrint('❌ Error fetching favorite IDs: $e');
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
      debugPrint('❌ Error fetching all favorites: $e');
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
