import 'package:flutter/material.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  void _onAssessmentTap(BuildContext context) {
    customNavigate(context, '/assessment_page', AnimationType.fade);
  }

  void _onLearningToolsTap(BuildContext context) {
    customNavigate(context, '/learning_tools_page', AnimationType.fade);
  }

  void _onStudySetTap(BuildContext context) {
    customNavigate(context, '/study_set_mode_selection', AnimationType.fade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildCreateCard(
                context: context,
                icon: Icons.check_circle_outline,
                iconColor: const Color(0xFF6B9B7C),
                title: 'Assessments',
                description: 'Create quizzes, duels, polls, surveys and more!',
                onTap: () => _onAssessmentTap(context),
              ),
              const SizedBox(height: 16),
              _buildCreateCard(
                context: context,
                icon: Icons.menu_book_outlined,
                iconColor: const Color(0xFF6B9B7C),
                title: 'Learning Tools',
                description: 'Flashcards, drag and drop, games and more!',
                onTap: () => _onLearningToolsTap(context),
              ),
              const SizedBox(height: 16),
              _buildCreateCard(
                context: context,
                icon: Icons.layers_outlined,
                iconColor: const Color(0xFF6B9B7C),
                title: 'Study Set',
                description: 'Combine quizzes, flashcards, notes & more!',
                onTap: () => _onStudySetTap(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.chevron_right,
                size: 28,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
