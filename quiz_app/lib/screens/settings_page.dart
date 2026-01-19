import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/ProfilePage/edit_profile_page.dart';
import 'package:quiz_app/models/user_model.dart';
import 'package:quiz_app/providers/locale_provider.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/app_strings.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/widgets/bottom_nav_aware_page.dart';
import 'package:quiz_app/widgets/core/app_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userEmail = '';
  UserModel? _userModel;
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!mounted) return;
        if (doc.exists) {
          setState(() {
            _userEmail = user.email ?? '';
            _userModel = UserModel.fromDocument(doc);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignOut() async {
    final shouldSignOut = await AppDialog.showInput<bool>(
      context: context,
      title: 'Sign Out',
      content: const Text(
        'Are you sure you want to sign out?',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      cancelText: 'Cancel',
      submitText: 'Sign Out',
      onSubmit: () => true,
    );

    if (shouldSignOut == true && mounted) {
      try {
        await _auth.signOut();
        if (mounted) {
          customNavigateReplacement(context, '/login', AnimationType.fade);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
        }
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    if (_isDeleting) return;

    // First confirmation
    final firstConfirm = await AppDialog.showInput<bool>(
      context: context,
      title: 'Delete Account',
      content: const Text(
        'This will permanently delete your account and all associated data. This action cannot be undone.\n\nAre you sure you want to continue?',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      cancelText: 'Cancel',
      submitText: 'Continue',
      onSubmit: () => true,
    );

    if (firstConfirm != true || !mounted) return;

    // Second confirmation with password
    final TextEditingController passwordController = TextEditingController();
    final secondConfirm = await AppDialog.showInput<bool>(
      context: context,
      title: 'Confirm Deletion',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Please enter your password to confirm account deletion:'),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
            ),
          ),
        ],
      ),
      cancelText: 'Cancel',
      submitText: 'Delete Account',
      onSubmit: () => true,
    );

    if (secondConfirm != true || !mounted) {
      passwordController.dispose();
      return;
    }

    final password = passwordController.text;
    passwordController.dispose();

    if (password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password is required'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isDeleting = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Show loading dialog
      if (mounted) {
        AppDialog.show(
          context: context,
          title: 'Please Wait',
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Deleting account...'),
            ],
          ),
          dismissible: false,
        );
      }

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Delete user account from Firebase Auth
      await user.delete();

      // Navigate to login - use root navigator
      if (mounted) {
        // Close loading dialog first
        Navigator.of(context, rootNavigator: true).pop();

        // Wait a moment for dialog to close
        await Future.delayed(const Duration(milliseconds: 100));

        // Navigate to login using root navigator
        if (mounted) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if open
      }
      String errorMessage = 'Error deleting account';
      if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (e.code == 'requires-recent-login') {
        errorMessage =
            'Please sign out and sign in again before deleting your account';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _handleChangePassword() async {
    final shouldReset = await AppDialog.showInput<bool>(
      context: context,
      title: 'Change Password',
      content: const Text(
        'We\'ll send you a password reset link to your email address. Click the link in the email to create a new password.',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      cancelText: 'Cancel',
      submitText: 'Send Reset Link',
      onSubmit: () => true,
    );

    if (shouldReset != true || !mounted) return;

    try {
      final user = _auth.currentUser;
      if (user?.email == null) {
        throw Exception('No email found for this account');
      }

      await _auth.sendPasswordResetEmail(email: user!.email!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset link sent to ${user.email}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to send reset email';
      if (e.code == 'user-not-found') {
        errorMessage = 'No account found with this email';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many requests. Please try again later';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showLanguageSelector() {
    final currentLocale = ref.read(localeProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.language_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Select Language',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Choose your preferred language for the app',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final language = supportedLanguages[index];
                    final isSelected =
                        currentLocale.languageCode == language.code;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(localeProvider.notifier)
                                .setLocale(language.code);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Language changed to ${language.name}',
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  language.flag,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        language.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        language.nativeName,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isSelected
                                              ? AppColors.primary.withValues(
                                                  alpha: 0.7,
                                                )
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: NavbarAwareScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get(
                  'settings',
                  ref.watch(localeProvider).languageCode,
                ),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _userEmail,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Account Section
              _buildSectionTitle(
                AppStrings.get(
                  'account',
                  ref.watch(localeProvider).languageCode,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildSettingItem(
                  icon: Icons.person_outline_rounded,
                  title: AppStrings.get(
                    'edit_profile',
                    ref.watch(localeProvider).languageCode,
                  ),
                  subtitle: AppStrings.get(
                    'update_profile_info',
                    ref.watch(localeProvider).languageCode,
                  ),
                  onTap: () async {
                    if (_userModel != null) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfilePage(userModel: _userModel!),
                        ),
                      );
                      // Reload user data if profile was updated
                      if (result == true && mounted) {
                        await _loadUserData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text('Profile updated successfully!'),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unable to load profile data'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.lock_outline_rounded,
                  title: AppStrings.get(
                    'change_password',
                    ref.watch(localeProvider).languageCode,
                  ),
                  subtitle: AppStrings.get(
                    'update_password',
                    ref.watch(localeProvider).languageCode,
                  ),
                  onTap: _handleChangePassword,
                ),
              ]),

              const SizedBox(height: 24),

              // Preferences Section
              _buildSectionTitle(
                AppStrings.get(
                  'preferences',
                  ref.watch(localeProvider).languageCode,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildSettingItem(
                  icon: Icons.language_rounded,
                  title: AppStrings.get(
                    'language',
                    ref.watch(localeProvider).languageCode,
                  ),
                  subtitle: ref
                      .watch(localeProvider.notifier)
                      .currentLanguage
                      .name,
                  onTap: () => _showLanguageSelector(),
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.palette_outlined,
                  title: AppStrings.get(
                    'theme',
                    ref.watch(localeProvider).languageCode,
                  ),
                  subtitle: AppStrings.get(
                    'light_mode',
                    ref.watch(localeProvider).languageCode,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Theme selection coming soon'),
                      ),
                    );
                  },
                ),
              ]),

              const SizedBox(height: 24),

              // About Section
              _buildSectionTitle(
                AppStrings.get('about', ref.watch(localeProvider).languageCode),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildSettingItem(
                  icon: Icons.info_outline_rounded,
                  title: AppStrings.get(
                    'about_app',
                    ref.watch(localeProvider).languageCode,
                  ),
                  subtitle:
                      '${AppStrings.get('version', ref.watch(localeProvider).languageCode)} 1.0.0',
                  onTap: () {
                    AppDialog.show(
                      context: context,
                      title: 'About Queez',
                      showCloseIcon: true,
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.quiz_rounded,
                            size: 64,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Queez',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Learn Smarter. Score Higher.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        return SafeArea(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 20,
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom + 20,
                            ),
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.65, // 👈 limit height
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      height: 5,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  const Text(
                                    "Privacy Policy",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        """
Privacy Policy for Queez
Last Updated: January 2026

1. Information We Collect
We collect information you provide when creating an account:
• Name and email address
• Profile information (age, role, subject area, experience level)
• Learning preferences and interests
• Quiz and flashcard content you create
• Study progress and performance data

2. How We Use Your Information
• To provide and improve our learning services
• To personalize your learning experience
• To track your study progress and streaks
• To enable content sharing and collaboration
• To send important service updates

3. Data Storage and Security
• All data is securely stored using Firebase
• We use industry-standard encryption
• Your password is never stored in plain text
• We implement regular security audits

4. Data Sharing
• We do NOT sell your personal data to third parties
• Quiz content you share is visible to other users based on your sharing settings
• Anonymous usage statistics may be collected for app improvement

5. Your Rights
• Access your data anytime through your profile
• Edit or update your information in Settings
• Delete your account and all associated data permanently
• Export your created content (coming soon)

6. Children's Privacy
Queez is designed for educational use. Users under 13 require parental consent.

7. Changes to This Policy
We may update this policy periodically. Continued use constitutes acceptance of changes.

8. Contact Us
For privacy concerns or questions, contact us through the app's support section.
""",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(
                                          0xFF5E8C61,
                                        ), // dark forest green
                                        foregroundColor:
                                            Colors.white, // text/icon color
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Close"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        return SafeArea(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 20,
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom + 20,
                            ),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.65,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      height: 5,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  const Text(
                                    "Terms of Service",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        """
Terms of Service for Queez
Last Updated: January 2026

1. Acceptance of Terms
By using Queez, you agree to these Terms of Service. If you disagree with any part, please discontinue use.

2. User Accounts
• You must provide accurate information during registration
• You are responsible for maintaining account security
• One account per person; sharing accounts is prohibited
• You must be 13+ years old to create an account

3. User Content
• You retain ownership of quizzes, flashcards, and notes you create
• You grant Queez a license to store and display your content
• Shared content may be viewed by other users based on your settings
• You must not upload inappropriate, offensive, or copyrighted content

4. Acceptable Use
You agree NOT to:
• Use the app for any illegal purposes
• Harass, abuse, or harm other users
• Attempt to hack or compromise app security
• Upload malicious code or spam content
• Impersonate others or create fake accounts

5. Learning Content
• Quiz and flashcard content is for educational purposes
• We do not guarantee accuracy of user-generated content
• Official educational content is clearly marked
• You are responsible for verifying information accuracy

6. Service Availability
• We strive for 99% uptime but cannot guarantee uninterrupted service
• Maintenance may cause temporary unavailability
• We reserve the right to modify or discontinue features

7. Account Termination
• We may suspend accounts violating these terms
• You can delete your account anytime from Settings
• Deleted data cannot be recovered

8. Intellectual Property
• Queez name, logo, and design are our property
• You may not copy or redistribute our proprietary content

9. Limitation of Liability
• Queez is provided "as is" without warranties
• We are not liable for any damages from app use
• Maximum liability is limited to fees paid (if any)

10. Changes to Terms
We may update these terms. Continued use means acceptance of changes.

11. Governing Law
These terms are governed by applicable laws in your jurisdiction.
""",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF5E8C61),
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Close"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ]),

              const SizedBox(height: 24),

              // Danger Zone
              _buildSectionTitle(
                AppStrings.get(
                  'danger_zone',
                  ref.watch(localeProvider).languageCode,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildSettingItem(
                  icon: Icons.logout_rounded,
                  title: AppStrings.get(
                    'sign_out',
                    ref.watch(localeProvider).languageCode,
                  ),
                  subtitle: 'Sign out of your account',
                  onTap: _handleSignOut,
                  isDestructive: true,
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.delete_outline_rounded,
                  title: AppStrings.get(
                    'delete_account',
                    ref.watch(localeProvider).languageCode,
                  ),
                  subtitle: 'Permanently delete your account',
                  onTap: _handleDeleteAccount,
                  isDestructive: true,
                ),
              ]),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? AppColors.error
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.textSecondary.withValues(alpha: 0.1),
    );
  }
}
