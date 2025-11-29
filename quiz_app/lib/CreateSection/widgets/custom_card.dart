import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconPath;
  final VoidCallback onPressed;
  final bool showArrow;

  const CustomCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.onPressed,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(QuizSpacing.lg),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: QuizSpacing.lg),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow indicator
              if (showArrow)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
