import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/globals.dart';

class QuestionNavigation extends StatefulWidget {
  final int currentIndex;
  final int totalQuestions;
  final Function(int) onIndexChanged;
  final VoidCallback onAddQuestion;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final bool isLocked;

  const QuestionNavigation({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.onIndexChanged,
    required this.onAddQuestion,
    required this.onToggleExpanded,
    this.isExpanded = false,
    required this.isLocked,
  });

  @override
  State<QuestionNavigation> createState() => _QuestionNavigationState();
}

class _QuestionNavigationState extends State<QuestionNavigation>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    _slideController.forward();
    _buttonController.forward();

    if (widget.isExpanded) {
      _expandController.forward();
    }
  }

  @override
  void didUpdateWidget(QuestionNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _buttonController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _handleAddQuestion() {
    _buttonController.reset();
    _buttonController.forward();
    widget.onAddQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 8,
              bottom: kBottomNavbarHeight + 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: widget.onToggleExpanded,
                  child: Center(
                    child: Icon(
                      widget.isExpanded ? Icons.expand_more : Icons.expand_less,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (widget.isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Question ${widget.currentIndex + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'of ${widget.totalQuestions}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.primaryLighter,
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        child: Slider(
                          value: widget.currentIndex.toDouble(),
                          min: 0,
                          max: (widget.totalQuestions - 1).toDouble(),
                          divisions: widget.totalQuestions > 1
                              ? widget.totalQuestions - 1
                              : 1,
                          onChanged: (value) =>
                              widget.onIndexChanged(value.round()),
                        ),
                      ),
                    ],
                  ),
                ),
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.currentIndex > 0
                                  ? () => widget.onIndexChanged(
                                      widget.currentIndex - 1,
                                    )
                                  : null,
                              icon: const Icon(
                                Icons.arrow_back_ios_rounded,
                                size: 12,
                              ),
                              label: const Text(
                                'Prev',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.currentIndex > 0
                                    ? AppColors.secondary
                                    : AppColors.iconInactive.withValues(
                                        alpha: 0.3,
                                      ),
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: widget.currentIndex > 0 ? 1 : 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  widget.currentIndex <
                                      widget.totalQuestions - 1
                                  ? () => widget.onIndexChanged(
                                      widget.currentIndex + 1,
                                    )
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    widget.currentIndex <
                                        widget.totalQuestions - 1
                                    ? AppColors.secondary
                                    : AppColors.iconInactive.withValues(
                                        alpha: 0.3,
                                      ),
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation:
                                    widget.currentIndex <
                                        widget.totalQuestions - 1
                                    ? 1
                                    : 0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('Next', style: TextStyle(fontSize: 12)),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (!widget.isLocked)
                        ScaleTransition(
                          scale: _buttonAnimation,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _handleAddQuestion,
                              icon: const Icon(
                                Icons.add_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Add Question',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentBright,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
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
        ),
      ),
    );
  }
}
