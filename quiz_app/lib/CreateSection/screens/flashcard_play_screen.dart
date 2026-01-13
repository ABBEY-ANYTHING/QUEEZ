import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/flashcard_set.dart';
import 'package:quiz_app/CreateSection/services/flashcard_service.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/widgets/appbar/universal_appbar.dart';

class FlashcardPlayScreen extends StatefulWidget {
  final String flashcardSetId;
  final String userId;

  const FlashcardPlayScreen({
    super.key,
    required this.flashcardSetId,
    required this.userId,
  });

  @override
  State<FlashcardPlayScreen> createState() => _FlashcardPlayScreenState();
}

class _FlashcardPlayScreenState extends State<FlashcardPlayScreen>
    with SingleTickerProviderStateMixin {
  FlashcardSet? flashcardSet;
  bool isLoading = true;
  String? errorMessage;

  int currentCardIndex = 0;
  bool showAnswer = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _loadFlashcardSet();
  }

  Future<void> _loadFlashcardSet() async {
    try {
      final set = await FlashcardService.getFlashcardSet(
        widget.flashcardSetId,
        widget.userId,
      );
      setState(() {
        flashcardSet = set;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _flipCard() {
    if (showAnswer) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  void _nextCard() {
    if (currentCardIndex < (flashcardSet?.cards.length ?? 0) - 1) {
      setState(() {
        currentCardIndex++;
        showAnswer = false;
      });
      _flipController.reset();
    }
  }

  void _previousCard() {
    if (currentCardIndex > 0) {
      setState(() {
        currentCardIndex--;
        showAnswer = false;
      });
      _flipController.reset();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const UniversalAppBar(title: 'Loading...'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const UniversalAppBar(title: 'Error'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load flashcard set',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (flashcardSet == null || flashcardSet!.cards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const UniversalAppBar(title: 'No Cards'),
        body: const Center(child: Text('No flashcards available')),
      );
    }

    final currentCard = flashcardSet!.cards[currentCardIndex];
    final totalCards = flashcardSet!.cards.length;
    final progress = (currentCardIndex + 1) / totalCards;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UniversalAppBar(title: flashcardSet!.title),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Card ${currentCardIndex + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'of $totalCards',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // Flashcard
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * pi;
                    final transform = Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle);

                    return Transform(
                      transform: transform,
                      alignment: Alignment.center,
                      child: angle <= pi / 2
                          ? _buildCardFace(
                              currentCard.front,
                              'Question',
                              AppColors.primary,
                            )
                          : Transform(
                              transform: Matrix4.identity()..rotateY(pi),
                              alignment: Alignment.center,
                              child: _buildCardFace(
                                currentCard.back,
                                'Answer',
                                AppColors.accentBright,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Previous button
                ElevatedButton.icon(
                  onPressed: currentCardIndex > 0 ? _previousCard : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // Flip button
                ElevatedButton.icon(
                  onPressed: _flipCard,
                  icon: Icon(
                    showAnswer ? Icons.flip_to_front : Icons.flip_to_back,
                  ),
                  label: Text(showAnswer ? 'Show Question' : 'Show Answer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // Next button
                ElevatedButton.icon(
                  onPressed: currentCardIndex < totalCards - 1
                      ? _nextCard
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCardFace(String text, String label, Color accentColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.5,
        maxWidth: 600,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: accentColor,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tap to flip',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
