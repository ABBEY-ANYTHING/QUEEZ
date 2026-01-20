import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/flashcard_set.dart';
import 'package:quiz_app/CreateSection/services/flashcard_service.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/globals.dart';
import 'package:quiz_app/widgets/appbar/universal_appbar.dart';
import 'package:quiz_app/widgets/core/app_dialog.dart';
import 'package:uuid/uuid.dart';

/// Page for editing an existing flashcard set
// TODO: Create endpoint to update items within course packs (not create new ones)
// TODO: Add editing support for AI-generated quizzes, flashcards, and notes within a course pack
class FlashcardEditPage extends StatefulWidget {
  final FlashcardSet flashcardSet;
  final VoidCallback? onSaved;

  const FlashcardEditPage({
    super.key,
    required this.flashcardSet,
    this.onSaved,
  });

  @override
  State<FlashcardEditPage> createState() => _FlashcardEditPageState();
}

class _FlashcardEditPageState extends State<FlashcardEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late List<Map<String, String>> _cards;
  int _currentCardIndex = 0;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _hasChanges = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.flashcardSet.title);
    _descriptionController = TextEditingController(
      text: widget.flashcardSet.description,
    );

    // Convert existing cards to editable format
    _cards = widget.flashcardSet.cards.map((card) {
      return {
        'id': card.id ?? const Uuid().v4(),
        'front': card.front,
        'back': card.back,
      };
    }).toList();

    // Ensure at least one card exists
    if (_cards.isEmpty) {
      _addNewCard();
    }

    // Track changes
    _titleController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  void _onCardChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addNewCard() {
    setState(() {
      _cards.add({'id': const Uuid().v4(), 'front': '', 'back': ''});
      _currentCardIndex = _cards.length - 1;
      _hasChanges = true;
    });
  }

  Future<void> _deleteCard(int index) async {
    if (_cards.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Must have at least one card'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final shouldDelete = await AppDialog.showInput<bool>(
      context: context,
      title: 'Delete Card?',
      content: const Text(
        'Are you sure you want to delete this card? This action cannot be undone.',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      cancelText: 'Cancel',
      submitText: 'Delete',
      onSubmit: () => true,
    );

    if (shouldDelete != true) return;

    setState(() => _isDeleting = true);

    // Simulate a brief delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    setState(() {
      _cards.removeAt(index);
      if (_currentCardIndex >= _cards.length) {
        _currentCardIndex = _cards.length - 1;
      }
      _hasChanges = true;
      _isDeleting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Card deleted'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToCard(int index) {
    if (index >= 0 && index < _cards.length) {
      setState(() {
        _currentCardIndex = index;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldDiscard = await AppDialog.showInput<bool>(
      context: context,
      title: 'Discard Changes?',
      content: const Text(
        'You have unsaved changes. Are you sure you want to discard them?',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      cancelText: 'Keep Editing',
      submitText: 'Discard',
      onSubmit: () => true,
    );

    return shouldDiscard == true;
  }

  Future<void> _saveFlashcardSet() async {
    // Validate title
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate cards
    final validCards = _cards
        .where(
          (card) =>
              card['front']!.trim().isNotEmpty &&
              card['back']!.trim().isNotEmpty,
        )
        .toList();

    if (validCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add at least one card with front and back content',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FlashcardService.updateFlashcardSet(
        setId: widget.flashcardSet.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: widget.flashcardSet.category,
        creatorId: widget.flashcardSet.creatorId,
        cards: validCards,
      );

      AppLogger.success('Flashcard set updated: ${widget.flashcardSet.id}');

      if (mounted) {
        setState(() => _hasChanges = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Flashcard set saved successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        widget.onSaved?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      AppLogger.error('Error updating flashcard set: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error saving: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: (_isSaving || !_hasChanges) ? null : _saveFlashcardSet,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _hasChanges
                ? (_isSaving
                      ? AppColors.secondary.withValues(alpha: 0.6)
                      : AppColors.secondary)
                : AppColors.secondary.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 40,
                  height: 20,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                )
              : Text(
                  'Save',
                  style: TextStyle(
                    color: _hasChanges
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: UniversalAppBar(
          title: 'Edit Flashcard Set',
          showNotificationBell: false,
          actions: [_buildSaveButton()],
        ),
        body: Column(
          children: [
            // Header with title and description
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Set Title',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Description (optional)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Card editor
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card navigation - now scrollable
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Card ${_currentCardIndex + 1} of ${_cards.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _currentCardIndex > 0
                                ? () => _navigateToCard(_currentCardIndex - 1)
                                : null,
                            color: AppColors.primary,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _currentCardIndex < _cards.length - 1
                                ? () => _navigateToCard(_currentCardIndex + 1)
                                : null,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCardEditor(),
                  ],
                ),
              ),
            ),

            // Bottom action bar with proper bottom nav bar clearance
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: kBottomNavbarHeight + 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isDeleting
                          ? null
                          : () => _deleteCard(_currentCardIndex),
                      icon: _isDeleting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.delete_outline, size: 18),
                      label: Text(
                        _isDeleting ? 'Deleting...' : 'Delete Card',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addNewCard,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'Add Card',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBright,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardEditor() {
    final card = _cards[_currentCardIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Front side
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.question_mark,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Front (Question)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: TextEditingController(text: card['front'] ?? ''),
                  onChanged: (value) {
                    _cards[_currentCardIndex]['front'] = value;
                    _onCardChanged();
                  },
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Enter the question or term',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Back side
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.green,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Back (Answer)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: TextEditingController(text: card['back'] ?? ''),
                  onChanged: (value) {
                    _cards[_currentCardIndex]['back'] = value;
                    _onCardChanged();
                  },
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Enter the answer or definition',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Card thumbnails
        const Text(
          'All Cards',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _cards.length,
            itemBuilder: (context, index) {
              final isSelected = index == _currentCardIndex;
              return GestureDetector(
                onTap: () => _navigateToCard(index),
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
