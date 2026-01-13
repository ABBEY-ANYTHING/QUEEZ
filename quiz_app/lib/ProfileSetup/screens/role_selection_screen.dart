import 'package:flutter/material.dart';
import 'package:quiz_app/ProfileSetup/widgets/role_selection_card.dart';
import 'package:quiz_app/utils/color.dart';

class RoleSelectionStep extends StatefulWidget {
  final Function(String) onNext;

  const RoleSelectionStep({super.key, required this.onNext});

  @override
  State<RoleSelectionStep> createState() => _RoleSelectionStepState();
}

class _RoleSelectionStepState extends State<RoleSelectionStep> {
  String? _selectedRole;

  void _onRoleSelected(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  void _onContinue() {
    if (_selectedRole != null) {
      widget.onNext(_selectedRole!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Text(
            'Choose Your Role',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select how you\'ll be using Queez',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: RoleSelectionCard(
                    title: 'Educator',
                    description: 'Teach & manage classrooms',
                    iconData: Icons.school,
                    isSelected: _selectedRole == 'Educator',
                    onTap: () => _onRoleSelected('Educator'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: RoleSelectionCard(
                    title: 'Personal',
                    description: 'Self learning & quizzes',
                    iconData: Icons.person,
                    isSelected: _selectedRole == 'Individual/Personal',
                    onTap: () => _onRoleSelected('Individual/Personal'),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color:
                  _selectedRole != null
                      ? AppColors.primary
                      : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              boxShadow:
                  _selectedRole != null
                      ? [
                        BoxShadow(
                          color: AppColors.accentShadow,
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : null,
            ),
            child: ElevatedButton(
              onPressed: _selectedRole != null ? _onContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color:
                      _selectedRole != null
                          ? AppColors.white
                          : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
