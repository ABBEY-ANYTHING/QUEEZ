import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/CreateSection/screens/create_page.dart';
import 'package:quiz_app/LibrarySection/screens/library_page.dart';
import 'package:quiz_app/ProfilePage/profile_page.dart';
import 'package:quiz_app/providers/navigation_provider.dart';
import 'package:quiz_app/screens/home_page.dart';
import 'package:quiz_app/screens/settings_page.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/custom_navigator.dart';

class BottomNavbarController extends ConsumerStatefulWidget {
  const BottomNavbarController({super.key});

  @override
  ConsumerState<BottomNavbarController> createState() =>
      BottomNavbarControllerState();
}

class BottomNavbarControllerState extends ConsumerState<BottomNavbarController>
    with TickerProviderStateMixin {
  final List<GlobalKey<NavigatorState>> navigatorKeys = List.generate(
    5,
    (index) => GlobalKey<NavigatorState>(),
  );
  late final List<Widget> _pages;

  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _navbarAnimController;
  late Animation<Offset> _navbarSlideAnimation;
  late Animation<double> _navbarFadeAnimation;
  bool _isKeyboardVisible = false;
  final List<Widget> _sections = [LibraryPage(), CreatePage()];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    // Navbar show/hide animation
    _navbarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _navbarSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1)).animate(
          CurvedAnimation(
            parent: _navbarAnimController,
            curve: Curves.easeInOut,
          ),
        );
    _navbarFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _navbarAnimController, curve: Curves.easeInOut),
    );

    _pages = [
      const HomePage(),
      CreateNavigator(navigatorKey: navigatorKeys[1], widget: _sections[0]),
      CreateNavigator(navigatorKey: navigatorKeys[2], widget: _sections[1]),
      const ProfilePage(),
      const SettingsPage(),
    ];
    _controller.forward();
  }

  void _onNavItemTapped(int index) {
    final currentIndex = ref.read(bottomNavIndexProvider);
    if (index != currentIndex) {
      ref.read(previousNavIndexProvider.notifier).setIndex(currentIndex);
      ref.read(bottomNavIndexProvider.notifier).setIndex(index);
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _navbarAnimController.dispose();
    super.dispose();
  }

  AnimationType _getAnimationType(int previous, int current) {
    if (current == 2) return AnimationType.fade;
    if (current - previous >= 1) return AnimationType.slideLeft;
    return AnimationType.slideRight;
  }

  Widget _buildTransitioningPage(int index) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final previousIndex = ref.watch(previousNavIndexProvider);
    final bool isActive = index == selectedIndex;
    final animationType = _getAnimationType(previousIndex, selectedIndex);

    return Offstage(
      offstage: !isActive,
      child: TickerMode(
        enabled: isActive,
        child: PageTransition(
          animation: _animation,
          animationType: animationType,
          child: _pages[index],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // Animate navbar based on keyboard visibility
    if (keyboardVisible && !_isKeyboardVisible) {
      _isKeyboardVisible = true;
      _navbarAnimController.forward();
    } else if (!keyboardVisible && _isKeyboardVisible) {
      _isKeyboardVisible = false;
      _navbarAnimController.reverse();
    }

    return Stack(
      children: [
        // Pages
        ...List.generate(_pages.length, _buildTransitioningPage),
        // Bottom navbar positioned at bottom
        if (!keyboardVisible)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _navbarSlideAnimation,
              child: FadeTransition(
                opacity: _navbarFadeAnimation,
                child: _BottomNavbar(
                  currentIndex: selectedIndex,
                  onTap: _onNavItemTapped,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void setIndex(int index) {
    _onNavItemTapped(index);
  }

  bool canPopCurrentNavigator() {
    final selectedIndex = ref.read(bottomNavIndexProvider);
    final navigatorKey = navigatorKeys[selectedIndex];
    return navigatorKey.currentState?.canPop() ?? false;
  }

  void popCurrentNavigator() {
    final selectedIndex = ref.read(bottomNavIndexProvider);
    final navigatorKey = navigatorKeys[selectedIndex];
    navigatorKey.currentState?.pop();
  }
}

class _BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavbar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _navItem(Icons.home_rounded, 0, 'Home'),
              _navItem(Icons.library_books_rounded, 1, 'Library'),
              _navItem(Icons.add_circle_rounded, 2, 'Create'),
              _navItem(Icons.person_rounded, 3, 'Profile'),
              _navItem(Icons.settings_rounded, 4, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index, String label) {
    final bool isActive = currentIndex == index;
    final bool isCreateButton = index == 2;

    return GestureDetector(
      onTap: () {
        if (!isActive) onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isCreateButton ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? isCreateButton
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isCreateButton ? 28 : 24,
              color: isActive
                  ? isCreateButton
                        ? AppColors.white
                        : AppColors.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? isCreateButton
                          ? AppColors.white
                          : AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
