import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/flashcard_set.dart';
import 'package:quiz_app/CreateSection/services/flashcard_service.dart';
import 'package:quiz_app/CreateSection/widgets/quiz_saved_dialog.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/widgets/appbar/universal_appbar.dart';
import 'package:quiz_app/widgets/core/app_dialog.dart';
import 'package:uuid/uuid.dart';

class FlashcardCreationPage extends StatefulWidget {
  final String title;
  final String description;
  final String category;
  final String creatorId;
  final bool isStudySetMode;
  final Function(FlashcardSet)? onSaveForStudySet;

  const FlashcardCreationPage({
    super.key,
    required this.title,
    required this.description,
    required this.category,
    required this.creatorId,
    this.isStudySetMode = false,
    this.onSaveForStudySet,
  });

  @override
  FlashcardCreationPageState createState() => FlashcardCreationPageState();
}

class FlashcardCreationPageState extends State<FlashcardCreationPage> {
  final List<Map<String, String>> _cards = [];
  int currentCardIndex = 0;
  bool _isSaving = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addNewCard(); // Start with one empty card
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addNewCard() {
    setState(() {
      _cards.add({'id': const Uuid().v4(), 'front': '', 'back': ''});
      currentCardIndex = _cards.length - 1;
    });
  }

  void _navigateToCard(int index) {
    if (index >= 0 && index < _cards.length) {
      setState(() {
        currentCardIndex = index;
      });
    }
  }

  Future<void> _saveFlashcardSet() async {
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
        const SnackBar(content: Text('Please add at least one valid card')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // If in study set mode, create flashcard set and add to cache
      if (widget.isStudySetMode && widget.onSaveForStudySet != null) {
        final flashcardSetId = const Uuid().v4();
        final flashcards = validCards
            .map(
              (card) => Flashcard(
                id: card['id']!,
                front: card['front']!,
                back: card['back']!,
              ),
            )
            .toList();

        final flashcardSet = FlashcardSet(
          id: flashcardSetId,
          title: widget.title,
          description: widget.description,
          category: widget.category,
          creatorId: widget.creatorId,
          cards: flashcards,
          createdAt: DateTime.now().toIso8601String(),
        );

        widget.onSaveForStudySet!(flashcardSet);

        if (mounted) {
          // Show success dialog with custom QuizSavedDialog
          await QuizSavedDialog.show(
            context,
            title: 'Flashcard Set Added!',
            message: 'Flashcard set has been added to your study set.',
            onDismiss: () async {
              if (mounted) {
                // Pop back to dashboard with simple slide animation
                // Stack: ... -> Dashboard -> FlashcardDetailsPage -> FlashcardCreationPage (current)
                int popCount = 0;
                Navigator.of(context).popUntil((route) {
                  return popCount++ >= 2 || route.isFirst;
                });
              }
            },
          );
        }
        return;
      }

      final flashcardSetId = await FlashcardService.createFlashcardSet(
        title: widget.title,
        description: widget.description,
        category: widget.category,
        creatorId: widget.creatorId,
        cards: validCards,
      );

      debugPrint('Flashcard set saved with ID: $flashcardSetId');

      // Show success dialog
      if (mounted) {
        await QuizSavedDialog.show(
          context,
          title: 'Success!',
          message:
              'Your flashcard set has been saved successfully and is ready to use!',
          onDismiss: () async {
            debugPrint('Success dialog dismissed');
            if (mounted) {
              // Pop back to the Create page
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        );
        debugPrint('Success dialog shown');
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _saveFlashcardSet: $e\n$stackTrace');
      if (mounted) {
        await AppDialog.show(
          context: context,
          title: 'Error',
          content: 'Failed to save flashcard set: $e',
          primaryActionText: 'OK',
          primaryActionCallback: () => Navigator.of(context).pop(),
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
        onTap: _isSaving ? null : _saveFlashcardSet,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isSaving ? Colors.grey : AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UniversalAppBar(
        title: 'Create Flashcards',
        showNotificationBell: false,
        actions: [_buildSaveButton()],
      ),
      body: _cards.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    key: ValueKey('flashcard_$currentCardIndex'),
                    child: _FlashcardInputCard(
                      key: ValueKey('card_$currentCardIndex'),
                      card: _cards[currentCardIndex],
                      onUpdate: (updatedCard) {
                        setState(() {
                          _cards[currentCardIndex] = updatedCard;
                        });
                      },
                    ),
                  ),
                ),
                _FlashcardNavigationBar(
                  currentIndex: currentCardIndex,
                  totalCards: _cards.length,
                  onIndexChanged: _navigateToCard,
                  onAddCard: _addNewCard,
                ),
              ],
            ),
    );
  }
}

class _FlashcardInputCard extends StatefulWidget {
  final Map<String, String> card;
  final Function(Map<String, String>) onUpdate;

  const _FlashcardInputCard({
    super.key,
    required this.card,
    required this.onUpdate,
  });

  @override
  State<_FlashcardInputCard> createState() => _FlashcardInputCardState();
}

class _FlashcardInputCardState extends State<_FlashcardInputCard> {
  late TextEditingController _frontController;
  late TextEditingController _backController;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(text: widget.card['front']);
    _backController = TextEditingController(text: widget.card['back']);
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  void _updateCard() {
    widget.onUpdate({
      'id': widget.card['id']!,
      'front': _frontController.text,
      'back': _backController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Question (Front)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _frontController,
            maxLines: 4,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Enter your question here...',
              hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.surface),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.surface),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (_) => _updateCard(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Answer (Back)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _backController,
            maxLines: 4,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Enter your answer here...',
              hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.surface),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.surface),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (_) => _updateCard(),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 120,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _frontController.text.isNotEmpty
                          ? _frontController.text
                          : 'Your question will appear here',
                      style: TextStyle(
                        fontSize: 16,
                        color: _frontController.text.isNotEmpty
                            ? Colors.black
                            : Colors.black.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlashcardNavigationBar extends StatelessWidget {
  final int currentIndex;
  final int totalCards;
  final Function(int) onIndexChanged;
  final VoidCallback onAddCard;

  const _FlashcardNavigationBar({
    required this.currentIndex,
    required this.totalCards,
    required this.onIndexChanged,
    required this.onAddCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          IconButton(
            onPressed: currentIndex > 0
                ? () => onIndexChanged(currentIndex - 1)
                : null,
            icon: Icon(
              Icons.arrow_back_ios,
              color: currentIndex > 0 ? AppColors.primary : Colors.grey,
            ),
          ),

          // Card counter and indicator
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${currentIndex + 1} / $totalCards',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalCards > 10 ? 10 : totalCards, (
                    index,
                  ) {
                    if (totalCards > 10 && index == 9) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          '...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == currentIndex
                            ? AppColors.primary
                            : AppColors.surface,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Next/Add button
          if (currentIndex < totalCards - 1)
            IconButton(
              onPressed: () => onIndexChanged(currentIndex + 1),
              icon: Icon(Icons.arrow_forward_ios, color: AppColors.primary),
            )
          else
            IconButton(
              onPressed: onAddCard,
              icon: Icon(Icons.add_circle, color: AppColors.primary, size: 28),
            ),
        ],
      ),
    );
  }
}
