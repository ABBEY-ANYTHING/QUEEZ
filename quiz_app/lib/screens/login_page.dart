import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';
import 'package:quiz_app/widgets/core/core_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = false;
  bool _isSignUpMode = false;

  late final AnimationController _slideController;
  late final Animation<Offset> _confirmPassOffsetAnimation;
  late final Animation<Offset> _buttonOffsetAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: QuizAnimations.slow,
    );

    _confirmPassOffsetAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    _buttonOffsetAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, 0.35)).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<bool> _isProfileSetup(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        return false;
      }

      // Check if essential profile fields exist
      final data = doc.data()!;
      final hasName =
          data.containsKey('name') &&
          data['name'] != null &&
          data['name'].toString().isNotEmpty;
      final hasRole =
          data.containsKey('role') &&
          data['role'] != null &&
          data['role'].toString().isNotEmpty;

      // Profile is complete only if it has at least name and role
      return hasName && hasRole;
    } catch (e) {
      debugPrint('Error checking profile: $e');
      return false; // On error, assume profile not setup
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter both email and password');
      return;
    }

    setState(() => _loading = true);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user?.uid;

      if (uid == null) {
        _showMessage('Failed to get user info.');
        return;
      }

      // Check if profile is set up
      final hasProfile = await _isProfileSetup(uid);

      debugPrint('Login check - UID: $uid, Has Profile: $hasProfile');

      // Save login state to SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', true);

      if (hasProfile) {
        // Profile is already set up, go to dashboard
        debugPrint('Navigating to dashboard - profile exists');
        await prefs.setBool('profileSetupCompleted', true);
        await prefs.setString('lastRoute', '/dashboard');

        // Navigate to dashboard
        if (mounted) {
          customNavigateReplacement(context, '/dashboard', AnimationType.fade);
        }
      } else {
        // Profile not set up, go to profile setup
        debugPrint('Navigating to profile setup - profile incomplete');
        await prefs.setBool('profileSetupCompleted', false);
        await prefs.setString('lastRoute', '/profile_welcome');

        // Navigate to profile setup
        if (mounted) {
          customNavigateReplacement(
            context,
            '/profile_welcome',
            AnimationType.fade,
          );
        }
      }

      // Call the callback for backward compatibility
      widget.onLoginSuccess();
    } on FirebaseAuthException catch (e) {
      _showMessage('Login failed: ${e.message}');
    } on FirebaseException catch (e) {
      _showMessage('Firebase error: ${e.message}');
    } catch (e) {
      _showMessage('An unexpected error occurred: $e');
      debugPrint('Login error details: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match');
      return;
    }

    setState(() => _loading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        _showMessage('Failed to get user info.');
        return;
      }

      // For new users, always go to profile setup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', true);
      await prefs.setBool('profileSetupCompleted', false);
      await prefs.setString('lastRoute', '/profile_welcome');
      if (!mounted) return;
      // Use customNavigateReplacement directly instead of callback
      customNavigateReplacement(
        context,
        '/profile_welcome',
        AnimationType.fade,
      );

      // Still call the callback for backward compatibility
      widget.onLoginSuccess();
    } on FirebaseAuthException catch (e) {
      _showMessage('Sign up failed: ${e.message}');
    } catch (e) {
      _showMessage('An unexpected error occurred');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    AppSnackBar.showError(context, message);
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return AppTextField(
      controller: controller,
      hintText: hint,
      prefixIcon: icon,
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }

  void _toggleSignUpMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
      if (_isSignUpMode) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: QuizSpacing.lg),
          child: AnimatedSize(
            duration: QuizAnimations.slow,
            curve: Curves.easeInOut,
            child: Container(
              padding: const EdgeInsets.all(QuizSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(QuizBorderRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🌿 Quizzy!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondaryDark,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: QuizSpacing.sm),
                  Text(
                    _isSignUpMode
                        ? 'Let\'s begin your journey'
                        : 'Let\'s continue your journey',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: QuizSpacing.xl),

                  _buildInputField(
                    controller: _emailController,
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: QuizSpacing.md),

                  _buildInputField(
                    controller: _passwordController,
                    hint: 'Enter your password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),

                  SizeTransition(
                    sizeFactor: _slideController,
                    axisAlignment: -1.0,
                    child: SlideTransition(
                      position: _confirmPassOffsetAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(top: QuizSpacing.md),
                        child: _buildInputField(
                          controller: _confirmPasswordController,
                          hint: 'Confirm your password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: QuizSpacing.lg),

                  SlideTransition(
                    position: _buttonOffsetAnimation,
                    child: AppButton.primary(
                      text: _isSignUpMode ? 'Sign Up' : 'Login',
                      onPressed: _isSignUpMode ? _signUp : _login,
                      isLoading: _loading,
                      fullWidth: true,
                      size: AppButtonSize.medium,
                    ),
                  ),

                  const SizedBox(height: QuizSpacing.lg),

                  TextButton(
                    onPressed: _loading ? null : _toggleSignUpMode,
                    child: Text(
                      _isSignUpMode
                          ? 'Already have an account? Login'
                          : 'Don\'t have an account? Sign Up',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
