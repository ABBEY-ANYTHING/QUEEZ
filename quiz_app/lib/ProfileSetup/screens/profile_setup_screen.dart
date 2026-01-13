import 'package:flutter/material.dart';
import 'package:quiz_app/ProfileSetup/screens/basic_info_screen.dart';
import 'package:quiz_app/ProfileSetup/screens/preferences_screen.dart';
import 'package:quiz_app/ProfileSetup/screens/role_selection_screen.dart';
import 'package:quiz_app/ProfileSetup/screens/welcome_screen.dart';
import 'package:quiz_app/ProfileSetup/widgets/profile_progress_indicator.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Shared state
  String? _selectedRole;
  Map<String, dynamic> _basicInfo = {};

  void _onWelcomeNext() {
    _goToPage(1);
  }

  void _onRoleSelected(String role) {
    setState(() {
      _selectedRole = role;
    });
    _goToPage(2);
  }

  void _onBasicInfoSubmitted(Map<String, dynamic> info) {
    setState(() {
      _basicInfo = info;
    });
    _goToPage(3);
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPage = page;
    });
  }

  void _onBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: AppColors.textPrimary,
                        onPressed: _onBack,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    )
                  else
                    const SizedBox(width: 4),
                  Expanded(
                    child: ProfileProgressIndicator(
                      currentStep: _currentPage + 1,
                      totalSteps: 4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  WelcomeStep(onNext: _onWelcomeNext),
                  RoleSelectionStep(onNext: _onRoleSelected),
                  BasicInfoStep(
                    selectedRole: _selectedRole,
                    onNext: _onBasicInfoSubmitted,
                  ),
                  PreferencesStep(
                    userData: {
                      'role': _selectedRole,
                      ..._basicInfo,
                    },
                    onFinish: (completeData) {
                      customNavigate(
                        context,
                        '/profile_complete',
                        AnimationType.slideLeft,
                        arguments: completeData,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
