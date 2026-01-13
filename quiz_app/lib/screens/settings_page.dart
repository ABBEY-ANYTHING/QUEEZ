import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/ProfilePage/edit_profile_page.dart';
import 'package:quiz_app/models/user_model.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/widgets/core/app_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignOut() async {
    final shouldSignOut = await AppDialog.show<bool>(
      context: context,
      title: 'Sign Out',
      content: 'Are you sure you want to sign out?',
      secondaryActionText: 'Cancel',
      secondaryActionCallback: () => Navigator.pop(context, false),
      primaryActionText: 'Sign Out',
      primaryActionCallback: () => Navigator.pop(context, true),
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
    final firstConfirm = await AppDialog.show<bool>(
      context: context,
      title: 'Delete Account',
      content:
          'This will permanently delete your account and all associated data. This action cannot be undone.\n\nAre you sure you want to continue?',
      secondaryActionText: 'Cancel',
      secondaryActionCallback: () => Navigator.pop(context, false),
      primaryActionText: 'Continue',
      primaryActionCallback: () => Navigator.pop(context, true),
    );

    if (firstConfirm != true || !mounted) return;

    // Second confirmation with password
    final TextEditingController passwordController = TextEditingController();
    final secondConfirm = await AppDialog.show<bool>(
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
      secondaryActionText: 'Cancel',
      secondaryActionCallback: () => Navigator.pop(context, false),
      primaryActionText: 'Delete Account',
      primaryActionCallback: () => Navigator.pop(context, true),
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
    final shouldReset = await AppDialog.show<bool>(
      context: context,
      title: 'Change Password',
      content:
          'We\'ll send you a password reset link to your email address. Click the link in the email to create a new password.',
      secondaryActionText: 'Cancel',
      secondaryActionCallback: () => Navigator.pop(context, false),
      primaryActionText: 'Send Reset Link',
      primaryActionCallback: () => Navigator.pop(context, true),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
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
              _buildSectionTitle('Account'),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildSettingItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profile',
                  subtitle: 'Update your profile information',
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
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  onTap: _handleChangePassword,
                ),
              ]),

              const SizedBox(height: 24),

              // Preferences Section
              _buildSectionTitle('Preferences'),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildSettingItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications settings coming soon'),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: 'English (US)',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Language selection coming soon'),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: 'Light mode',
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
              _buildSectionTitle('About'),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildSettingItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About Queez',
                  subtitle: 'Version 1.0.0',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Queez',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.quiz_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      children: [
                        const Text(
                          'Learn Smarter. Score Higher.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy policy coming soon'),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terms of service coming soon'),
                      ),
                    );
                  },
                ),
              ]),

              const SizedBox(height: 24),

              // Danger Zone
              _buildSectionTitle('Danger Zone'),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildSettingItem(
                  icon: Icons.logout_rounded,
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account',
                  onTap: _handleSignOut,
                  isDestructive: true,
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.delete_outline_rounded,
                  title: 'Delete Account',
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
