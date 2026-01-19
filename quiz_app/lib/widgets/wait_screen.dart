import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../utils/app_logger.dart';
import '../utils/color.dart';

class WaitScreen extends StatefulWidget {
  final Future<void> Function() onLoadComplete;
  final VoidCallback onNavigate;
  final String loadingMessage;

  const WaitScreen({
    super.key,
    required this.onLoadComplete,
    required this.onNavigate,
    this.loadingMessage = 'Loading your content',
  });

  @override
  State<WaitScreen> createState() => _WaitScreenState();
}

class _WaitScreenState extends State<WaitScreen> {
  int _currentTipIndex = 0;
  final Random _random = Random();

  final List<String> _tips = [
    "Octopuses have three hearts! Two pump blood to the gills, one pumps to the rest of the body.",
    "A group of flamingos is called a \"flamboyance.\"",
    "Sloths can hold their breath longer than dolphins – up to 40 minutes underwater!",
    "Butterflies can taste with their feet.",
    "Sea otters hold hands while sleeping so they don't drift apart.",
    "Bananas are berries, but strawberries aren't.",
    "Sharks existed before trees – over 400 million years ago!",
    "Koalas have fingerprints almost identical to humans.",
    "A day on Venus is longer than a year on Venus.",
    "Wombat poop is cube-shaped!",
    "Penguins propose with pebbles. Male penguins give a pebble to a female they like.",
    "Some frogs can freeze and come back to life.",
    "Starfish don't have a brain, but they can still move and eat!",
    "Your stomach gets a new lining every 3-4 days so it doesn't digest itself.",
    "Honey never spoils – archaeologists found edible honey in 3,000-year-old tombs!",
  ];

  @override
  void initState() {
    super.initState();
    _currentTipIndex = _random.nextInt(_tips.length);
    _startTipRotation();
    _loadAndNavigate();
  }

  void _startTipRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentTipIndex = _random.nextInt(_tips.length);
        });
        _startTipRotation();
      }
    });
  }

  Future<void> _loadAndNavigate() async {
    final startTime = DateTime.now();

    try {
      // Execute the loading function
      await widget.onLoadComplete();
    } catch (e) {
      // Handle errors if needed
      AppLogger.error('Error during loading: $e');
    }

    // Calculate elapsed time
    final elapsed = DateTime.now().difference(startTime);
    final remainingTime = const Duration(seconds: 2) - elapsed;

    // Wait for remaining time if less than 2 seconds have elapsed
    if (remainingTime.inMilliseconds > 0) {
      await Future.delayed(remainingTime);
    }

    // Navigate to the target screen
    if (mounted) {
      widget.onNavigate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.loadingMessage,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Lottie loading animation
                Lottie.asset(
                  'assets/animations/yay-jump.json',
                  width: 180,
                  height: 180,
                  repeat: true,
                ),

                const SizedBox(height: 48),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    key: ValueKey(_currentTipIndex),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _tips[_currentTipIndex],
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.surface,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
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
