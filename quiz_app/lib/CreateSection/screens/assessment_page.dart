import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/widgets/custom_card.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/widgets/appbar/universal_appbar.dart';
import 'package:quiz_app/widgets/bottom_nav_aware_page.dart';

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
      appBar: const UniversalAppBar(title: 'Create Assessment'),

      body: SafeArea(
        child: NavbarAwareScrollView(
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
