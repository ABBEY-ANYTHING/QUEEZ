import 'package:flutter/material.dart';
// Sorry
mixin QuestionCardAnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late AnimationController slideController;
  late AnimationController fadeController;
  late AnimationController scaleController;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  void initializeAnimations() {
    // Initialize animation controllers
    slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Create animations from controllers
    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: slideController, curve: Curves.easeOutCubic),
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: fadeController, curve: Curves.easeIn));

    scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: scaleController, curve: Curves.elasticOut),
    );

    // Start the animations
    slideController.forward();
    fadeController.forward();
    scaleController.forward();
  }

  void disposeAnimations() {
    slideController.dispose();
    fadeController.dispose();
    scaleController.dispose();
  }
}
