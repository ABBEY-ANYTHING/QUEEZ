import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../../CreateSection/models/flashcard_set.dart';
import '../../CreateSection/services/flashcard_service.dart';
import '../../utils/color.dart';

class FlashcardPlayScreen extends StatefulWidget {
  final String flashcardSetId;
  final FlashcardSet? preloadedFlashcardSet;

  const FlashcardPlayScreen({
    super.key,
    required this.flashcardSetId,
    this.preloadedFlashcardSet,
  });

  @override
  State<FlashcardPlayScreen> createState() => _FlashcardPlayScreenState();
}

class _FlashcardPlayScreenState extends State<FlashcardPlayScreen> {
  final CardSwiperController _controller = CardSwiperController();
  FlashcardSet? _flashcardSet;
  int? _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Use preloaded flashcard set if available, otherwise fetch
    if (widget.preloadedFlashcardSet != null) {
      _flashcardSet = widget.preloadedFlashcardSet;
    } else {
      _loadFlashcardSet();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadFlashcardSet() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final flashcardSet = await FlashcardService.getFlashcardSet(
        widget.flashcardSetId,
        userId,
      );

      setState(() {
        _flashcardSet = flashcardSet;
      });
    } catch (e) {
      // Show error in snackbar instead of state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_flashcardSet == null || _flashcardSet!.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flashcards'),
          backgroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        body: const Center(child: Text('No flashcards in this set')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _flashcardSet!.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              '${(_currentIndex ?? 0) + 1} / ${_flashcardSet!.cards.length}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () {
              setState(() {
                _flashcardSet!.cards.shuffle();
                _currentIndex = 0;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CardSwiper(
              controller: _controller,
              cardsCount: _flashcardSet!.cards.length,
              onSwipe: (previousIndex, currentIndex, direction) {
                setState(() {
                  _currentIndex = currentIndex;
                });
                return true;
              },
              onUndo: (previousIndex, currentIndex, direction) {
                setState(() {
                  _currentIndex = currentIndex;
                });
                return true;
              },
              numberOfCardsDisplayed: _flashcardSet!.cards.length < 3
                  ? _flashcardSet!.cards.length
                  : 3,
              backCardOffset: const Offset(0, 40),
              padding: const EdgeInsets.all(24.0),
              cardBuilder:
                  (
                    context,
                    index,
                    horizontalThresholdPercentage,
                    verticalThresholdPercentage,
                  ) {
                    return _FlashcardWithOverlay(
                      flashcard: _flashcardSet!.cards[index],
                      index: index,
                      total: _flashcardSet!.cards.length,
                      horizontalOffset: horizontalThresholdPercentage
                          .toDouble(),
                      isTopCard: index == _currentIndex,
                    );
                  },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 120.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.undo,
                  color: Colors.orange,
                  onPressed: () => _controller.undo(),
                ),
                _buildActionButton(
                  icon: Icons.close,
                  color: Colors.red,
                  onPressed: () => _controller.swipe(CardSwiperDirection.left),
                ),
                _buildActionButton(
                  icon: Icons.check,
                  color: Colors.green,
                  onPressed: () => _controller.swipe(CardSwiperDirection.right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 28),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// Wrapper widget that adds swipe overlay effect
class _FlashcardWithOverlay extends StatelessWidget {
  final Flashcard flashcard;
  final int index;
  final int total;
  final double horizontalOffset;
  final bool isTopCard;

  const _FlashcardWithOverlay({
    required this.flashcard,
    required this.index,
    required this.total,
    required this.horizontalOffset,
    required this.isTopCard,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate opacity based on swipe progress
    final opacity = (horizontalOffset.abs() * 2).clamp(0.0, 0.6);

    // Determine swipe direction colors
    Color overlayColor;
    IconData overlayIcon;

    if (horizontalOffset > 0) {
      // Swiping right (correct/like)
      overlayColor = Colors.green;
      overlayIcon = Icons.check_circle;
    } else if (horizontalOffset < 0) {
      // Swiping left (incorrect/dislike)
      overlayColor = Colors.red;
      overlayIcon = Icons.cancel;
    } else {
      overlayColor = Colors.transparent;
      overlayIcon = Icons.circle;
    }

    return Stack(
      children: [
        // The actual flashcard widget
        _FlashcardWidget(
          flashcard: flashcard,
          index: index,
          total: total,
          isTopCard: isTopCard,
        ),
        // Swipe overlay
        if (horizontalOffset.abs() > 0.01)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: overlayColor.withValues(alpha: opacity),
              ),
              child: Center(
                child: Icon(
                  overlayIcon,
                  size: 100,
                  color: Colors.white.withValues(alpha: opacity),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  final int index;
  final int total;
  final bool isTopCard;

  const _FlashcardWidget({
    required this.flashcard,
    required this.index,
    required this.total,
    required this.isTopCard,
  });

  @override
  State<_FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<_FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void didUpdateWidget(_FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset to front when flashcard changes
    if (oldWidget.flashcard != widget.flashcard) {
      _controller.reset();
      setState(() {
        _isFront = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isTopCard ? _flipCard : null, // Only allow tap on top card
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isFrontVisible = angle < pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isFrontVisible
                ? _buildFront()
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Question',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.flashcard.front,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tap to flip',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF6C5CE7),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Answer',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.flashcard.back,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
