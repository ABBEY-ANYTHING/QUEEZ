import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/widgets/custom_card.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';

class AssessmentPage extends StatelessWidget {
  const AssessmentPage({super.key});

  void _onQuizTap(BuildContext context) {
    customNavigate(context, '/quiz_details', AnimationType.slideLeft);
  }

  void _onPollTap(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Create a Poll tapped!')));
  }

  void _onSurveyTap(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Create a Survey tapped!')));
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Create Assessment',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.iconActive),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CustomCard(
                title: 'Create a Quiz',
                description:
                    'Test knowledge with multiple choice, true/false, and open-ended questions',
                iconPath: 'assets/icons/quiz_icon.png',
                onPressed: () => _onQuizTap(context),
                showArrow: true,
              ),
              const SizedBox(height: 16),
              CustomCard(
                title: 'Create a Poll',
                description:
                    'Gather quick opinions and instant feedback from your audience',
                iconPath: 'assets/icons/poll_icon.png',
                onPressed: () => _onPollTap(context),
                showArrow: true,
              ),
              const SizedBox(height: 16),
              CustomCard(
                title: 'Create a Survey',
                description:
                    'Collect detailed responses and comprehensive data insights',
                iconPath: 'assets/icons/survey_icon.png',
                onPressed: () => _onSurveyTap(context),
                showArrow: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
