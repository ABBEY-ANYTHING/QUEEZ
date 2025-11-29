import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/screens/ai_study_set_configuration.dart';
import 'package:quiz_app/CreateSection/widgets/custom_card.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';

class StudySetModeSelection extends StatelessWidget {
  const StudySetModeSelection({super.key});

  void _onManualTap(BuildContext context) {
    customNavigate(context, '/study_set_details', AnimationType.fade);
  }

  void _onAITap(BuildContext context) {
    Navigator.push(
      context,
      customRoute(const AIStudySetConfiguration(), AnimationType.fade),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CustomCard(
                title: 'Create Manually',
                description: 'Build your study set step by step',
                iconPath: 'assets/icons/quiz_icon.png',
                onPressed: () => _onManualTap(context),
                showArrow: true,
              ),
              const SizedBox(height: 28),
              CustomCard(
                title: 'Create with AI',
                description: 'Let AI generate from your documents',
                iconPath: 'assets/icons/flashcard_icon.png',
                onPressed: () => _onAITap(context),
                showArrow: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
