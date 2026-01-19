import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/widgets/custom_dropdown.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/utils/color.dart';

class PreferencesStep extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) onFinish;

  const PreferencesStep({
    super.key,
    required this.userData,
    required this.onFinish,
  });

  @override
  State<PreferencesStep> createState() => _PreferencesStepState();
}

class _PreferencesStepState extends State<PreferencesStep> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User data from previous screen
  Map<String, dynamic> _userData = {};
  final List<String> _selectedInterests = [];
  final List<String> _allInterests = [
    'Mathematics',
    'Science',
    'Physics',
    'Chemistry',
    'Biology',
    'History',
    'Geography',
    'Literature',
    'English',
    'Arts',
    'Music',
    'Technology',
    'Computer Science',
    'Languages',
    'Economics',
    'Business',
    'Psychology',
    'Philosophy',
    'Physical Education',
  ];

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
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

    widget.onFinish(completeUserData);
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
      AppLogger.error('Error saving preferences: $e');
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
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
    );
  }

  Widget _buildInterestsSection() {
    final availableInterests = _allInterests
        .where((i) => !_selectedInterests.contains(i))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select at least one topic',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        CustomDropdown(
          key: ValueKey(
            availableInterests.length,
          ), // Force rebuild to prevent state issues
          value: null,
          items: availableInterests,
          hintText: availableInterests.isEmpty
              ? 'All topics selected'
              : 'Choose a topic...',
          enabled: availableInterests.isNotEmpty,
          onChanged: (String? newValue) {
            if (newValue != null) {
              _toggleInterest(newValue);
            }
          },
        ),
        const SizedBox(height: 24),
        if (_selectedInterests.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 14,
            children: _selectedInterests.map((interest) {
              return Chip(
                label: Text(interest),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _toggleInterest(interest),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                labelStyle: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
                deleteIconColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
