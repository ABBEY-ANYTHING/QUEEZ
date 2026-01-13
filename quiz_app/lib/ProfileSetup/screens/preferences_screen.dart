import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app/ProfileSetup/widgets/profile_progress_indicator.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User data from previous screen
  Map<String, dynamic> _userData = {};
  final List<String> _selectedInterests = [];

  @override
  void initState() {
    super.initState();
    // Get user data from previous screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _userData = args;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onComplete() {
    // Save preferences to Firestore
    _savePreferences();

    // Navigate to completion screen with all user data
    final Map<String, dynamic> completeUserData = {
      ..._userData,
      'interests': _selectedInterests,
    };

    customNavigate(
      context,
      '/profile_complete',
      AnimationType.slideLeft,
      arguments: completeUserData,
    );
  }

  Future<void> _savePreferences() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Update user document with preferences
        await _firestore.collection('users').doc(currentUser.uid).update({
          'interests': _selectedInterests,
        });
      }
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const ProfileProgressIndicator(currentStep: 4, totalSteps: 4),
              const SizedBox(height: 32),
              const Text(
                'Select Your Interests',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose topics you\'re interested in learning',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(child: _buildInterestsSection()),
              ),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentShadow,
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Complete Setup',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select at least one topic',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 14,
          children: [
            _buildInterestChip('Mathematics'),
            _buildInterestChip('Science'),
            _buildInterestChip('Physics'),
            _buildInterestChip('Chemistry'),
            _buildInterestChip('Biology'),
            _buildInterestChip('History'),
            _buildInterestChip('Geography'),
            _buildInterestChip('Literature'),
            _buildInterestChip('English'),
            _buildInterestChip('Arts'),
            _buildInterestChip('Music'),
            _buildInterestChip('Technology'),
            _buildInterestChip('Computer Science'),
            _buildInterestChip('Languages'),
            _buildInterestChip('Economics'),
            _buildInterestChip('Business'),
            _buildInterestChip('Psychology'),
            _buildInterestChip('Philosophy'),
            _buildInterestChip('Physical Education'),
          ],
        ),
      ],
    );
  }

  Widget _buildInterestChip(String label) {
    final bool isSelected = _selectedInterests.contains(label);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _toggleInterest(label),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
      ),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }
}
