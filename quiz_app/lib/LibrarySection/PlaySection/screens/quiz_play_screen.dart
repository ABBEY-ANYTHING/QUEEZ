import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/question.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/LibrarySection/PlaySection/models/quiz_attempt.dart';
import 'package:quiz_app/LibrarySection/PlaySection/screens/quiz_results_screen.dart';
import 'package:quiz_app/LibrarySection/PlaySection/widgets/play_question_card.dart';
import 'package:quiz_app/LibrarySection/PlaySection/widgets/progress_timer_bar.dart';
import 'package:quiz_app/LibrarySection/widgets/quiz_library_item.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';

class QuizPlayScreen extends StatefulWidget {
  final QuizLibraryItem quizItem;
  final List<Question>? preloadedQuestions;

  const QuizPlayScreen({
    super.key,
    required this.quizItem,
    this.preloadedQuestions,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen>
    with TickerProviderStateMixin {
  QuizAttempt? _quizAttempt;
  int _currentIndex = 0;

  late AnimationController _progressController;
  late AnimationController _cardAnimationController;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();
  
  // Timer state
  Timer? _countdownTimer;
  int _timeRemaining = 30;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Use preloaded questions if available, otherwise fetch
    if (widget.preloadedQuestions != null &&
        widget.preloadedQuestions!.isNotEmpty) {
      _quizAttempt = QuizAttempt(questions: widget.preloadedQuestions!);
      _progressController.animateTo(1 / widget.preloadedQuestions!.length);
      _cardAnimationController.forward();
      _startQuestionTimer();
    } else {
      _fetchQuestions();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cardAnimationController.dispose();
    _scrollController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }
  
  void _startQuestionTimer() {
    _countdownTimer?.cancel();
    if (_quizAttempt == null || _currentIndex >= _quizAttempt!.questions.length) return;
    
    final question = _quizAttempt!.questions[_currentIndex];
    _timeRemaining = question.timeLimit;
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          timer.cancel();
          // Time's up - auto-submit with no answer (wrong)
          _onTimeUp();
        }
      });
    });
  }
  
  void _onTimeUp() {
    if (_quizAttempt == null) return;
    
    // Record as unanswered (will be marked wrong)
    _quizAttempt!.recordAnswer(_currentIndex, null);
    
    // Move to next question
    Future.delayed(const Duration(milliseconds: 500), () {
      _goToNextQuestion();
    });
  }

  Future<List<Question>> _fetchQuestions() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not authenticated");
      }
      final questions = await QuizService.fetchQuestionsByQuizId(
        widget.quizItem.id,
        userId,
      );
      if (questions.isEmpty) {
        throw Exception("This quiz has no questions.");
      }
      setState(() {
        _quizAttempt = QuizAttempt(questions: questions);
        _progressController.animateTo(1 / questions.length);
        _cardAnimationController.forward();
      });
      _startQuestionTimer(); // Start timer for first question
      return questions;
    } catch (e) {
      // Show error in snackbar instead of state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pop();
      }
      return [];
    }
  }

  void _onAnswerSelected(dynamic answer) {
    if (_quizAttempt == null) return;
    
    // Stop the timer when answer is selected
    _countdownTimer?.cancel();

    setState(() {
      _quizAttempt!.recordAnswer(_currentIndex, answer);
    });

    // Short delay to show feedback before moving to the next question
    Future.delayed(const Duration(milliseconds: 800), () {
      _goToNextQuestion();
    });
  }

  void _goToNextQuestion() {
    if (_quizAttempt == null) return;

    if (_currentIndex < _quizAttempt!.questions.length - 1) {
      _cardAnimationController.reverse().then((_) {
        setState(() {
          _currentIndex++;
          _progressController.animateTo(
            (_currentIndex + 1) / _quizAttempt!.questions.length,
          );
        });
        _cardAnimationController.forward();
        _startQuestionTimer(); // Start timer for next question
      });
    } else {
      // Quiz finished, navigate to results
      _countdownTimer?.cancel();
      _quizAttempt!.calculateScore();
      Navigator.pushReplacement(
        context,
        customRoute(
          QuizResultsScreen(
            quizItem: widget.quizItem,
            quizAttempt: _quizAttempt!,
          ),
          AnimationType.slideUp,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.quizItem.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_quizAttempt == null || _quizAttempt!.questions.isEmpty) {
      return const Center(
        child: Text(
          'No questions found for this quiz.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      );
    }

    final question = _quizAttempt!.questions[_currentIndex];
    final userAnswer = _quizAttempt!.answers[_currentIndex];
    final hasAnswered = userAnswer != null;

    // Timer and progress stay fixed at top (like Kahoot/Quizlet/Trivia Crack)
    return Column(
      children: [
        // Fixed header section - always visible
        Container(
          color: AppColors.background,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: ProgressTimerBar(
                  controller: _progressController,
                  currentIndex: _currentIndex,
                  total: _quizAttempt!.questions.length,
                ),
              ),
              // Countdown Timer - stays fixed at top
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildCountdownTimer(question.timeLimit, hasAnswered),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        // Scrollable question content
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(position: _slideAnimation, child: child);
                  },
                  child: PlayQuestionCard(
                    key: ValueKey<String>(question.id),
                    question: question,
                    userAnswer: userAnswer,
                    onAnswerSelected: _onAnswerSelected,
                    scrollController: _scrollController,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCountdownTimer(int timeLimit, bool hasAnswered) {
    final progress = timeLimit > 0 ? _timeRemaining / timeLimit : 0.0;
    final isLowTime = _timeRemaining <= 5;
    final isCriticalTime = _timeRemaining <= 3;
    
    Color timerColor;
    if (hasAnswered) {
      timerColor = AppColors.primary;
    } else if (isLowTime) {
      timerColor = const Color(0xFFE53935);
    } else if (progress > 0.6) {
      timerColor = const Color(0xFF4CAF50);
    } else if (progress > 0.3) {
      timerColor = const Color(0xFFFF9800);
    } else {
      timerColor = const Color(0xFFE53935);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: timerColor.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 20,
                    color: timerColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Time',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isCriticalTime && !hasAnswered ? 28 : 24,
                  fontWeight: FontWeight.w700,
                  color: timerColor,
                ),
                child: Text('${_timeRemaining}s'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.linear,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
