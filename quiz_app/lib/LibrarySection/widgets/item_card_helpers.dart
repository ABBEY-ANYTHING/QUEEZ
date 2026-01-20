import 'package:flutter/material.dart';

import '../models/library_item.dart';

/// Earth tone colors for different item types in the library
class ItemCardColors {
  ItemCardColors._();

  // Card background colors (earth tones)
  static const Color quizBackground = Color(0xFFF5F0E8); // Warm cream
  static const Color noteBackground = Color(0xFFFDF6E3); // Soft sand
  static const Color studySetBackground = Color(0xFFE8F0E8); // Sage mist
  static const Color coursePackBackground = Color(0xFFE8EBF0); // Cool slate
  static const Color flashcardBackground = Color(0xFFF0EDE8); // Warm stone

  // Accent colors (darker earth tones)
  static const Color quizAccent = Color(0xFF5E8C61); // Forest green
  static const Color noteAccent = Color(0xFFB8860B); // Dark goldenrod
  static const Color studySetAccent = Color(0xFF6B8E7B); // Eucalyptus
  static const Color coursePackAccent = Color(0xFF5B6B8C); // Slate blue
  static const Color flashcardAccent = Color(0xFF8B7355); // Warm brown

  // Text colors
  static const Color quizText = Color(0xFF3D5940); // Deep forest
  static const Color noteText = Color(0xFF6B4423); // Saddle brown
  static const Color studySetText = Color(0xFF4A6B5A); // Deep sage
  static const Color coursePackText = Color(0xFF3A4A5C); // Deep slate
  static const Color flashcardText = Color(0xFF5C4A3A); // Dark brown

  /// Get background color based on item type
  static Color getBackgroundColor(LibraryItem item) {
    if (item.isQuiz) return quizBackground;
    if (item.isNote) return noteBackground;
    if (item.isStudySet) return studySetBackground;
    if (item.isCoursePack) return coursePackBackground;
    return flashcardBackground;
  }

  /// Get accent color based on item type
  static Color getAccentColor(LibraryItem item) {
    if (item.isQuiz) return quizAccent;
    if (item.isNote) return noteAccent;
    if (item.isStudySet) return studySetAccent;
    if (item.isCoursePack) return coursePackAccent;
    return flashcardAccent;
  }

  /// Get text color based on item type
  static Color getTextColor(LibraryItem item) {
    if (item.isQuiz) return quizText;
    if (item.isNote) return noteText;
    if (item.isStudySet) return studySetText;
    if (item.isCoursePack) return coursePackText;
    return flashcardText;
  }
}

/// Helper class for item type-specific UI elements
class ItemTypeHelper {
  ItemTypeHelper._();

  /// Get icon based on item type
  static IconData getIcon(LibraryItem item) {
    if (item.isQuiz) return Icons.quiz_outlined;
    if (item.isNote) return Icons.description_outlined;
    if (item.isStudySet) return Icons.collections_bookmark_outlined;
    if (item.isCoursePack) return Icons.school_outlined;
    return Icons.style_outlined; // Flashcard
  }

  /// Get label based on item type
  static String getLabel(LibraryItem item) {
    if (item.isQuiz) return 'Quiz';
    if (item.isNote) return 'Note';
    if (item.isStudySet) return 'Course Pack';
    return 'Flashcards';
  }

  /// Get item count text based on item type
  static String getItemCountText(LibraryItem item) {
    if (item.isNote) return 'Note';
    if (item.isStudySet) return '${item.itemCount} Items';
    if (item.isQuiz) return '${item.itemCount} Questions';
    if (item.isCoursePack) return '${item.itemCount} Items';
    return '${item.itemCount} Cards';
  }
}

/// Format date with shortened month (e.g., "January 20, 2025" -> "Jan 20, 2025")
String formatDateShort(String dateString) {
  try {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const shortMonths = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    for (int i = 0; i < months.length; i++) {
      if (dateString.contains(months[i])) {
        return dateString
            .replaceFirst(months[i], shortMonths[i])
            .replaceAll(', ', ' ');
      }
    }
    return dateString;
  } catch (e) {
    return dateString;
  }
}
