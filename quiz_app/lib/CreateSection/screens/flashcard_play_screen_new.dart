import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../../CreateSection/models/flashcard_set.dart';
import '../../CreateSection/services/flashcard_service.dart';
import '../../widgets/appbar/universal_appbar.dart';

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
  FlashcardSet? _flashcardSet;
  List<Flashcard> _cards = [];
  List<Flashcard> _originalCards = [];
  int _totalCards = 0;
  int _correctCount = 0;
  bool _isCompleted = false;

  // History for undo - stores the card and whether it was correct
  final List<_SwipeEntry> _history = [];

  // Key to force rebuild of CardSwiper when cards change
  int _swiperKey = 0;
  CardSwiperController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = CardSwiperController();
    if (widget.preloadedFlashcardSet != null) {
      _flashcardSet = widget.preloadedFlashcardSet;
      _initializeCards();
    } else {
      _loadFlashcardSet();
    }
  }

  void _initializeCards() {
    if (_flashcardSet != null && _flashcardSet!.cards.isNotEmpty) {
      _originalCards = List.from(_flashcardSet!.cards);
      _cards = List.from(_flashcardSet!.cards);
      _totalCards = _originalCards.length;
      _correctCount = 0;
      _isCompleted = false;
      _history.clear();
      _swiperKey++;
      _recreateController();
    }
  }

  void _recreateController() {
    _controller?.dispose();
    _controller = CardSwiperController();
  }

  @override
  void dispose() {
    _controller?.dispose();
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
        _initializeCards();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop();
      }
    }
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (previousIndex < 0 || previousIndex >= _cards.length) return false;

    final card = _cards[previousIndex];

    if (direction == CardSwiperDirection.right) {
      // Correct - remove card permanently
      setState(() {
        _history.add(
          _SwipeEntry(
            card: card,
            wasCorrect: true,
            originalIndex: previousIndex,
          ),
        );
        _cards.removeAt(previousIndex);
        _correctCount++;
        _swiperKey++;
        _recreateController();

        if (_cards.isEmpty) {
          _isCompleted = true;
        }
      });
      return false; // We handle it ourselves by rebuilding
    } else if (direction == CardSwiperDirection.left) {
      // Wrong - move card to back of deck
      setState(() {
        _history.add(
          _SwipeEntry(
            card: card,
            wasCorrect: false,
            originalIndex: previousIndex,
          ),
        );
        _cards.removeAt(previousIndex);
        _cards.add(card); // Add to back
        _swiperKey++;
        _recreateController();
      });
      return false; // We handle it ourselves by rebuilding
    }

    return true;
  }

  void _handleUndo() {
    if (_history.isEmpty) return;

    final lastEntry = _history.removeLast();

    setState(() {
      if (lastEntry.wasCorrect) {
        // Was a correct swipe - add card back and decrement count
        _cards.insert(0, lastEntry.card);
        _correctCount = (_correctCount - 1).clamp(0, _totalCards);
        _isCompleted = false;
      } else {
        // Was a wrong swipe - remove from back and add to front
        if (_cards.isNotEmpty && _cards.last == lastEntry.card) {
          _cards.removeLast();
        }
        _cards.insert(0, lastEntry.card);
      }
      _swiperKey++;
      _recreateController();
    });
  }

  void _resetCards() {
    setState(() {
      _cards = List.from(_originalCards);
      _correctCount = 0;
      _isCompleted = false;
      _history.clear();
      _swiperKey++;
      _recreateController();
    });
  }

  void _shuffleCards() {
    setState(() {
      _cards.shuffle();
      _history.clear();
      _swiperKey++;
      _recreateController();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_flashcardSet == null || _originalCards.isEmpty) {
      return Scaffold(
        appBar: const UniversalAppBar(title: 'Flashcards'),
        body: const Center(child: Text('No flashcards in this set')),
      );
    }

    if (_isCompleted) {
      return _buildCompletionScreen();
    }

    if (_cards.isEmpty) {
      return _buildCompletionScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: UniversalAppBar(
        title: _flashcardSet!.title,
        showNotificationBell: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _shuffleCards,
            tooltip: 'Shuffle cards',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressCounter(),
          Expanded(
            child: _controller == null
                ? const Center(child: CircularProgressIndicator())
                : CardSwiper(
                    key: ValueKey(_swiperKey),
                    controller: _controller!,
                    cardsCount: _cards.length,
                    onSwipe: _onSwipe,
                    onUndo: (_, __, ___) => true, // We don't use built-in undo
                    numberOfCardsDisplayed: _cards.length < 3
                        ? _cards.length
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
                          if (index < 0 || index >= _cards.length) {
                            return const SizedBox.shrink();
                          }
                          final card = _cards[index];
                          return _FlashcardWithOverlay(
                            // Use unique key based on card content + position in current deck
                            key: ValueKey(
                              '${card.front}_${card.back}_${_swiperKey}_$index',
                            ),
                            flashcard: card,
                            horizontalOffset: horizontalThresholdPercentage
                                .toDouble(),
                            isTopCard: index == 0,
                          );
                        },
                  ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.layers, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '${_cards.length} cards left',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 1,
                  height: 20,
                  color: Colors.grey.shade300,
                ),
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_correctCount / $_totalCards correct',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final bool canUndo = _history.isNotEmpty;
    final bool hasCards = _cards.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 120.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Cross (wrong) button - LEFT - moves card to back
          _buildActionButton(
            icon: Icons.close,
            color: Colors.red,
            onPressed: hasCards
                ? () => _controller?.swipe(CardSwiperDirection.left)
                : null,
          ),
          // Undo button - CENTER
          _buildActionButton(
            icon: Icons.undo,
            color: canUndo ? Colors.orange : Colors.grey.shade400,
            onPressed: canUndo ? _handleUndo : null,
          ),
          // Check (correct) button - RIGHT - removes card
          _buildActionButton(
            icon: Icons.check,
            color: Colors.green,
            onPressed: hasCards
                ? () => _controller?.swipe(CardSwiperDirection.right)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    final bool isDisabled = onPressed == null;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDisabled ? Colors.grey.shade200 : Colors.white,
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDisabled ? Colors.grey.shade400 : color,
          size: 28,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: UniversalAppBar(
        title: _flashcardSet!.title,
        showNotificationBell: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.celebration,
                  size: 80,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Yay! 🎉',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'You completed the revision!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                'You got $_correctCount out of $_totalCards cards correct!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _resetCards,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Practice Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6C5CE7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF6C5CE7)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeEntry {
  final Flashcard card;
  final bool wasCorrect;
  final int originalIndex;

  _SwipeEntry({
    required this.card,
    required this.wasCorrect,
    required this.originalIndex,
  });
}

// Wrapper widget that adds swipe overlay effect
class _FlashcardWithOverlay extends StatelessWidget {
  final Flashcard flashcard;
  final double horizontalOffset;
  final bool isTopCard;

  const _FlashcardWithOverlay({
    super.key,
    required this.flashcard,
    required this.horizontalOffset,
    required this.isTopCard,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = (horizontalOffset.abs() * 2).clamp(0.0, 0.6);

    Color overlayColor;
    IconData overlayIcon;

    if (horizontalOffset > 0) {
      overlayColor = Colors.green;
      overlayIcon = Icons.check_circle;
    } else if (horizontalOffset < 0) {
      overlayColor = Colors.red;
      overlayIcon = Icons.cancel;
    } else {
      overlayColor = Colors.transparent;
      overlayIcon = Icons.circle;
    }

    return Stack(
      children: [
        _FlashcardWidget(flashcard: flashcard, isTopCard: isTopCard),
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
  final bool isTopCard;

  const _FlashcardWidget({required this.flashcard, required this.isTopCard});

  @override
  State<_FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<_FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  bool _showingFront = true;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    
    // Listen to animation status to track when animation completes
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed || 
          status == AnimationStatus.dismissed) {
        if (mounted) {
          setState(() {
            _isAnimating = false;
          });
        }
      }
    });
    
    _showingFront = true;
  }

  @override
  void didUpdateWidget(_FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset flip state when the card content changes
    if (oldWidget.flashcard.front != widget.flashcard.front ||
        oldWidget.flashcard.back != widget.flashcard.back) {
      _animController.reset();
      _showingFront = true;
      _isAnimating = false;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _flipCard() {
    // Prevent multiple rapid taps during animation
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    if (_showingFront) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
    setState(() {
      _showingFront = !_showingFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isFrontVisible = angle < pi / 2;

          // Use a Stack to layer: backing card -> rotating card
          // This prevents seeing through to the next card during flip
          return Stack(
            children: [
              // Backing card - solid card that sits behind during flip
              // This blocks the view of cards behind when the main card is rotating
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    // Always white to match the visible cards behind
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              // The actual rotating card
              Transform(
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
              ),
            ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                'Tap to flip',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                'Tap to flip back',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
