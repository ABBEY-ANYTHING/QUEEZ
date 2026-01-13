import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

/// A reusable Drag & Drop options widget for quiz questions.
/// Used by both single player and multiplayer modes.
class QuizDragDropOptions extends StatefulWidget {
  final List<String> dragItems;
  final List<String> dropTargets;
  final Map<String, String>? userAnswer; // dragItem -> dropTarget
  final Map<String, String>? correctMatches; // dragItem -> dropTarget
  final ValueChanged<Map<String, String>> onAnswerSelected;
  final bool hasAnswered;
  final bool enabled;
  final ScrollController? scrollController;

  const QuizDragDropOptions({
    super.key,
    required this.dragItems,
    required this.dropTargets,
    required this.onAnswerSelected,
    this.userAnswer,
    this.correctMatches,
    this.hasAnswered = false,
    this.enabled = true,
    this.scrollController,
  });

  @override
  State<QuizDragDropOptions> createState() => _QuizDragDropOptionsState();
}

class _QuizDragDropOptionsState extends State<QuizDragDropOptions> {
  late Map<String, String?> _dropTargetValues; // dropTarget -> dragItem
  late List<String> _availableDragItems;
  Timer? _scrollTimer;
  bool _hasSubmitted = false;
  String? _selectedItem; // For tap-to-select mode

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(QuizDragDropOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset when question changes
    if (!_listEquals(oldWidget.dragItems, widget.dragItems) ||
        !_listEquals(oldWidget.dropTargets, widget.dropTargets)) {
      _initializeState();
    }
    // Reset if hasAnswered goes from true to false
    if (!widget.hasAnswered && oldWidget.hasAnswered) {
      _initializeState();
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _initializeState() {
    _dropTargetValues = {};
    for (var target in widget.dropTargets) {
      _dropTargetValues[target] = null;
    }
    _availableDragItems = List.from(widget.dragItems);
    _hasSubmitted = false;
    _selectedItem = null;

    // Restore from userAnswer if exists
    if (widget.userAnswer != null) {
      for (var entry in widget.userAnswer!.entries) {
        final dragItem = entry.key;
        final dropTarget = entry.value;
        if (_dropTargetValues.containsKey(dropTarget)) {
          _dropTargetValues[dropTarget] = dragItem;
          _availableDragItems.remove(dragItem);
        }
      }
      _hasSubmitted = true;
    }
  }

  void _onItemTapped(String item) {
    if (!widget.enabled || widget.hasAnswered || _hasSubmitted) return;

    setState(() {
      if (_selectedItem == item) {
        _selectedItem = null;
      } else {
        _selectedItem = item;
      }
    });
  }

  void _onTargetTapped(String target) {
    if (!widget.enabled || widget.hasAnswered || _hasSubmitted) return;
    if (_selectedItem == null) return;

    _onDragItemPlaced(target, _selectedItem!);
    setState(() {
      _selectedItem = null;
    });
  }

  bool get _allItemsPlaced => !_dropTargetValues.values.contains(null);

  void _onDragItemPlaced(String target, String item) {
    if (!widget.enabled || widget.hasAnswered || _hasSubmitted) return;

    setState(() {
      // Remove item from its previous target
      _dropTargetValues.forEach((key, value) {
        if (value == item) {
          _dropTargetValues[key] = null;
        }
      });

      // If target already has an item, return it to available items
      final existingItem = _dropTargetValues[target];
      if (existingItem != null) {
        _availableDragItems.add(existingItem);
      }

      // Place item in new target
      _dropTargetValues[target] = item;
      _availableDragItems.remove(item);
    });
  }

  void _onDragItemRemoved(String target) {
    if (!widget.enabled || widget.hasAnswered || _hasSubmitted) return;

    setState(() {
      final item = _dropTargetValues[target];
      if (item != null) {
        _dropTargetValues[target] = null;
        _availableDragItems.add(item);
      }
    });
  }

  void _submitAnswer() {
    if (!_allItemsPlaced || _hasSubmitted) return;

    final answer = <String, String>{};
    _dropTargetValues.forEach((target, item) {
      if (item != null) {
        answer[item] = target; // dragItem -> dropTarget
      }
    });

    setState(() {
      _hasSubmitted = true;
    });

    widget.onAnswerSelected(answer);
  }

  void _startAutoScroll(DragUpdateDetails details) {
    if (widget.scrollController == null) return;

    final scrollController = widget.scrollController!;
    final screenHeight = MediaQuery.of(context).size.height;
    const scrollEdgeThreshold = 100.0;
    const scrollSpeed = 5.0;

    final dragY = details.globalPosition.dy;
    _scrollTimer?.cancel();

    if (dragY < scrollEdgeThreshold) {
      _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (scrollController.hasClients) {
          final newOffset = scrollController.offset - scrollSpeed;
          if (newOffset >= scrollController.position.minScrollExtent) {
            scrollController.jumpTo(newOffset);
          } else {
            scrollController.jumpTo(scrollController.position.minScrollExtent);
            timer.cancel();
          }
        }
      });
    } else if (dragY > screenHeight - scrollEdgeThreshold) {
      _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (scrollController.hasClients) {
          final newOffset = scrollController.offset + scrollSpeed;
          if (newOffset <= scrollController.position.maxScrollExtent) {
            scrollController.jumpTo(newOffset);
          } else {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
            timer.cancel();
          }
        }
      });
    }
  }

  void _stopAutoScroll() {
    _scrollTimer?.cancel();
  }

  bool? _isMatchCorrect(String target, String? item) {
    if (item == null || widget.correctMatches == null) return null;
    return widget.correctMatches![item] == target;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dragItems.isEmpty || widget.dropTargets.isEmpty) {
      return const Center(
        child: Text(
          'Invalid drag and drop question',
          style: TextStyle(fontSize: 16, color: AppColors.error),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Available Drag Items
        if (_availableDragItems.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: _availableDragItems.map((item) {
              return _buildDraggableItem(item);
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Drop Targets
        ...widget.dropTargets.map((target) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildDropTarget(target, _dropTargetValues[target]),
          );
        }),

        const SizedBox(height: 20),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                (_allItemsPlaced && !_hasSubmitted && !widget.hasAnswered)
                ? _submitAnswer
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.disabledBackground,
              disabledForegroundColor: AppColors.textDisabled,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _hasSubmitted
                  ? 'Submitted'
                  : (_allItemsPlaced ? 'Submit' : 'Place all items first'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropTarget(String target, String? placedItem) {
    final isCorrect = _isMatchCorrect(target, placedItem);
    final showFeedback =
        _hasSubmitted && placedItem != null && widget.correctMatches != null;
    final canTapToPlace =
        _selectedItem != null &&
        placedItem == null &&
        widget.enabled &&
        !widget.hasAnswered &&
        !_hasSubmitted;

    return GestureDetector(
      onTap: canTapToPlace ? () => _onTargetTapped(target) : null,
      child: DragTarget<String>(
        hitTestBehavior: HitTestBehavior.translucent,
        onWillAcceptWithDetails: (data) {
          return widget.enabled && !widget.hasAnswered && !_hasSubmitted;
        },
        onAcceptWithDetails: (data) {
          _onDragItemPlaced(target, data.data);
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty || canTapToPlace;

          Color backgroundColor;
          Color borderColor;

          if (showFeedback) {
            if (isCorrect == true) {
              backgroundColor = AppColors.success.withValues(alpha: 0.1);
              borderColor = AppColors.success;
            } else if (isCorrect == false) {
              backgroundColor = AppColors.error.withValues(alpha: 0.1);
              borderColor = AppColors.error;
            } else {
              backgroundColor = AppColors.white;
              borderColor = Colors.grey.shade300;
            }
          } else {
            backgroundColor = AppColors.white;
            borderColor = placedItem != null
                ? AppColors.primary
                : isHovering
                ? AppColors.primary
                : Colors.grey.shade300;
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: [
                // Target Label
                Expanded(
                  flex: 2,
                  child: Text(
                    target,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Arrow
                Icon(
                  Icons.arrow_forward,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  size: 20,
                ),
                const SizedBox(width: 12),

                // Placed Item or Empty Slot
                Expanded(
                  flex: 2,
                  child: placedItem != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: showFeedback
                                ? (isCorrect == true
                                      ? AppColors.success
                                      : AppColors.error)
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Text(
                                  placedItem,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (showFeedback) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  isCorrect == true
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: AppColors.white,
                                  size: 18,
                                ),
                              ] else if (!widget.hasAnswered &&
                                  !_hasSubmitted) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _onDragItemRemoved(target),
                                  child: const Icon(
                                    Icons.close,
                                    color: AppColors.white,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  canTapToPlace ? 'Tap to place' : 'Drop here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: canTapToPlace
                                        ? AppColors.primary
                                        : AppColors.textSecondary.withValues(
                                            alpha: 0.5,
                                          ),
                                    fontStyle: FontStyle.italic,
                                    fontWeight: canTapToPlace
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDraggableItem(String item) {
    final canInteract = widget.enabled && !widget.hasAnswered && !_hasSubmitted;
    final isSelected = _selectedItem == item;

    if (!canInteract) {
      return _buildItemChip(item, isSelected: false);
    }

    return GestureDetector(
      onTap: () => _onItemTapped(item),
      child: LongPressDraggable<String>(
        data: item,
        delay: const Duration(milliseconds: 200),
        hapticFeedbackOnStart: true,
        onDragStarted: () {
          setState(() {
            _selectedItem = null;
          });
        },
        onDragUpdate: _startAutoScroll,
        onDragEnd: (details) {
          _stopAutoScroll();
        },
        onDraggableCanceled: (velocity, offset) {
          _stopAutoScroll();
        },
        feedback: Material(
          color: Colors.transparent,
          elevation: 4,
          child: Transform.scale(
            scale: 1.05,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accentBright,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBright.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildItemChip(item, isSelected: false),
        ),
        child: _buildItemChip(item, isSelected: isSelected),
      ),
    );
  }

  Widget _buildItemChip(String item, {bool isSelected = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.5),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isSelected ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        item,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
    );
  }
}
